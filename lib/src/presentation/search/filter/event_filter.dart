import 'package:devalay_app/src/application/explore/explore_event/explore_event_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_event/explore_event_state.dart';
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
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';

class EventFilterWidget extends StatefulWidget {
  const EventFilterWidget({super.key});

  @override
  State<EventFilterWidget> createState() => _EventFilterWidgetState();
}

class _EventFilterWidgetState extends State<EventFilterWidget> {
  late ExploreEventCubit filterCubit;
  String? valueText;

  @override
  void initState() {
    super.initState();
    // Create new cubit instance for filter
    filterCubit = ExploreEventCubit()..fetchEventFilterData();
    filterCubit.selectedDay = filterCubit.focusedDay;
    filterCubit.dateController.text = StringConstant.noDataAvailable;
  }

  @override
  void dispose() {
    filterCubit.close();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(filterCubit.selectedDay, selectedDay)) {
      setState(() {
        filterCubit.selectedDay = selectedDay;
        filterCubit.focusedDay = focusedDay;
        filterCubit.dateController.text = _formatDate(selectedDay);
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      filterCubit.selectedDay = null;
      filterCubit.focusedDay = focusedDay;
      filterCubit.rangeStart = start;
      filterCubit.rangeEnd = end;

      if (start != null && end != null) {
        filterCubit.dateController.text =
            "${_formatDate(start)} - ${_formatDate(end)}";
      } else if (start != null) {
        filterCubit.dateController.text = _formatDate(start);
      } else {
        filterCubit.dateController.text = StringConstant.noDataAvailable;
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String buildFilterQuery() {
    final List<String> queryParams = [];

    // Location filter
    if (filterCubit.selectedLocationFilterMap.isNotEmpty) {
      final city = filterCubit.selectedLocationFilterMap['city'];
      final state = filterCubit.selectedLocationFilterMap['state'];
      final country = filterCubit.selectedLocationFilterMap['country'];

      debugPrint('Selected Location Map: ${filterCubit.selectedLocationFilterMap}');
      debugPrint('City: $city, State: $state, Country: $country');

      if (city != null && city.toString().isNotEmpty) {
        queryParams.add('&city=${Uri.encodeComponent(city.toString())}');
      }
      if (state != null && state.toString().isNotEmpty) {
        queryParams.add('&state=${Uri.encodeComponent(state.toString())}');
      }
      if (country != null && country.toString().isNotEmpty) {
        queryParams.add('&country=${Uri.encodeComponent(country.toString())}');
      }
    }

    // Date range filter
    if (filterCubit.rangeStart != null && filterCubit.rangeEnd != null) {
      final start = DateFormat('yyyy-MM-dd').format(filterCubit.rangeStart!);
      final end = DateFormat('yyyy-MM-dd').format(filterCubit.rangeEnd!);
      queryParams.add('&start_date=$start');
      queryParams.add('&end_date=$end');
      
      debugPrint('Date Range: $start to $end');
    }

    // Dev filter
    if (filterCubit.selectedDevFilterMap.isNotEmpty) {
      final devId = filterCubit.selectedDevFilterMap['id'];
      debugPrint('Selected Dev Map: ${filterCubit.selectedDevFilterMap}');
      debugPrint('Dev ID: $devId');
      
      if (devId != null && devId.toString().isNotEmpty) {
        queryParams.add('&dev=${Uri.encodeComponent(devId.toString())}');
      }
    }

    // Sort by filter
    if (filterCubit.selectedSortByIndex != null && 
        filterCubit.selectedSortByIndex!.isNotEmpty) {
      String sortBy = filterCubit.selectedSortByIndex!.toLowerCase();
      if (sortBy == 'added date') sortBy = 'recent';
      if (sortBy == 'alphabetically') sortBy = 'alphabetically';
      queryParams.add('&sort_by=$sortBy');
    }

    // Order by filter
    if (filterCubit.selectedOrderByIndex != null && 
        filterCubit.selectedOrderByIndex!.isNotEmpty) {
      String orderBy = filterCubit.selectedOrderByIndex == 'Ascending'
          ? 'asce'
          : 'desc';
      queryParams.add('&order_by=$orderBy');
    }

    final result = queryParams.isEmpty ? '' : queryParams.join('');
    debugPrint('Final Filter Query: $result');
    return result;
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
                  color: Theme.of(context).colorScheme.background, width: 2.w),
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
                            onTap: () =>
                                setState(() => filterCubit.selectedFilter = index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Text(filterCubit.filterTypes[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: filterCubit.selectedFilter == index
                                              ? accentColor
                                              : (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? AppColor.whiteColor
                                                  : AppColor.blackColor))),
                            ),
                          ),
                        ),
                      ),
                    ),
                    CustomVerticalDivider(height: 350.h),
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
                    debugPrint('=== EVENT FILTER DEBUG ===');
                    debugPrint('Selected Location Index: ${filterCubit.selectedLocationIndex}');
                    debugPrint('Location Filter Map: ${filterCubit.selectedLocationFilterMap}');
                    debugPrint('Selected Dev Index: ${filterCubit.selectedDevIndex}');
                    debugPrint('Dev Filter Map: ${filterCubit.selectedDevFilterMap}');
                    debugPrint('Date Range Start: ${filterCubit.rangeStart}');
                    debugPrint('Date Range End: ${filterCubit.rangeEnd}');
                    debugPrint('Sort By: ${filterCubit.selectedSortByIndex}');
                    debugPrint('Order By: ${filterCubit.selectedOrderByIndex}');

