import 'package:devalay_app/src/application/globle_search/temple/temple_search_cubit.dart';
import 'package:devalay_app/src/application/globle_search/temple/temple_search_state.dart';
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
  final void Function(String filterQuery)? onApply;
  const TempleFilterWidget({super.key, this.onApply});

  @override
  State<TempleFilterWidget> createState() => _TempleFilterWidgetState();
}

class _TempleFilterWidgetState extends State<TempleFilterWidget> {
  late TempleSearchICubit templeSearchICubit;

  String? valueText;

  @override
  void initState() {
    templeSearchICubit = context.read<TempleSearchICubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TempleSearchICubit()..fetchTempleFilterData(),
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
                          templeSearchICubit.filterTypes.length,
                          (index) => GestureDetector(
                            onTap: () => setState(() =>
                                templeSearchICubit.selectedFilter = index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Text(
                                templeSearchICubit.filterTypes[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: templeSearchICubit
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
                    final String filterQuery =
                        context.read<TempleSearchICubit>() .buildFilterQuery();
                    debugPrint('${StringConstant.filterGuery}: $filterQuery');

                    if (widget.onApply != null) {
                      widget.onApply!(filterQuery);
                    } else {
                      final templeSearchICubit =
                          BlocProvider.of<TempleSearchICubit>(context);
                      templeSearchICubit.applyFilters(filterQuery);
                      Navigator.pop(context);
                    }
                  },
                  clearTap: () {
                    setState(() {
                      templeSearchICubit.selectedLocationIndex = null;
                      templeSearchICubit.selectedDevIndex = null;
                      templeSearchICubit.selectedSortByIndex = '';
                      templeSearchICubit.selectedOrderByIndex = 'Decending';
                      templeSearchICubit.selectedLocationFilterMap = {};
                      templeSearchICubit.selectedDevFilterMap = {};
                      templeSearchICubit.searchLocationController.clear();
                      templeSearchICubit.searchDevController.clear();
                      templeSearchICubit.searchQuery = '';
                    });
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
    switch (templeSearchICubit.selectedFilter) {
      case 0:
        return BlocBuilder<TempleSearchICubit, TempleSearchState>(
          builder: (context, state) {
            if (state is TempleSearchLoaded) {
              if (state.templeFilterModel != null) {
                final filteredLocations =
                    state.templeFilterModel!.location!.where(
                  (location) {
                    final searchQuery = templeSearchICubit
                        .searchLocationController.text
                        .toLowerCase();
                    if (searchQuery.isEmpty) {
                      return true; // Show all when no search query
                    }

                    // Search in title
                    final title = location.title?.toLowerCase() ?? '';
                    if (title.contains(searchQuery)) {
                      return true;
                    }

                    // Search in location details (country, state, city)
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
                              templeSearchICubit.searchLocationController,
                          focusNode: templeSearchICubit.focusNode,
                          onChanged: (String value) {
                            setState(() {
                              valueText = value;
                              templeSearchICubit.searchQuery = value;
                            });
                            debugPrint('Search value: $value');
                          },
                          onTap: () {
                            setState(() {
                              templeSearchICubit.searchQuery = valueText!;
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
                                  templeSearchICubit.selectedLocationIndex ==
                                      location.title;

                              // Find which field matched
                              final searchQuery = templeSearchICubit
                                  .searchLocationController.text
                                  .toLowerCase();
                              String matchedField = "";
                              if (searchQuery.isNotEmpty) {
                                final title =
                                    location.title?.toLowerCase() ?? '';
                                final country =
                                    location.filter?.country?.toLowerCase() ??
                                        '';
                                final state =
                                    location.filter?.state?.toLowerCase() ?? '';
                                final city =
                                    location.filter?.city?.toLowerCase() ?? '';

                                if (title.contains(searchQuery))
                                  matchedField = "title";
                                else if (country.contains(searchQuery))
                                  matchedField = "country";
                                else if (state.contains(searchQuery))
                                  matchedField = "state";
                                else if (city.contains(searchQuery))
                                  matchedField = "city";
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    templeSearchICubit.selectedLocationIndex =
                                        isLocationSelected
                                            ? null
                                            : location.title;
                                    templeSearchICubit
                                            .selectedLocationFilterMap =
                                        location.filter?.toJson() ?? {};
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isLocationSelected ? Icons.done_all : Icons.done,
                                      color: isLocationSelected ? accentColor : AppColor.lightTextColor,
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
                                              StringConstant.matchedField(matchedField),
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
        return BlocBuilder<TempleSearchICubit, TempleSearchState>(
          builder: (context, state) {
            if (state is TempleSearchLoaded) {
              if (state.templeFilterModel != null) {
                final filteredDev = state.templeFilterModel!.dev!.where(
                  (dev) {
                    final searchQuery = templeSearchICubit
                        .searchDevController.text
                        .toLowerCase();
                    if (searchQuery.isEmpty) {
                      return true; // Show all when no search query
                    }

                    // Search in title
                    final title = dev.title?.toLowerCase() ?? '';
                    if (title.contains(searchQuery)) {
                      return true;
                    }

                    // Search in dev details
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
                                templeSearchICubit.searchDevController,
                            focusNode: templeSearchICubit.focusNode,
                            onChanged: (String value) {
                              setState(() {
                                templeSearchICubit.searchQuery = value;
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
                            // Replace your current itemBuilder in the Dev section (case 1) with this:

                            itemBuilder: (context, index) {
                              final dev = filteredDev[index];
                              final isDevSelected =
                                  templeSearchICubit.selectedDevIndex ==
                                      dev.title;

                              // Find which field matched
                              final searchQuery = templeSearchICubit
                                  .searchDevController.text
                                  .toLowerCase();
                              String matchedField = "";
                              if (searchQuery.isNotEmpty) {
                                final title = dev.title?.toLowerCase() ?? '';
                                final devValue =
                                    dev.filter?.dev?.toLowerCase() ?? '';

                                if (title.contains(searchQuery))
                                  matchedField = "title";
                                else if (devValue.contains(searchQuery))
                                  matchedField = "dev";

                                if (matchedField.isNotEmpty) {
                                  debugPrint(
                                      'Match found in $matchedField for dev: ${dev.title}');
                                }
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    templeSearchICubit.selectedDevIndex =
                                        isDevSelected ? null : dev.title;
                                    templeSearchICubit.selectedDevFilterMap =
                                        dev.filter?.toJson() ?? {};
                                  });
                                  debugPrint(
                                      'Selected dev index: ${templeSearchICubit.selectedDevIndex}');
                                  debugPrint(
                                      'Selected dev title: ${dev.title}');
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
                                              StringConstant.matchedField(matchedField),
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
                items: templeSearchICubit.sortBy,
                selectedItem: templeSearchICubit.selectedSortByIndex,
                onItemSelected: (value) => setState(
                    () => templeSearchICubit.selectedSortByIndex = value),
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
                  itemCount: templeSearchICubit.orderBy.length,
                  itemBuilder: (context, index) {
                    final item = templeSearchICubit.orderBy[index];
                    final isOrderBySelected =
                        templeSearchICubit.selectedOrderByIndex ==
                            item['title'];
                    return InkWell(
                      onTap: () {
                        debugPrint(
                            'Selected index order by: ${templeSearchICubit.selectedOrderByIndex}');
                        debugPrint('Selected title order by: ${item['title']}');
                        setState(() {
                          templeSearchICubit.selectedOrderByIndex =
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
