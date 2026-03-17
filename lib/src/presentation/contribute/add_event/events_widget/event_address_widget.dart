import 'dart:async';

import 'package:devalay_app/src/application/contribution/god_form/god_form_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_event/contribution_event_cubit.dart';
import '../../../../application/contribution/contribution_event/contribution_event_state.dart';
import '../../../../application/contribution/god_form/god_form_state.dart';
import '../../../../application/feed/feed_home/feed_home_cubit.dart';
import '../../../../application/feed/feed_home/feed_home_state.dart';
import '../../../../data/model/contribution/temple_list_model.dart';
import '../../../core/utils/colors.dart';
import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class EventAddressWidget extends StatefulWidget {
  const EventAddressWidget({
    super.key,
    required this.onNext,
    this.onBack,
    this.eventId,
  });

  final void Function() onNext;
  final VoidCallback? onBack;
  final String? eventId;

  @override
  State<EventAddressWidget> createState() => _EventAddressWidgetState();
}

class _EventAddressWidgetState extends State<EventAddressWidget> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeCountry = FocusNode();
  final FocusNode _focusNodeLandmark = FocusNode();
  final FocusNode _focusNodeNearestAirport = FocusNode();
  final FocusNode _focusNodeNearestRailway = FocusNode();
  final FocusNode _focusNodeGoogleLink = FocusNode();
  bool _showTempleDropdown = false;
  bool isChecked = false;
  TempleListModel? selectedTemple;
  String isValue = '';
  String? _selectedLocation;

  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090);
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;
  bool _isMapReady = false;

  final TextEditingController _searchController = TextEditingController();
  bool _showLocationDropdown = false;

  late FeedHomeCubit _feedHomeCubit;

  @override
  void initState() {
    super.initState();
    _initializeFocusListeners();
    context.read<GodFormCubit>().fetchGodTempleData();
    _getCurrentLocation();
    _feedHomeCubit = context.read<FeedHomeCubit>();
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
      _showErrorSnackBar('Error getting address: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fillAddressFromPlacemark(
      Placemark placemark, LatLng position) async {
    final eventcubit = context.read<ContributeEventCubit>();

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
      _showLocationDropdown = false;
    });
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

  void _onLocationSelected(String locationDescription) {
    // Add debug print to see what we're getting
    print('DEBUG: Selected location: $locationDescription');

    setState(() {
      _selectedLocation = locationDescription;
      _searchController.text = locationDescription;
      _showLocationDropdown = false;
      selectedTemple = null;
    });

    // You can add logic here to parse the selected location
    // and fill the address fields if needed
  }

  void _clearLocation() {
    final eventcubit = context.read<ContributeEventCubit>();
    setState(() {
      _selectedLocation = null;
      _markers.clear();
      _searchController.clear();
      _showLocationDropdown = false;
    });
    eventcubit.streetAddressController.clear();
    eventcubit.cityController.clear();
    eventcubit.stateController.clear();
    eventcubit.countryController.clear();
    eventcubit.pincodeController.clear();
    eventcubit.googleLinkController.clear();
    _feedHomeCubit.clearLocationResults();
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

  bool _areAddressFieldsFilled() {
    final eventcubit = context.read<ContributeEventCubit>();
    return eventcubit.streetAddressController.text.isNotEmpty ||
        eventcubit.cityController.text.isNotEmpty ||
        eventcubit.stateController.text.isNotEmpty ||
        eventcubit.countryController.text.isNotEmpty;
  }

  void _clearTempleIfAddressFilled() {
    if (_areAddressFieldsFilled() && selectedTemple != null) {
      setState(() {
        selectedTemple = null;
        _showTempleDropdown = false;
      });
    }
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
      builder: (context, state) {
        final eventcubit = context.read<ContributeEventCubit>();
        return Form(
          key: eventcubit.eventAddressFormKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildLocationSearchDropdown(),
                // Gap(10.h),
                // _buildMapSection(),
                // Gap(20.h),
                if (!isChecked) _buildAddressFields(eventcubit),
                if (isChecked) _buildTempleSelection(),
                _buildFooter(eventcubit),
                Gap(20.h),
                _buildGuidelines(),
                Gap(20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationSearchDropdown() {
    return BlocBuilder<FeedHomeCubit, FeedHomeState>(
      bloc: _feedHomeCubit,
      builder: (context, feedState) {
        final locationLoading = feedState is FeedHomeLoaded ? feedState.locationLoading : false;
        final locationError = feedState is FeedHomeLoaded ? feedState.locationError : null;
        final locationResults = feedState is FeedHomeLoaded ? feedState.locationResults : [];

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: StringConstant.searchToAutofillAddressInformation,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: SvgPicture.asset(
                      "assets/icon/search_icon.svg",
                      height: 8.h,
                      width: 8.w,
                      color: const Color(0xff3C3C43),
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 20.sp),
                          onPressed: _clearLocation,
                        )
                      : Icon(Icons.keyboard_arrow_down,
                          size: 24.sp, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15.sp,
                    vertical: 12.sp,
                  ),
                ),
                onChanged: (val) {
                  print('DEBUG: Search input changed: $val');
                  setState(() {
                    _showLocationDropdown = val.trim().isNotEmpty;
                  });
                  if (val.trim().isNotEmpty) {
                    _feedHomeCubit.getLocationFromApi(val);
                  } else {
                    _feedHomeCubit.clearLocationResults();
                  }
                },
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    setState(() {
                      _showLocationDropdown = true;
                    });
                  }
                },
              ),
            ),
            if (_showLocationDropdown)
              Container(
                margin: EdgeInsets.only(top: 4.h),
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
                constraints: BoxConstraints(
                  maxHeight: 300.h,
                ),
                child: _buildLocationDropdownContent(locationLoading, locationError, locationResults),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLocationDropdownContent(bool locationLoading, String? locationError, List<dynamic> locationResults) {
    // Add debug prints
    print('DEBUG: locationLoading: $locationLoading');
    print('DEBUG: locationError: $locationError');
    print('DEBUG: locationResults: $locationResults');
    print('DEBUG: locationResults length: ${locationResults.length}');

    if (locationResults.isNotEmpty) {
      print('DEBUG: First result: ${locationResults[0]}');
    }
    if (locationLoading) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (locationError != null) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: Text(
          locationError,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Handle the response structure - the API response is wrapped in locationResults
    List<dynamic> predictions = [];

    if (locationResults.isNotEmpty) {
      final firstResult = locationResults[0];
      if (firstResult is Map<String, dynamic> && firstResult.containsKey('predictions')) {
        predictions = firstResult['predictions'] as List<dynamic>;
      }
    }

    if (predictions.isEmpty && _searchController.text.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            const Text(
              'No results found.',
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _onLocationSelected(_searchController.text.trim()),
                icon: const Icon(Icons.edit_location_alt),
                label: Text('Use "${_searchController.text.trim()}" as location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: predictions.length,
      itemBuilder: (context, index) {
        final place = predictions[index];

        if (place == null || place is! Map<String, dynamic>) {
          return const SizedBox.shrink();
        }

        // Extract location information from the API response
        String mainText = '';
        String secondaryText = '';
        String placeId = place['place_id']?.toString() ?? '';

        // Get structured formatting
        final structuredFormatting = place['structured_formatting'];
        if (structuredFormatting != null && structuredFormatting is Map<String, dynamic>) {
          mainText = structuredFormatting['main_text']?.toString() ?? '';
          secondaryText = structuredFormatting['secondary_text']?.toString() ?? '';
        }

        // Fallback to description if structured formatting is not available
        if (mainText.isEmpty) {
          final description = place['description']?.toString() ?? '';
          if (description.isNotEmpty) {
            final parts = description.split(',');
            mainText = parts[0].trim();
            if (parts.length > 1) {
              secondaryText = parts.sublist(1).join(',').trim();
            }
          }
        }

        // Skip if we couldn't extract any meaningful text
        if (mainText.isEmpty && secondaryText.isEmpty) {
          return const SizedBox.shrink();
        }

        return InkWell(
          onTap: () {
            // Use the full description for more complete location info
            final selectedLocation = place['description']?.toString() ?? mainText;

            // If you want to use place details API to get coordinates and full address:
            // You can call _parseAndFillAddress with place_id here
            if (placeId.isNotEmpty) {
              // Uncomment this if you want to parse full address details:
              // _parseAndFillAddress(selectedLocation, placeId);
            } else {
              _onLocationSelected(selectedLocation);
            }

            // For now, just select the location
            _onLocationSelected(selectedLocation);
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
                            ),
                      ),
                      if (place['structured_formatting']['secondary_text'] !=
                          null)
                        Text(
                          place['structured_formatting']['secondary_text'],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
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
                      _showLocationDropdown = false;
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
          StringConstant.tapMapToSelectLocationAndAutofillAddress,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildAddressFields(ContributeEventCubit eventcubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextfield(
          title: StringConstant.address,
          controller: eventcubit.streetAddressController,
          validator: eventcubit.streetAddressValidator,
          onChanged: (value) {
            setState(() {
              _showLocationDropdown = false;
            });
            _clearTempleIfAddressFilled();
            return null;
          },
        ),
        Gap(20.h),
        CommonTextfield(
          title: StringConstant.city,
          controller: eventcubit.cityController,
          validator: eventcubit.cityValidator,
          onChanged: (value) {
            setState(() {
              _showLocationDropdown = false;
            });
            _clearTempleIfAddressFilled();
            return null;
          },
        ),
        Gap(20.h),
        CommonTextfield(
          title: StringConstant.state,
          controller: eventcubit.stateController,
          validator: eventcubit.stateValidator,
          onChanged: (value) {
            setState(() {
              _showLocationDropdown = false;
            });
            _clearTempleIfAddressFilled();
            return null;
          },
        ),
        Gap(20.h),
        CommonTextfield(
          title: StringConstant.country,
          focusNode: _focusNodeCountry,
          controller: eventcubit.countryController,
          validator: eventcubit.countryValidator,
          onChanged: (value) {
            setState(() {
              _showLocationDropdown = false;
            });
            _clearTempleIfAddressFilled();
            return null;
          },
        ),
        Gap(20.h),
        CommonTextfield(
          title: StringConstant.pincode,
          focusNode: _focusNodeLandmark,
          controller: eventcubit.pincodeController,
          validator: eventcubit.landmarkValidator,
        ),
        Gap(30.h),
        _buildTempleSelection(),
      ],
    );
  }

  Widget _buildTempleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstant.eventHappeningTemple,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Gap(10.h),
        BlocBuilder<GodFormCubit, GodFormState>(
          builder: (context, state) {
            if (state is GodFormLoaded) {
              if (state.loadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage.isNotEmpty) {
                return Center(child: Text(state.errorMessage));
              }

              bool isDropdownDisabled = _areAddressFieldsFilled();

              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.boxColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.sp),
                    child: InkWell(
                      onTap: isDropdownDisabled
                          ? null
                          : () {
                              setState(() {
                                _showTempleDropdown = !_showTempleDropdown;
                              });
                            },
                      child: Opacity(
                        opacity: isDropdownDisabled ? 0.5 : 1.0,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.sp),
                                child: Text(
                                  selectedTemple?.title ??
                                      (isDropdownDisabled
                                          ? 'Disabled (Address fields filled)'
                                          : 'Select Temple'),
                                  style: TextStyle(
                                    color: selectedTemple != null
                                        ? Colors.black
                                        : AppColor.lightTextColor,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              _showTempleDropdown
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColor.lightTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap(10.h),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _showTempleDropdown && !isDropdownDisabled
                        ? Container(
                            height: 200.h,
                            margin: EdgeInsets.only(top: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: AppColor.boxColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.templeList?.length ?? 0,
                              itemBuilder: (context, index) {
                                final temple = state.templeList?[index];
                                final isSelected =
                                    selectedTemple?.id == temple?.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTemple = temple;
                                      _showTempleDropdown = false;
                                      _showLocationDropdown = false;
                                    });

                                    // Clear address fields when temple is selected
                                    if (temple != null) {
                                      final eventcubit =
                                          context.read<ContributeEventCubit>();
                                      eventcubit.streetAddressController
                                          .clear();
                                      eventcubit.cityController.clear();
                                      eventcubit.stateController.clear();
                                      eventcubit.countryController.clear();
                                      eventcubit.pincodeController.clear();
                                      eventcubit.googleLinkController.clear();
                                      setState(() {
                                        _selectedLocation = null;
                                        _markers.clear();
                                        _searchController.clear();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18.0.sp,
                                      vertical: 12.sp,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xffFDF2EE)
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            temple?.title ?? "",
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? AppColor.appbarBgColor
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildFooter(ContributeEventCubit eventcubit) {
    return CommonFooterText(
      onNextTap: () async {
        setState(() {
          _showTempleDropdown = false;
        });
        await eventcubit.updateEventAddress(
          widget.eventId ?? '',
          selectedTemple?.id.toString() ?? '',
          isValue.trim(),
        );
        widget.onNext();
      },
      onBackTap: widget.onBack,
    );
  }

  Widget _buildGuidelines() {
    return Guideline(
      title: StringConstant.guideline,
      points: [
        'Use the search dropdown to find and select locations',
        'Tap on the map to select location and autofill address fields',
        'Enable location services for better accuracy',
        'You can manually edit address fields after autofill',
        StringConstant.eventLocate,
        StringConstant.autoFIllAddress,
        StringConstant.editFields,
        StringConstant.eventLocateGuideline,
      ],
    );
  }
}