                    final String filterQuery = buildFilterQuery();
                    debugPrint('Final Filter Query: $filterQuery');
                    debugPrint('========================');

                    // Use GobelSearchCubit for consistent API calls
                    context
                        .read<GobelSearchCubit>()
                        .applyFilters(filterQuery, 'Event');

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
                      filterCubit.rangeEnd = null;
                      filterCubit.rangeStart = null;
                      filterCubit.dateController.text =
                          StringConstant.noDataAvailable;
                    });

                    // Clear filters and reload data
                    context.read<GobelSearchCubit>().applyFilters('', 'Event');

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
        return BlocBuilder<ExploreEventCubit, ExploreEventState>(
          builder: (context, state) {
            if (state is ExploreEventLoaded) {
              if (state.eventFilter != null) {
                final filteredLocations = state.eventFilter!.location!.where(
                  (location) {
                    final searchQuery = filterCubit
                        .searchLocationController.text
                        .toLowerCase();
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
                                      filterCubit.selectedLocationIndex =
                                          location.title;
                                      filterCubit.selectedLocationFilterMap =
                                          location.filter?.toJson() ?? {};

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
        return BlocBuilder<ExploreEventCubit, ExploreEventState>(
          builder: (context, state) {
            if (state is ExploreEventLoaded) {
              if (state.eventFilter != null) {
                return SizedBox(
                  height: 350.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 40.h,
                          child: TextField(
                            controller: filterCubit.dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Select date range',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 10.w),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide:
                                    const BorderSide(color: AppColor.greyColor),
                              ),
                              suffixIcon: const Icon(
                                Icons.date_range,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),
                        Gap(10.h),
                        TableCalendar(
                          focusedDay: filterCubit.focusedDay,
                          firstDay: DateTime.utc(2010, 3, 14),
                          lastDay: DateTime.utc(2030, 3, 14),
                          calendarFormat: filterCubit.calendarFormat,
                          rangeStartDay: filterCubit.rangeStart,
                          rangeSelectionMode: RangeSelectionMode.toggledOn,
                          rangeEndDay: filterCubit.rangeEnd,
                          onRangeSelected: _onRangeSelected,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left, size: 20),
                            rightChevronIcon:
                                Icon(Icons.chevron_right, size: 20),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            cellMargin: EdgeInsets.all(1.sp),
                            defaultTextStyle: const TextStyle(fontSize: 12),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                                color:
                                    const Color(0xffFF9500).withOpacity(0.88)),
                            weekendStyle: TextStyle(
                                color:
                                    const Color(0xffFF9500).withOpacity(0.88)),
                          ),
                          rowHeight: 25,
                          selectedDayPredicate: (day) =>
                              isSameDay(filterCubit.selectedDay, day),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          onDaySelected: _onDaySelected,
                          onPageChanged: (focusedDay) {
                            filterCubit.focusedDay = focusedDay;
                          },
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
                            'Selected order by: ${item['title']}');
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
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
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