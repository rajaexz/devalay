import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class LocationSearchSheet extends StatefulWidget {
  final String selectedLocation;
  final Function(String) onLoactionSelected;

  const LocationSearchSheet({
    super.key,
    required this.selectedLocation,
    required this.onLoactionSelected,
  });

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  late FeedHomeCubit feedHomeCubit;

  @override
  void initState() {
    super.initState();
    feedHomeCubit = context.read<FeedHomeCubit>();
    _controller.text = widget.selectedLocation;
  }

  void _useManualLocation() {
    if (_controller.text.trim().isNotEmpty) {
      // Call callback first to update the field
      widget.onLoactionSelected(_controller.text.trim());
      // Then close the sheet
      Future.microtask(() => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedHomeCubit, FeedHomeState>(
      bloc: feedHomeCubit,
      builder: (context, state) {
        // Correctly extract the location-specific state variables
        final locationLoading = state is FeedHomeLoaded ? state.locationLoading : false;
        final locationError = state is FeedHomeLoaded ? state.locationError : null;
        final locationResults = state is FeedHomeLoaded ? state.locationResults : [];

        return Container(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 10.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                  Gap(12.w),
                  Text(
                    StringConstant.selectLocation,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              SizedBox(
                height: 40.h,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: StringConstant.searchLocation,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                    suffixIcon: _controller.text.trim().isNotEmpty
                        ? IconButton(
                            onPressed: _useManualLocation,
                            icon: const Icon(Icons.check, color: Colors.black),
                          )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {}); // Rebuild to show/hide suffixIcon
                    if (val.trim().isNotEmpty) {
                      feedHomeCubit.getLocationFromGoogleApi(val);
                    } else {
                      feedHomeCubit.clearLocationResults();
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (locationLoading)
                const Center(child: CircularProgressIndicator())
              else if (locationError != null)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(locationError, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                )
              else if (locationResults.isEmpty && _controller.text.trim().isNotEmpty)
                Column(
                  children: [
                     Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(StringConstant.noResultsFound),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _useManualLocation,
                        icon: const Icon(Icons.edit_location_alt),
                        label: Text(StringConstant.useAsLocation(_controller.text.trim())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                )
              else if (locationResults.isNotEmpty)
                Flexible(
                  child: _buildLocationList(),
                ),
            ],
          ),
        );
      },
    );
  }
Widget _buildLocationList() {
    // Get current state from the cubit
    final currentState = feedHomeCubit.state;
    final locationResults = (currentState is FeedHomeLoaded) 
        ? currentState.locationResults 
        : <dynamic>[];
    
    // Handle the response structure correctly
    List<dynamic> predictions = [];
    
    if (locationResults.isNotEmpty) {
      final firstResult = locationResults[0];
      if (firstResult is Map<String, dynamic> && firstResult.containsKey('predictions')) {
        predictions = firstResult['predictions'] as List<dynamic>;
      } else if (firstResult is List) {
        predictions = firstResult;
      }
    }
    
    if (predictions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(StringConstant.noLocationsFound),
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
        
        // Extract location information safely
        String mainText = '';
        String secondaryText = '';
        
        // Try to get structured formatting first
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
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            mainText.isNotEmpty ? mainText : StringConstant.unknownLocation,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: secondaryText.isNotEmpty 
              ? Text(
                  secondaryText,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
                  ),
                )
              : null,
          leading: Icon(
            Icons.location_on,
            color: Colors.grey.shade600,
            size: 20.sp,
          ),
          onTap: () {
            // Use full description (complete address) instead of just main text
            final description = place['description']?.toString() ?? '';
            final selectedLocation = description.isNotEmpty 
                ? description 
                : (mainText.isNotEmpty ? mainText : StringConstant.unknownLocation);
            
            // Call callback first to update the field
            widget.onLoactionSelected(selectedLocation);
            // Then close the sheet
            Future.microtask(() => Navigator.pop(context));
          },
        );
      },
    );
  }
}