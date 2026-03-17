import 'dart:async';
import 'dart:convert';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_devalay_model.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../create/widget/common_guideline_text.dart';

class TempleAddressWidget extends StatefulWidget {
  const TempleAddressWidget(
      {super.key, required this.onNext, this.onBack, this.templeId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? templeId;

  @override
  State<TempleAddressWidget> createState() => _TempleAddressWidgetState();
}

class _TempleAddressWidgetState extends State<TempleAddressWidget> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeCountry = FocusNode();
  final FocusNode _focusNodeLandmark = FocusNode();
  final FocusNode _focusNodeNearestAirport = FocusNode();
  final FocusNode _focusNodeNearestRailway = FocusNode();
  final FocusNode _focusNodeGoogleLink = FocusNode();
  String? _selectedLocation;
  String isValue = '';
  ContributionDevalayModel? selectedTemple;
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default to Delhi
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;
  bool _isMapReady = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _showDropdown = false;
  String? _searchError;
  Timer? _debounceTimer;
  ContributeTempleCubit? contributeTempleCubit;
  @override
  void initState() {
    super.initState();
    _initializeFocusListeners();
    _getCurrentLocation();
  }

  void _initializeFocusListeners() {
    _focusNodeCountry
        .addListener(() => _scrollToFocusedField(_focusNodeCountry));
    _focusNodeLandmark
        .addListener(() => _scrollToFocusedField(_focusNodeLandmark));
    _focusNodeNearestAirport
        .addListener(() => _scrollToFocusedField(_focusNodeNearestAirport));
    _focusNodeNearestRailway
        .addListener(() => _scrollToFocusedField(_focusNodeNearestRailway));
    _focusNodeGoogleLink
        .addListener(() => _scrollToFocusedField(_focusNodeGoogleLink));
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final newPosition = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = newPosition;
        });

