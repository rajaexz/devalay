

import 'package:devalay_app/src/application/kirti/service/service_cubit.dart';
import 'package:devalay_app/src/application/kirti/service/service_state.dart';
import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/explore/widget/clear_apply_filter.dart';
import 'package:devalay_app/src/presentation/explore/widget/close_button_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/custom_divider_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/filter_header_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/list_filter_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/search_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdminAsignFilterWidget extends StatefulWidget {
  final AdminOrderDetailModel? order;
  const AdminAsignFilterWidget({super.key, this.order});

  @override
  State<AdminAsignFilterWidget> createState() => _AdminAsignFilterWidgetState();
}

class _AdminAsignFilterWidgetState extends State<AdminAsignFilterWidget> {
  late ServiceCubit serviceCubit;

  String? valueText;

  @override
  void initState() {
  serviceCubit = context.read<ServiceCubit>();
  serviceCubit.fetchFilterOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return   Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CloseButtonWidget(onTap: () => Navigator.pop(context)),
          Gap(10.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              border: Border.all(
                  color: Theme.of(context).colorScheme.secondary, width: 2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterHeaderWidget(title: StringConstant.filterAndSort),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          serviceCubit.filterTypes.length,
                          (index) => GestureDetector(
                            onTap: () => setState(() =>
                                serviceCubit.selectedFilter = index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Text(
                                serviceCubit.filterTypes[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: serviceCubit
                                                    .selectedFilter ==
                                                index
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const CustomVerticalDivider(),
                    Expanded(
                      child: _buildSelectedFilterContent(),
                    ),
                  ],
                ),
                const CustomDivider(),
                ClearApplyFilter(
                title: StringConstant.cleanFilter,
                  buttonText: StringConstant.applyFilter,
                  applyTap: () {
                  
                
                      context.read<ServiceCubit>().applyFilters(widget.order);
                      Navigator.pop(context);
                 
                  },
                  clearTap: () {
                    setState(() {
                      serviceCubit.selectedLocationIndex = null;
                 
                      serviceCubit.selectedSortByIndex = '';
                     
                      serviceCubit.selectedLocationFilterMap = {};

                      serviceCubit.searchLocationController.clear();
                      serviceCubit.searchDevController.clear();
                      serviceCubit.searchQuery = '';
                    });
                    debugPrint('Filters cleared');
                  },
                )
              ],
            ),
          ),
        ],
      );
  
  }
Widget _buildSelectedFilterContent() {
  switch (serviceCubit.selectedFilter) {
    // ✅ LOCATION FILTER
    case 0:
      return BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoadedState) {
            // ✅ Access locations from serviceCubit, not state
            final locations = serviceCubit.locationList ?? [];
            
            if (locations.isEmpty) {
              return const Center(
                child: Text('No locations available'),
              );
            }

            // ✅ Filter locations based on search
            final filteredLocations = locations.where((location) {
              final searchQuery = serviceCubit.searchLocationController.text.toLowerCase();
              if (searchQuery.isEmpty) {
                return true;
              }

              final title = location.title?.toLowerCase() ?? '';
              if (title.contains(searchQuery)) {
                return true;
              }

              final country = location.filter?.country?.toLowerCase() ?? '';
              final state = location.filter?.state?.toLowerCase() ?? '';
              final city = location.filter?.city?.toLowerCase() ?? '';

              return country.contains(searchQuery) ||
                  state.contains(searchQuery) ||
                  city.contains(searchQuery);
            }).toList();

            return SizedBox(
              height: 300.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
                child: Column(
                  children: [
                    // ✅ Search box
                    SearchBoxWidget(
                      textEditingController: serviceCubit.searchLocationController,
                      focusNode: serviceCubit.focusNode,
                      onChanged: (String value) {
                        setState(() {
                          valueText = value;
                          serviceCubit.searchQuery = value;
                        });
                        debugPrint('🔍 Search value: $value');
                      },
                      onTap: () {
                        setState(() {
                          if (valueText != null) {
                            serviceCubit.searchQuery = valueText!;
                          }
                        });
                      },
                      hintText: StringConstant.search,
                    ),
                    Gap(10.h),

                    // ✅ Location list
                    Expanded(
                      child: filteredLocations.isEmpty
                          ? const Center(child: Text('No locations found'))
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredLocations.length,
                              itemBuilder: (context, index) {
                                final location = filteredLocations[index];
                                final isLocationSelected =
                                    serviceCubit.selectedLocationIndex == location.title;

                                // ✅ Determine matched field
                                final searchQuery =
                                    serviceCubit.searchLocationController.text.toLowerCase();
                                String matchedField = "";
                                
                                if (searchQuery.isNotEmpty) {
                                  final title = location.title?.toLowerCase() ?? '';
                                  final country = location.filter?.country?.toLowerCase() ?? '';
                                  final state = location.filter?.state?.toLowerCase() ?? '';
                                  final city = location.filter?.city?.toLowerCase() ?? '';

                                  if (title.contains(searchQuery)) {
                                    matchedField = "title";
                                  } else if (country.contains(searchQuery)) {
                                    matchedField = "country";
                                  } else if (state.contains(searchQuery)) {
                                    matchedField = "state";
                                  } else if (city.contains(searchQuery)) {
                                    matchedField = "city";
                                  }
                                }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isLocationSelected) {
                                        // ✅ Deselect
                                        serviceCubit.selectedLocationIndex = null;
                                        serviceCubit.selectedLocationFilterMap = {};
                                      } else {
                                        // ✅ Select
                                        serviceCubit.selectedLocationIndex = location.title;
                                        serviceCubit.selectedLocationFilterMap =
                                            location.filter?.toJson() ?? {};
                                           
                                        debugPrint('✅ Selected Location: ${location.title}');
                                        debugPrint('📍 Filter Map: ${serviceCubit.selectedLocationFilterMap}');
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLocationSelected ? Icons.done_all : Icons.done,
                                        color: isLocationSelected
                                            ? accentColor
                                            : AppColor.lightTextColor,
                                        size: 18.sp,
                                      ),
                                      Gap(10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              location.title ?? '',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                            if (matchedField.isNotEmpty &&
                                                matchedField != "title")
                                              Text(
                                                "Matched: ${matchedField.toUpperCase()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: accentColor,
                                                      fontSize: 10.sp,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Gap(10.h),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // ✅ Loading state
          return const Center(child: CircularProgressIndicator());
        },
      );

    // ✅ SORT BY FILTER
    case 1:
      return SizedBox(
        height: 300.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          child: ShortListFilterWidget(
            items: serviceCubit.sortBy,
            selectedItem: serviceCubit.selectedSortByIndex,
            onItemSelected: (value) =>
                setState(() => serviceCubit.selectedSortByIndex = value),
          ),
        ),
      );

  
    default:
      return const SizedBox.shrink();
  }
}}
