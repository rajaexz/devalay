import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_state.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';

class TempleFilterWidget extends StatefulWidget {
  const TempleFilterWidget({super.key});

  @override
  State<TempleFilterWidget> createState() => _TempleFilterWidgetState();
}

class _TempleFilterWidgetState extends State<TempleFilterWidget> {
  String? valueText;
  late ExploreDevalayCubit filterCubit;

  @override
  void initState() {
    super.initState();
    // Create cubit instance once in initState
    filterCubit = ExploreDevalayCubit()..fetchTempleFilterData();
  }

  @override
  void dispose() {
    filterCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: filterCubit,
      child: Column(
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
                          filterCubit.filterTypes.length,
                          (index) => GestureDetector(
                            onTap: () => setState(() => filterCubit.selectedFilter = index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Text(
                                filterCubit.filterTypes[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: filterCubit.selectedFilter == index
                                            ? Theme.of(context).colorScheme.primary
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
                    // Debug prints
                    debugPrint('=== FILTER DEBUG ===');
                    debugPrint('Selected Location Index: ${filterCubit.selectedLocationIndex}');
                    debugPrint('Location Filter Map: ${filterCubit.selectedLocationFilterMap}');
                    debugPrint('Selected Dev Index: ${filterCubit.selectedDevIndex}');
                    debugPrint('Dev Filter Map: ${filterCubit.selectedDevFilterMap}');
                    debugPrint('Sort By: ${filterCubit.selectedSortByIndex}');
                    debugPrint('Order By: ${filterCubit.selectedOrderByIndex}');

                    final String filterQuery = filterCubit.buildFilterQuery();
                    debugPrint('Final Filter Query: $filterQuery');
                    debugPrint('===================');

                    // Use GobelSearchCubit for consistent API calls
                    context.read<GobelSearchCubit>().applyFilters(filterQuery, 'Temple');

                    Navigator.pop(context);
                  },
                  clearTap: () {
                    setState(() {
                      filterCubit.selectedLocationIndex = null;
                      filterCubit.selectedDevIndex = null;
                      filterCubit.selectedSortByIndex = '';
                      filterCubit.selectedOrderByIndex = 'Descending';
                      filterCubit.selectedLocationFilterMap = {};
                      filterCubit.selectedDevFilterMap = {};
                      filterCubit.searchLocationController.clear();
                      filterCubit.searchDevController.clear();
                      filterCubit.searchQuery = '';
                    });

                    // Clear filters and reload data
                    context.read<GobelSearchCubit>().applyFilters('', 'Temple');

                    debugPrint('Filters cleared');
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilterContent() {
    switch (filterCubit.selectedFilter) {
      case 0:
        return BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
          builder: (context, state) {
            if (state is ExploreDevalayLoaded) {
              if (state.templeFilterModel != null) {
                final filteredLocations =
                    state.templeFilterModel!.location!.where(
                  (location) {
                    final searchQuery =
                        filterCubit.searchLocationController.text.toLowerCase();
                    if (searchQuery.isEmpty) {
                      return true;
                    }

                    final title = location.title?.toLowerCase() ?? '';
                    if (title.contains(searchQuery)) {
                      return true;
                    }

                    final country =
                        location.filter?.country?.toLowerCase() ?? '';
                    final state = location.filter?.state?.toLowerCase() ?? '';
                    final city = location.filter?.city?.toLowerCase() ?? '';

                    return country.contains(searchQuery) ||
                        state.contains(searchQuery) ||
                        city.contains(searchQuery);
                  },
                ).toList();

                return SizedBox(
                  height: 300.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    child: Column(
                      children: [
                        SearchBoxWidget(
                          textEditingController:
                              filterCubit.searchLocationController,
                          focusNode: filterCubit.focusNode,
                          onChanged: (String value) {
                            setState(() {
                              valueText = value;
                              filterCubit.searchQuery = value;
                            });
                            debugPrint('Search value: $value');
                          },
                          onTap: () {
                            setState(() {
                              if (valueText != null) {
                                filterCubit.searchQuery = valueText!;
                              }
                            });
                          },
                          hintText: StringConstant.search,
                        ),
                        Gap(10.h),
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredLocations.length,
                            itemBuilder: (context, index) {
                              final location = filteredLocations[index];
                              final isLocationSelected =
                                  filterCubit.selectedLocationIndex ==
                                      location.title;

                              final searchQuery = filterCubit
                                  .searchLocationController.text
                                  .toLowerCase();
                              String matchedField = "";
                              if (searchQuery.isNotEmpty) {
                                final title = location.title?.toLowerCase() ?? '';
                                final country =
                                    location.filter?.country?.toLowerCase() ?? '';
                                final state =
                                    location.filter?.state?.toLowerCase() ?? '';
                                final city =
                                    location.filter?.city?.toLowerCase() ?? '';

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
                                      // Deselect
                                      filterCubit.selectedLocationIndex = null;
                                      filterCubit.selectedLocationFilterMap = {};
                                    } else {
                                      // Select
                                      filterCubit.selectedLocationIndex = location.title;
                                      filterCubit.selectedLocationFilterMap =
                                          location.filter?.toJson() ?? {};
                                      
                                      // Debug print
                                      debugPrint('Selected Location: ${location.title}');
                                      debugPrint('Filter Map: ${filterCubit.selectedLocationFilterMap}');
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isLocationSelected
                                          ? Icons.done_all
                                          : Icons.done,
                                      color: isLocationSelected
                                          ? accentColor
                                          : AppColor.lightTextColor,
                                      size: 18.sp,
                                    ),
                                    Gap(10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            location.title ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
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
                            separatorBuilder: (context, index) {
                              return Gap(10.h);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return const Center(child: CustomLottieLoader());
          },
        );

      case 1:
        return BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
          builder: (context, state) {
            if (state is ExploreDevalayLoaded) {
              if (state.templeFilterModel != null) {
                final filteredDev = state.templeFilterModel!.dev!.where(
                  (dev) {
                    final searchQuery =
                        filterCubit.searchDevController.text.toLowerCase();
                    if (searchQuery.isEmpty) {
                      return true;
                    }

                    final title = dev.title?.toLowerCase() ?? '';
                    if (title.contains(searchQuery)) {
                      return true;
                    }

                    final devValue = dev.filter?.dev?.toLowerCase() ?? '';
                    return devValue.contains(searchQuery);
                  },
                ).toList();

                return SizedBox(
                  height: 300.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    child: Column(
                      children: [
                        SearchBoxWidget(
                            textEditingController:
                                filterCubit.searchDevController,
                            focusNode: filterCubit.focusNode,
                            onChanged: (String value) {
                              setState(() {
                                filterCubit.searchQuery = value;
                              });
                              debugPrint('Search value: $value');
                            },
                            onTap: () {},
                            hintText: StringConstant.search),
                        Gap(10.h),
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredDev.length,
                            itemBuilder: (context, index) {
                              final dev = filteredDev[index];
                              final isDevSelected =
                                  filterCubit.selectedDevIndex == dev.title;

                              final searchQuery = filterCubit
                                  .searchDevController.text
                                  .toLowerCase();
                              String matchedField = "";
                              if (searchQuery.isNotEmpty) {
                                final title = dev.title?.toLowerCase() ?? '';
                                final devValue =
                                    dev.filter?.dev?.toLowerCase() ?? '';

                                if (title.contains(searchQuery)) {
                                  matchedField = "title";
                                } else if (devValue.contains(searchQuery)) {
                                  matchedField = "dev";
                                }

                                if (matchedField.isNotEmpty) {
                                  debugPrint(
                                      'Match found in $matchedField for dev: ${dev.title}');
                                }
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isDevSelected) {
                                      filterCubit.selectedDevIndex = null;
                                      filterCubit.selectedDevFilterMap = {};
                                    } else {
                                      filterCubit.selectedDevIndex = dev.title;
                                      filterCubit.selectedDevFilterMap =
                                          dev.filter?.toJson() ?? {};
                                      
                                      debugPrint('Selected Dev: ${dev.title}');
                                      debugPrint('Dev Filter Map: ${filterCubit.selectedDevFilterMap}');
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isDevSelected
                                          ? Icons.done_all
                                          : Icons.done,
                                      color: isDevSelected
                                          ? accentColor
                                          : AppColor.lightTextColor,
                                      size: 18.sp,
                                    ),
                                    Gap(10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dev.title ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
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
                            separatorBuilder: (context, index) {
                              return Gap(10.h);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return const Center(child: CustomLottieLoader());
          },
        );

      case 2:
        return SizedBox(
            height: 300.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: ShortListFilterWidget(
                items: filterCubit.sortBy,
                selectedItem: filterCubit.selectedSortByIndex,
                onItemSelected: (value) =>
                    setState(() => filterCubit.selectedSortByIndex = value),
              ),
            ));

      case 3:
        return SizedBox(
          height: 300.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: filterCubit.orderBy.length,
                  itemBuilder: (context, index) {
                    final item = filterCubit.orderBy[index];
                    final isOrderBySelected =
                        filterCubit.selectedOrderByIndex == item['title'];
                    return InkWell(
                      onTap: () {
                        debugPrint(
                            'Selected index order by: ${filterCubit.selectedOrderByIndex}');
                        debugPrint('Selected title order by: ${item['title']}');
                        setState(() {
                          filterCubit.selectedOrderByIndex =
                              isOrderBySelected ? null : item['title'];
                        });
                      },
                      child: Row(
                        children: [
                          SvgPicture.network(item['icon'],
                              color: isOrderBySelected
                                  ? accentColor
                                  : AppColor.lightTextColor,
                              height: 16.h,
                              width: 16.w),
                          Gap(10.w),
                          Expanded(
                              child: Text(item['title'],
                                  style:
                                      Theme.of(context).textTheme.bodyMedium)),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Gap(10.h);
                  },
                )
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}