        if (_mapController != null && _isMapReady) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(newPosition),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      _showErrorSnackBar('Error getting location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      _isLoadingLocation = true;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        await _fillAddressFromPlacemark(placemark, position);

        _showSuccessSnackBar('Location selected successfully!');
      } else {
        _showErrorSnackBar('No address found for this location');
      }
    } catch (e) {
      print('Error getting address: $e');
      _showErrorSnackBar('Error getting address: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fillAddressFromPlacemark(
      Placemark placemark, LatLng position) async {
    final eventcubit = context.read<ContributeTempleCubit>();

    String street = '';

    if (placemark.subThoroughfare != null &&
        placemark.subThoroughfare!.isNotEmpty) {
      street = placemark.subThoroughfare!;
    }

    if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      street = street.isEmpty
          ? placemark.thoroughfare!
          : '$street, ${placemark.thoroughfare!}';
    }

    if (placemark.street != null &&
        placemark.street!.isNotEmpty &&
        street.isEmpty) {
      street = placemark.street!;
    }
    eventcubit.streetAddressController.text = street.trim();
    eventcubit.cityController.text =
        placemark.locality ?? placemark.subLocality ?? '';
    eventcubit.stateController.text = placemark.administrativeArea ?? '';
    eventcubit.countryController.text = placemark.country ?? '';
    eventcubit.pincodeController.text = placemark.postalCode ?? '';
    eventcubit.googleLinkController.text =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    setState(() {
      _selectedLocation = _buildLocationString(placemark);
      selectedTemple = null;
      _searchController.text = _selectedLocation ?? '';
      _showDropdown = false;
    });
  }

  void _clearLocation() {
    final eventcubit = context.read<ContributeTempleCubit>();
    setState(() {
      _selectedLocation = null;
      _markers.clear();
      _searchController.clear();
      _showDropdown = false;
      _searchResults = [];
    });
    eventcubit.streetAddressController.clear();
    eventcubit.cityController.clear();
    eventcubit.stateController.clear();
    eventcubit.countryController.clear();
    eventcubit.pincodeController.clear();
    eventcubit.googleLinkController.clear();
  }

  String _buildLocationString(Placemark placemark) {
    List<String> parts = [];

    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          _scrollController.position.extentBefore,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> _parseAndFillAddress(
      String locationDescription, String placeId) async {
    final eventcubit = context.read<ContributeTempleCubit>();

    try {
      setState(() {
        _isLoadingLocation = true;
      });

      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=address_components,formatted_address,geometry'
        '&key=AIzaSyCyg1_60NlB-xtlzhGQcoJG6OCsE6UVAu8',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final addressComponents =
              data['result']['address_components'] as List;
          final geometry = data['result']['geometry'];

          String street = '';
          String city = '';
          String state = '';
          String country = '';
          String postalCode = '';

          for (var component in addressComponents) {
            final types = component['types'] as List;
            final longName = component['long_name'] as String;

            if (types.contains('street_number')) {
              street = '$longName $street';
            } else if (types.contains('route')) {
              street = '$street$longName';
            } else if (types.contains('locality')) {
              city = longName;
            } else if (types.contains('administrative_area_level_2') &&
                city.isEmpty) {
              city = longName;
            } else if (types.contains('administrative_area_level_1')) {
              state = longName;
            } else if (types.contains('country')) {
              country = longName;
            } else if (types.contains('postal_code')) {
              postalCode = longName;
            }
          }

          eventcubit.streetAddressController.text = street.trim();
          eventcubit.cityController.text = city;
          eventcubit.stateController.text = state;
          eventcubit.countryController.text = country;
          eventcubit.pincodeController.text = postalCode;

          final lat = geometry['location']['lat'];
          final lng = geometry['location']['lng'];
          eventcubit.googleLinkController.text =
              'https://maps.google.com/?q=$lat,$lng';
          final newPosition = LatLng(lat, lng);
          setState(() {
            _currentPosition = newPosition;
            _markers = {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: newPosition,
                infoWindow: const InfoWindow(title: 'Selected Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            };
            selectedTemple = null;
            _selectedLocation = locationDescription;
            _searchController.text = locationDescription;
            _showDropdown = false;
          });
          if (_mapController != null && _isMapReady) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(newPosition),
            );
          }
          _showSuccessSnackBar('Address filled successfully!');
        } else {
          _showErrorSnackBar('Failed to get place details: ${data['status']}');
        }
      } else {
        _showErrorSnackBar('Failed to fetch place details');
      }
    } catch (e) {
      print('Error parsing address: $e');
      _showErrorSnackBar('Error parsing address: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _searchLocations(String input) async {
    if (input.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
        _showDropdown = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _showDropdown = true;
    });

    try {
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=AIzaSyCyg1_60NlB-xtlzhGQcoJG6OCsE6UVAu8'
        '&types=geocode'
        '&components=country:in',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _searchResults = data['predictions'];
            _isSearching = false;
          });
        } else {
          setState(() {
            _searchResults = [];
            _searchError =
                data['error_message'] ?? 'No results found in India.';
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _searchResults = [];
          _searchError = 'Failed to fetch results.';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _searchError = 'Error: $e';
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocations(value);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodeCountry.dispose();
    _focusNodeLandmark.dispose();
    _focusNodeNearestAirport.dispose();
    _focusNodeNearestRailway.dispose();
    _focusNodeGoogleLink.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templecubit = context.read<ContributeTempleCubit>();
        return Form(
          key: templecubit.templeAddressFromKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar (Figma style - grey #EEE background, 10px radius)
                _buildFigmaSearchBar(),
                Gap(8.h),
                // Map Section (Figma style)
                _buildFigmaMapSection(),
                Gap(20.h),
                // Address Fields
                CommonTextfield(
                  isRequired: true,
                  title: StringConstant.address,
                  controller: templecubit.streetAddressController,
                  validator: templecubit.streetAddressControllerValidator,
                ),
                Gap(8.h),
                CommonTextfield(
                  isRequired: true,
                  title: StringConstant.city,
                  controller: templecubit.cityController,
                  validator: templecubit.cityControllerValidator,
                ),
                Gap(8.h),
                CommonTextfield(
                  title: StringConstant.state,
                  controller: templecubit.stateController,
                  validator: templecubit.stateControllerValidator,
                ),
                Gap(8.h),
                CommonTextfield(
                  isRequired: true,
                  title: StringConstant.country,
                  focusNode: _focusNodeCountry,
                  controller: templecubit.countryController,
                  validator: templecubit.countryControllerValidator,
                ),
                Gap(8.h),
                CommonTextfield(
                  isRequired: true,
                  title: StringConstant.pincode,
                  focusNode: _focusNodeLandmark,
                  controller: templecubit.pincodeController,
                  validator: templecubit.landmarkControllerValidator,
                ),
                CommonFooterText(
                  onNextTap: () async {
                    if (templecubit.templeAddressFromKey.currentState!
                        .validate()) {
                      await templecubit.updateTempleAddress(widget.templeId!);
                      widget.onNext();
                    }
                  },
                  onBackTap: widget.onBack,
                ),
                Gap(20.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.templeLocate,
                  StringConstant.autoFIllAddress,
                  StringConstant.editFields,
                ]),
                Gap(10.h),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Figma-style Search Bar (grey #EEE background, 10px radius)
  Widget _buildFigmaSearchBar() {
    return Column(
      children: [
        // Search Input (Figma style)
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: StringConstant.searchToAutofillAddressInformation,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: const Color(0x993C3C43), // 60% opacity
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(10.sp),
                child: SvgPicture.asset(
                  "assets/icon/search_icon.svg",
                  height: 13.h,
                  width: 13.w,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF3C3C43),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _clearLocation,
                      icon: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                      padding: EdgeInsets.zero,
                    )
                  : RotatedBox(
                      quarterTurns: 2,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24.sp,
                        color: Colors.grey,
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            onChanged: (val) {
              setState(() {
                _showDropdown = val.isNotEmpty;
              });
              if (val.trim().isNotEmpty) {
                final templeCubit = context.read<ContributeTempleCubit>();
                templeCubit.getLocationFromGoogleApi(val);
              } else {
                setState(() {
                  _showDropdown = false;
                });
              }
            },
            onTap: () {
              if (_searchController.text.isNotEmpty) {
                setState(() {
                  _showDropdown = true;
                });
              }
            },
          ),
        ),
        // Dropdown Results
        if (_showDropdown)
          BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
            builder: (context, state) {
              final locationLoading = state is ContributeTempleLoaded 
                  ? state.locationLoading 
                  : false;
              final locationError = state is ContributeTempleLoaded 
                  ? state.locationError 
                  : null;
              final locationResults = state is ContributeTempleLoaded 
                  ? state.locationResults 
                  : <Map<String, dynamic>>[];

              return Container(
                margin: EdgeInsets.only(top: 4.h),
                constraints: BoxConstraints(maxHeight: 200.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildDropdownResults(
                  locationLoading,
                  locationError,
                  locationResults,
                ),
              );
            },
          ),
      ],
    );
  }

  /// Figma-style Map Section (rounded 4px)
  Widget _buildFigmaMapSection() {
    return SizedBox(
      height: 158.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _isMapReady = true;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 12,
              ),
              markers: _markers,
              onTap: (position) {
                _onMapTap(position);
                setState(() {
                  _showDropdown = false;
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              compassEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
            ),
            if (_isLoadingLocation)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLocationSearch() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          // height: MediaQuery.of(context).size.height/1.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Gap(20.h),
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // const Flexible(
              //   child: LocationSearchSheet(),
              // ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result['description'] != null) {
      setState(() {
        _selectedLocation = result['description'] as String;
      });

      // Parse and fill address fields
      if (result['place_id'] != null) {
        _parseAndFillAddress(
            result['description'] as String, result['place_id'] as String);
      }
    }
  }

  Widget _buildLocationSearchBar() {
    return InkWell(
      onTap: _showLocationSearch,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 12.sp),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icon/search_icon.svg",
              height: 16.h,
              width: 16.w,
              color: const Color(0xff3C3C43),
            ),
            Gap(8.w),
            Expanded(
              child: Text(
                _selectedLocation ?? 'Search to autofill address',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _selectedLocation != null
                          ? Colors.black87
                          : const Color(0xff3C3C43),
                      fontWeight: _selectedLocation != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
              ),
            ),
            if (_selectedLocation == null)
              Icon(Icons.keyboard_arrow_down, size: 24.sp, color: Colors.grey)
            else
              IconButton(
                onPressed: _clearLocation,
                icon: Icon(Icons.close, size: 20.sp, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildLocationSearchDropdown() {
  //   return Column(
  //     children: [
  //       Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(8.r),
  //           border: Border.all(color: Colors.grey.shade300),
  //         ),
  //         child: TextField(
  //           controller: _searchController,
  //           decoration: InputDecoration(
  //             hintText: StringConstant.searchToAutofillAddressInformation,
  //             prefixIcon: Padding(
  //               padding: EdgeInsets.all(16.sp),
  //               child: SvgPicture.asset(
  //                 "assets/icon/search_icon.svg",
  //                 height: 8.h,
  //                 width: 8.w,
  //                 color: const Color(0xff3C3C43),
  //               ),
  //             ),
  //             suffixIcon: _searchController.text.isNotEmpty
  //                 ? IconButton(
  //                     icon: Icon(Icons.clear, size: 20.sp),
  //                     onPressed: _clearLocation,
  //                   )
  //                 : Icon(Icons.keyboard_arrow_down,
  //                     size: 24.sp, color: Colors.grey),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8.r),
  //               borderSide: BorderSide.none,
  //             ),
  //             filled: true,
  //             fillColor: Colors.transparent,
  //             contentPadding: EdgeInsets.symmetric(
  //               horizontal: 15.sp,
  //               vertical: 12.sp,
  //             ),
  //           ),
  //           onChanged: _onSearchChanged,
  //           onTap: () {
  //             if (_searchController.text.isNotEmpty) {
  //               setState(() {
  //                 _showDropdown = true;
  //               });
  //             }
  //           },
  //         ),
  //       ),
  //       if (_showDropdown)
  //         Container(
  //           margin: EdgeInsets.only(top: 4.h),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(8.r),
  //             border: Border.all(color: Colors.grey.shade300),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.1),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           constraints: BoxConstraints(
  //             maxHeight: 300.h,
  //           ),
  //           child: _buildDropdownContent(),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildLocationSearchDropdown() {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        // Extract location-specific state variables from your cubit
        // You'll need to add these properties to your ContributeTempleState
        final locationLoading = state is ContributeTempleLoaded ? state.locationLoading : false;
        final locationError = state is ContributeTempleLoaded ? state.locationError : null;
        final locationResults = state is ContributeTempleLoaded ? state.locationResults : <Map<String, dynamic>>[];

        return Column(
          children: [
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: StringConstant.searchToAutofillAddressInformation,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.sp),
                    child: SvgPicture.asset(
                      "assets/icon/search_icon.svg",
                      height: 16.h,
                      width: 16.w,
                      color: const Color(0xff3C3C43),
                    ),
                  ),
                  suffixIcon: _searchController.text.trim().isNotEmpty
                      ? IconButton(
                    onPressed: _useManualLocation,
                    icon: const Icon(Icons.check, color: Colors.black),
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 12.w
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.5
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.5
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 0.5
                    ),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _showDropdown = true;
                  });
                  if (val.trim().isNotEmpty) {
                    context.read<ContributeTempleCubit>().getLocationFromGoogleApi(val);
                  } else {
                    setState(() {
                      _showDropdown = false;
                    });
                  }
                },
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    setState(() {
                      _showDropdown = true;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),

            // Results section similar to LocationSearchSheet
            if (_showDropdown) ...[
              Container(
                constraints: BoxConstraints(maxHeight: 300.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildDropdownResults(locationLoading, locationError, locationResults),
              ),
            ],
          ],
        );
      },
    );
  }

  void _useManualLocation() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        _selectedLocation = _searchController.text.trim();
        _showDropdown = false;
      });

      // You might want to handle manual location input here
      // For example, geocode the manual input or just use it as is
      _showSuccessSnackBar('Location set manually: ${_searchController.text.trim()}');
    }
  }

  Widget _buildDropdownResults(bool locationLoading, String? locationError,  List<dynamic> locationResults) {
    if (locationLoading) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (locationError != null) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Text(
              locationError,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (locationResults.isEmpty && _searchController.text.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            const Text('No results found.'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _useManualLocation,
                icon: const Icon(Icons.edit_location_alt),
                label: Text('Use "${_searchController.text.trim()}" as location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: locationResults.length,
      itemBuilder: (context, index) {
        final place = locationResults[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
          leading: Icon(
            Icons.location_on_outlined,
            size: 20.sp,
            color: Colors.grey,
          ),
          title: Text(
            place['main_text'] ?? '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15.sp,
            ),
          ),
          subtitle: Text(
            place['secondary_text'] ?? '',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13.sp,
            ),
          ),
          onTap: () async {
            final locationDescription = place['description'] ?? place['main_text'];
            final placeId = place['place_id'];

            setState(() {
              _searchController.text = locationDescription;
              _showDropdown = false;
            });

            // Parse and fill address using the same method you already have
            if (placeId != null) {
              await _parseAndFillAddress(locationDescription, placeId);
            }
          },
        );
      },
    );
  }


  Widget _buildDropdownContent() {
    if (_isSearching) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchError != null) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: Text(
          _searchError!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: const Text(
          'No results found.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        return InkWell(
          onTap: () async {
            await _parseAndFillAddress(
              place['description'],
              place['place_id'],
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.sp,
              vertical: 12.sp,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20.sp,
                  color: Colors.grey,
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['structured_formatting']['main_text'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                      ),
                      if (place['structured_formatting']['secondary_text'] !=
                          null)
                        Text(
                          place['structured_formatting']['secondary_text'],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _isMapReady = true;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onTap: (position) {
                    _onMapTap(position);
                    setState(() {
                      _showDropdown = false;
                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                ),
                if (_isLoadingLocation)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _getCurrentLocation,
                    child: Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap(8.h),
        Text(
          'Tap on the map to select a location and autofill address',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}


















// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
//
// // Model for address data
// class AddressData {
//   String streetAddress;
//   String city;
//   String state;
//   String country;
//   String pincode;
//   String googleLink;
//   String landmark;
//   String nearestAirport;
//   String nearestRailway;
//
//   AddressData({
//     this.streetAddress = '',
//     this.city = '',
//     this.state = '',
//     this.country = '',
//     this.pincode = '',
//     this.googleLink = '',
//     this.landmark = '',
//     this.nearestAirport = '',
//     this.nearestRailway = '',
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'streetAddress': streetAddress,
//       'city': city,
//       'state': state,
//       'country': country,
//       'pincode': pincode,
//       'googleLink': googleLink,
//       'landmark': landmark,
//       'nearestAirport': nearestAirport,
//       'nearestRailway': nearestRailway,
//     };
//   }
// }
//
// class TempleAddressWidget extends StatefulWidget {
//   final VoidCallback onNext;
//   final VoidCallback? onBack;
//   final String? templeId;
//   final AddressData? initialData;
//   final Function(AddressData)? onDataChanged;
//
//   const TempleAddressWidget({
//     super.key,
//     required this.onNext,
//     this.onBack,
//     this.templeId,
//     this.initialData,
//     this.onDataChanged,
//   });
//
//   @override
//   State<TempleAddressWidget> createState() => _TempleAddressWidgetState();
// }
//
// class _TempleAddressWidgetState extends State<TempleAddressWidget> {
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   // Text Controllers
//   final TextEditingController _streetAddressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _googleLinkController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   final TextEditingController _nearestAirportController = TextEditingController();
//   final TextEditingController _nearestRailwayController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//
//   // Focus Nodes
//   final FocusNode _focusNodeCountry = FocusNode();
//   final FocusNode _focusNodeLandmark = FocusNode();
//   final FocusNode _focusNodeNearestAirport = FocusNode();
//   final FocusNode _focusNodeNearestRailway = FocusNode();
//   final FocusNode _focusNodeGoogleLink = FocusNode();
//
//   // Map related
//   GoogleMapController? _mapController;
//   LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default to Delhi
//   Set<Marker> _markers = {};
//   bool _isLoadingLocation = false;
//   bool _isMapReady = false;
//
//   // Search related
//   List<dynamic> _searchResults = [];
//   bool _isSearching = false;
//   bool _showDropdown = false;
//   String? _searchError;
//   Timer? _debounceTimer;
//   String? _selectedLocation;
//
//   // API Key
//   static const String _googleApiKey = 'AIzaSyCyg1_60NlB-xtlzhGQcoJG6OCsE6UVAu8';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeFocusListeners();
//     _loadInitialData();
//     _getCurrentLocation();
//   }
//
//   void _loadInitialData() {
//     if (widget.initialData != null) {
//       final data = widget.initialData!;
//       _streetAddressController.text = data.streetAddress;
//       _cityController.text = data.city;
//       _stateController.text = data.state;
//       _countryController.text = data.country;
//       _pincodeController.text = data.pincode;
//       _googleLinkController.text = data.googleLink;
//       _landmarkController.text = data.landmark;
//       _nearestAirportController.text = data.nearestAirport;
//       _nearestRailwayController.text = data.nearestRailway;
//     }
//   }
//
//   void _initializeFocusListeners() {
//     _focusNodeCountry.addListener(() =>
//         _scrollToFocusedField(_focusNodeCountry));
//     _focusNodeLandmark.addListener(() =>
//         _scrollToFocusedField(_focusNodeLandmark));
//     _focusNodeNearestAirport.addListener(() =>
//         _scrollToFocusedField(_focusNodeNearestAirport));
//     _focusNodeNearestRailway.addListener(() =>
//         _scrollToFocusedField(_focusNodeNearestRailway));
//     _focusNodeGoogleLink.addListener(() =>
//         _scrollToFocusedField(_focusNodeGoogleLink));
//   }
//
//   void _scrollToFocusedField(FocusNode focusNode) {
//     if (focusNode.hasFocus) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         _scrollController.animateTo(
//           _scrollController.position.extentBefore,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       setState(() {
//         _isLoadingLocation = true;
//       });
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.whileInUse ||
//           permission == LocationPermission.always) {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//
//         final newPosition = LatLng(position.latitude, position.longitude);
//         setState(() {
//           _currentPosition = newPosition;
//         });
//
//         if (_mapController != null && _isMapReady) {
//           _mapController!.animateCamera(
//             CameraUpdate.newLatLng(newPosition),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error getting location: $e');
//       _showErrorSnackBar('Error getting location: $e');
//     } finally {
//       setState(() {
//         _isLoadingLocation = false;
//       });
//     }
//   }
//
//   Future<void> _onMapTap(LatLng position) async {
//     setState(() {
//       _isLoadingLocation = true;
//       _markers = {
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: position,
//           infoWindow: const InfoWindow(title: 'Selected Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       };
//     });
//
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         final placemark = placemarks.first;
//         await _fillAddressFromPlacemark(placemark, position);
//         _showSuccessSnackBar('Location selected successfully!');
//       } else {
//         _showErrorSnackBar('No address found for this location');
//       }
//     } catch (e) {
//       print('Error getting address: $e');
//       _showErrorSnackBar('Error getting address: $e');
//     } finally {
//       setState(() {
//         _isLoadingLocation = false;
//       });
//     }
//   }
//
//   Future<void> _fillAddressFromPlacemark(Placemark placemark,
//       LatLng position) async {
//     String street = '';
//
//     if (placemark.subThoroughfare != null &&
//         placemark.subThoroughfare!.isNotEmpty) {
//       street = placemark.subThoroughfare!;
//     }
//
//     if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
//       street = street.isEmpty
//           ? placemark.thoroughfare!
//           : '$street, ${placemark.thoroughfare!}';
//     }
//
//     if (placemark.street != null && placemark.street!.isNotEmpty &&
//         street.isEmpty) {
//       street = placemark.street!;
//     }
//
//     _streetAddressController.text = street.trim();
//     _cityController.text = placemark.locality ?? placemark.subLocality ?? '';
//     _stateController.text = placemark.administrativeArea ?? '';
//     _countryController.text = placemark.country ?? '';
//     _pincodeController.text = placemark.postalCode ?? '';
//     _googleLinkController.text =
//     'https://maps.google.com/?q=${position.latitude},${position.longitude}';
//
//     setState(() {
//       _selectedLocation = _buildLocationString(placemark);
//       _searchController.text = _selectedLocation ?? '';
//       _showDropdown = false;
//     });
//
//     _notifyDataChanged();
//   }
//
//   String _buildLocationString(Placemark placemark) {
//     List<String> parts = [];
//
//     if (placemark.locality != null && placemark.locality!.isNotEmpty) {
//       parts.add(placemark.locality!);
//     }
//     if (placemark.administrativeArea != null &&
//         placemark.administrativeArea!.isNotEmpty) {
//       parts.add(placemark.administrativeArea!);
//     }
//     if (placemark.country != null && placemark.country!.isNotEmpty) {
//       parts.add(placemark.country!);
//     }
//
//     return parts.join(', ');
//   }
//
//   Future<void> _parseAndFillAddress(String locationDescription,
//       String placeId) async {
//     try {
//       setState(() {
//         _isLoadingLocation = true;
//       });
//
//       final response = await http.get(Uri.parse(
//         'https://maps.googleapis.com/maps/api/place/details/json'
//             '?place_id=$placeId'
//             '&fields=address_components,formatted_address,geometry'
//             '&key=$_googleApiKey',
//       ));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           final addressComponents = data['result']['address_components'] as List;
//           final geometry = data['result']['geometry'];
//
//           String street = '';
//           String city = '';
//           String state = '';
//           String country = '';
//           String postalCode = '';
//
//           for (var component in addressComponents) {
//             final types = component['types'] as List;
//             final longName = component['long_name'] as String;
//
//             if (types.contains('street_number')) {
//               street = '$longName $street';
//             } else if (types.contains('route')) {
//               street = '$street$longName';
//             } else if (types.contains('locality')) {
//               city = longName;
//             } else
//             if (types.contains('administrative_area_level_2') && city.isEmpty) {
//               city = longName;
//             } else if (types.contains('administrative_area_level_1')) {
//               state = longName;
//             } else if (types.contains('country')) {
//               country = longName;
//             } else if (types.contains('postal_code')) {
//               postalCode = longName;
//             }
//           }
//
//           _streetAddressController.text = street.trim();
//           _cityController.text = city;
//           _stateController.text = state;
//           _countryController.text = country;
//           _pincodeController.text = postalCode;
//
//           final lat = geometry['location']['lat'];
//           final lng = geometry['location']['lng'];
//           _googleLinkController.text = 'https://maps.google.com/?q=$lat,$lng';
//
//           final newPosition = LatLng(lat, lng);
//           setState(() {
//             _currentPosition = newPosition;
//             _markers = {
//               Marker(
//                 markerId: const MarkerId('selected_location'),
//                 position: newPosition,
//                 infoWindow: const InfoWindow(title: 'Selected Location'),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                     BitmapDescriptor.hueRed),
//               ),
//             };
//             _selectedLocation = locationDescription;
//             _searchController.text = locationDescription;
//             _showDropdown = false;
//           });
//
//           if (_mapController != null && _isMapReady) {
//             _mapController!.animateCamera(
//               CameraUpdate.newLatLng(newPosition),
//             );
//           }
//
//           _notifyDataChanged();
//           _showSuccessSnackBar('Address filled successfully!');
//         } else {
//           _showErrorSnackBar('Failed to get place details: ${data['status']}');
//         }
//       } else {
//         _showErrorSnackBar('Failed to fetch place details');
//       }
//     } catch (e) {
//       print('Error parsing address: $e');
//       _showErrorSnackBar('Error parsing address: $e');
//     } finally {
//       setState(() {
//         _isLoadingLocation = false;
//       });
//     }
//   }
//
//   Future<void> _searchLocations(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _searchResults = [];
//         _searchError = null;
//         _showDropdown = false;
//       });
//       return;
//     }
//
//     setState(() {
//       _isSearching = true;
//       _searchError = null;
//       _showDropdown = true;
//     });
//
//     try {
//       final response = await http.get(Uri.parse(
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json'
//             '?input=${Uri.encodeComponent(input)}'
//             '&key=$_googleApiKey'
//             '&types=geocode'
//             '&components=country:in',
//       ));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           setState(() {
//             _searchResults = data['predictions'];
//             _isSearching = false;
//           });
//         } else {
//           setState(() {
//             _searchResults = [];
//             _searchError =
//                 data['error_message'] ?? 'No results found in India.';
//             _isSearching = false;
//           });
//         }
//       } else {
//         setState(() {
//           _searchResults = [];
//           _searchError = 'Failed to fetch results.';
//           _isSearching = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _searchResults = [];
//         _searchError = 'Error: $e';
//         _isSearching = false;
//       });
//     }
//   }
//
//   void _onSearchChanged(String value) {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       _searchLocations(value);
//     });
//   }
//
//   void _clearLocation() {
//     setState(() {
//       _selectedLocation = null;
//       _markers.clear();
//       _searchController.clear();
//       _showDropdown = false;
//       _searchResults = [];
//     });
//
//     _streetAddressController.clear();
//     _cityController.clear();
//     _stateController.clear();
//     _countryController.clear();
//     _pincodeController.clear();
//     _googleLinkController.clear();
//
//     _notifyDataChanged();
//   }
//
//   void _notifyDataChanged() {
//     if (widget.onDataChanged != null) {
//       final addressData = AddressData(
//         streetAddress: _streetAddressController.text,
//         city: _cityController.text,
//         state: _stateController.text,
//         country: _countryController.text,
//         pincode: _pincodeController.text,
//         googleLink: _googleLinkController.text,
//         landmark: _landmarkController.text,
//         nearestAirport: _nearestAirportController.text,
//         nearestRailway: _nearestRailwayController.text,
//       );
//       widget.onDataChanged!(addressData);
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   String? _validateRequired(String? value, String fieldName) {
//     if (value == null || value
//         .trim()
//         .isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }
//
//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     _scrollController.dispose();
//     _focusNodeCountry.dispose();
//     _focusNodeLandmark.dispose();
//     _focusNodeNearestAirport.dispose();
//     _focusNodeNearestRailway.dispose();
//     _focusNodeGoogleLink.dispose();
//     _mapController?.dispose();
//
//     _streetAddressController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _countryController.dispose();
//     _pincodeController.dispose();
//     _googleLinkController.dispose();
//     _landmarkController.dispose();
//     _nearestAirportController.dispose();
//     _nearestRailwayController.dispose();
//     _searchController.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         padding: EdgeInsets.only(bottom: MediaQuery
//             .of(context)
//             .viewInsets
//             .bottom),
//         child: Column(
//           children: [
//             _buildLocationSearchDropdown(),
//             Gap(10.h),
//             _buildMapSection(),
//             Gap(20.h),
//
//             // Address Fields
//             _buildTextField(
//               title: "Address *",
//               controller: _streetAddressController,
//               validator: (value) => _validateRequired(value, 'Address'),
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "City *",
//               controller: _cityController,
//               validator: (value) => _validateRequired(value, 'City'),
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "State *",
//               controller: _stateController,
//               validator: (value) => _validateRequired(value, 'State'),
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "Country *",
//               controller: _countryController,
//               focusNode: _focusNodeCountry,
//               validator: (value) => _validateRequired(value, 'Country'),
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "Pincode *",
//               controller: _pincodeController,
//               focusNode: _focusNodeLandmark,
//               validator: (value) => _validateRequired(value, 'Pincode'),
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "Landmark",
//               controller: _landmarkController,
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "Nearest Airport",
//               controller: _nearestAirportController,
//               focusNode: _focusNodeNearestAirport,
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "Nearest Railway",
//               controller: _nearestRailwayController,
//               focusNode: _focusNodeNearestRailway,
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//             Gap(10.h),
//
//             _buildTextField(
//               title: "Google Link",
//               controller: _googleLinkController,
//               focusNode: _focusNodeGoogleLink,
//               onChanged: (_) => _notifyDataChanged(),
//             ),
//
//             Gap(20.h),
//             _buildFooterButtons(),
//             Gap(20.h),
//             // _buildGuidelines(),
//             Gap(10.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required String title,
//     required TextEditingController controller,
//     FocusNode? focusNode,
//     String? Function(String?)? validator,
//     Function(String)? onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         Gap(6.h),
//         TextFormField(
//           controller: controller,
//           focusNode: focusNode,
//           validator: validator,
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             hintText: "Enter $title",
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: const BorderSide(color: Colors.blue),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 12.h,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLocationSearchDropdown() {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8.r),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search to autofill address information",
//               prefixIcon: Padding(
//                 padding: EdgeInsets.all(16.sp),
//                 child: Icon(
//                   Icons.search,
//                   size: 20.sp,
//                   color: const Color(0xff3C3C43),
//                 ),
//               ),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                 icon: Icon(Icons.clear, size: 20.sp),
//                 onPressed: _clearLocation,
//               )
//                   : Icon(
//                   Icons.keyboard_arrow_down, size: 24.sp, color: Colors.grey),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//                 borderSide: BorderSide.none,
//               ),
//               filled: true,
//               fillColor: Colors.transparent,
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 15.sp,
//                 vertical: 12.sp,
//               ),
//             ),
//             onChanged: _onSearchChanged,
//             onTap: () {
//               if (_searchController.text.isNotEmpty) {
//                 setState(() {
//                   _showDropdown = true;
//                 });
//               }
//             },
//           ),
//         ),
//         if (_showDropdown) _buildDropdownContent(),
//       ],
//     );
//   }
//
//   Widget _buildDropdownContent() {
//     return Container(
//       margin: EdgeInsets.only(top: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       constraints: BoxConstraints(maxHeight: 300.h),
//       child: _isSearching
//           ? Container(
//         padding: EdgeInsets.all(16.sp),
//         child: const Center(child: CircularProgressIndicator()),
//       )
//           : _searchError != null
//           ? Container(
//         padding: EdgeInsets.all(16.sp),
//         child: Text(
//           _searchError!,
//           style: const TextStyle(color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//       )
//           : _searchResults.isEmpty && _searchController.text.isNotEmpty
//           ? Container(
//         padding: EdgeInsets.all(16.sp),
//         child: const Text(
//           'No results found.',
//           textAlign: TextAlign.center,
//         ),
//       )
//           : ListView.builder(
//         shrinkWrap: true,
//         itemCount: _searchResults.length,
//         itemBuilder: (context, index) {
//           final place = _searchResults[index];
//           return InkWell(
//             onTap: () async {
//               await _parseAndFillAddress(
//                 place['description'],
//                 place['place_id'],
//               );
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: 16.sp,
//                 vertical: 12.sp,
//               ),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade200,
//                     width: 0.5,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.location_on_outlined,
//                     size: 20.sp,
//                     color: Colors.grey,
//                   ),
//                   Gap(12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           place['structured_formatting']['main_text'] ?? '',
//                           style: Theme
//                               .of(context)
//                               .textTheme
//                               .bodyMedium
//                               ?.copyWith(
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         if (place['structured_formatting']['secondary_text'] !=
//                             null)
//                           Text(
//                             place['structured_formatting']['secondary_text'],
//                             style: Theme
//                                 .of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildMapSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 200.h,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(4.r),
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   onMapCreated: (GoogleMapController controller) {
//                     _mapController = controller;
//                     _isMapReady = true;
//                   },
//                   initialCameraPosition: CameraPosition(
//                     target: _currentPosition,
//                     zoom: 15,
//                   ),
//                   markers: _markers,
//                   onTap: (position) {
//                     _onMapTap(position);
//                     setState(() {
//                       _showDropdown = false;
//                     });
//                   },
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                   mapType: MapType.normal,
//                   compassEnabled: true,
//                   zoomGesturesEnabled: true,
//                   scrollGesturesEnabled: true,
//                   rotateGesturesEnabled: true,
//                   tiltGesturesEnabled: true,
//                 ),
//                 if (_isLoadingLocation)
//                   Container(
//                     color: Colors.black26,
//                     child: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: FloatingActionButton(
//                     mini: true,
//                     backgroundColor: Colors.white,
//                     onPressed: _getCurrentLocation,
//                     child: Icon(
//                       Icons.my_location,
//                       color: Colors.blue,
//                       size: 20.sp,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Gap(8.h),
//         Text(
//           'Tap on the map to select a location and autofill address',
//           style: Theme
//               .of(context)
//               .textTheme
//               .labelMedium
//               ?.copyWith(
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFooterButtons() {
//     return Row(
//       children: [
//         if (widget.onBack != null)
//           Expanded(
//             child: OutlinedButton(
//               onPressed: widget.onBack,
//               style: OutlinedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 12.h),
//                 side: const BorderSide(color: Colors.grey),
//               ),
//               child: const Text('Back'),
//             ),
//           ),
//         if (widget.onBack != null) Gap(12.w),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 widget.onNext();
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(vertical: 12.h),
//             ),
//             child: const Text('Next'),
//           ),
//         ),
//       ],
//     );
//   }
// }

  // Widget _buildGui