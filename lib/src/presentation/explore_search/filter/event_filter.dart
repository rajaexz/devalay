import 'package:devalay_app/src/application/explore/explore_event/explore_event_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_event/explore_event_state.dart';
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
  late ExploreEventCubit exploreEventCubit;
  String? valueText;
  @override
  void initState() {
    super.initState();
    exploreEventCubit = context.read<ExploreEventCubit>();
    exploreEventCubit.selectedDay = exploreEventCubit.focusedDay;
    exploreEventCubit.dateController.text = StringConstant.noDataAvailable;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(exploreEventCubit.selectedDay, selectedDay)) {
      setState(() {
        exploreEventCubit.selectedDay = selectedDay;
        exploreEventCubit.focusedDay = focusedDay;
        exploreEventCubit.dateController.text = _formatDate(selectedDay);
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      exploreEventCubit.selectedDay = null;
      exploreEventCubit.focusedDay = focusedDay;
      exploreEventCubit.rangeStart = start;
      exploreEventCubit.rangeEnd = end;

      if (start != null && end != null) {
        exploreEventCubit.dateController.text =
            "${_formatDate(start)} - ${_formatDate(end)}";
      } else if (start != null) {
        exploreEventCubit.dateController.text = _formatDate(start);
      } else {
        exploreEventCubit.dateController.text = StringConstant.noDataAvailable;
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String buildFilterQuery() {
    final List<String> queryParams = [];

    if (exploreEventCubit.selectedLocationIndex != null &&
        exploreEventCubit.selectedLocationFilterMap.isNotEmpty) {
      final city = exploreEventCubit.selectedLocationFilterMap['city'];
      final state = exploreEventCubit.selectedLocationFilterMap['state'];
      final country = exploreEventCubit.selectedLocationFilterMap['country'];

      if (city != null) queryParams.add('&city=$city');
      if (state != null) queryParams.add('&state=$state');
      if (country != null) queryParams.add('&country=$country');
    }

    if (exploreEventCubit.rangeStart != null &&
        exploreEventCubit.rangeEnd != null) {
      final start =
          DateFormat('yyyy-MM-dd').format(exploreEventCubit.rangeStart!);
      final end = DateFormat('yyyy-MM-dd').format(exploreEventCubit.rangeEnd!);
      queryParams.add('&start_date=$start');
      queryParams.add('&end_date=$end');
    } else {
      queryParams.add('');
      queryParams.add('');
    }

    if (exploreEventCubit.selectedDevIndex != null &&
        exploreEventCubit.selectedDevFilterMap.isNotEmpty) {
      final devId = exploreEventCubit.selectedDevFilterMap['id'];
      if (devId != null) queryParams.add('&dev=$devId');
    }

    if (exploreEventCubit.selectedSortByIndex != null) {
      String sortBy = exploreEventCubit.selectedSortByIndex!.toLowerCase();

      if (sortBy == 'added date') sortBy = 'recent';

      if (sortBy == 'alphabetically') sortBy = 'alphabetically';

      queryParams.add('&sort_by=$sortBy');
    }

    if (exploreEventCubit.selectedOrderByIndex != null) {
      String orderBy = exploreEventCubit.selectedOrderByIndex == 'Ascending'
          ? 'asce'
          : 'desc';
      queryParams.add('&order_by=$orderBy');
    }

    return queryParams.isEmpty ? '' : queryParams.join('');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreEventCubit()..fetchEventFilterData(),
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
                          exploreEventCubit.filterTypes.length,
                          (index) => GestureDetector(
                            onTap: () => setState(
                                () => exploreEventCubit.selectedFilter = index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Text(exploreEventCubit.filterTypes[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: exploreEventCubit
                                                      .selectedFilter ==
                                                  index
                                              ? accentColor
                                              : (Theme.of(context).brightness == Brightness.dark ? AppColor.whiteColor:AppColor.blackColor))),
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
                    final String filterQuery = buildFilterQuery();
                    debugPrint('${StringConstant.filterGuery}: $filterQuery');

                    final explorerCubit =
                        BlocProvider.of<ExploreEventCubit>(context);
                    explorerCubit.applyFilters(filterQuery);

                    Navigator.pop(context);
                  },
                  clearTap: () {
                    setState(() {
                      exploreEventCubit.selectedLocationIndex = null;
                      exploreEventCubit.selectedDevIndex = null;
                      exploreEventCubit.selectedSortByIndex = '';
                      exploreEventCubit.selectedOrderByIndex = 'Decending';
                      exploreEventCubit.selectedLocationFilterMap = {};
                      exploreEventCubit.selectedDevFilterMap = {};
                      exploreEventCubit.searchLocationController.clear();
                      exploreEventCubit.rangeEnd = null;
                      exploreEventCubit.rangeStart = null;
                      exploreEventCubit.dateController.text =
                          StringConstant.noDataAvailable;
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
    switch (exploreEventCubit.selectedFilter) {
      case 0:
        return BlocBuilder<ExploreEventCubit, ExploreEventState>(
          builder: (context, state) {
            if (state is ExploreEventLoaded) {
              if (state.eventFilter != null) {
                final filteredLocations = state.eventFilter!.location!.where(
                  (location) {
                    final searchQuery = exploreEventCubit
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
                              exploreEventCubit.searchLocationController,
                          focusNode: exploreEventCubit.focusNode,
                          onChanged: (String value) {
                            setState(() {
                              valueText = value;
                              exploreEventCubit.searchQuery = value;
                            });
                            debugPrint('Search value: $value');
                          },
                          onTap: () {
                            setState(() {
                              exploreEventCubit.searchQuery = valueText!;
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
                                  exploreEventCubit.selectedLocationIndex ==
                                      location.title;

                              // Find which field matched
                              final searchQuery = exploreEventCubit
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
                                    exploreEventCubit.selectedLocationIndex =
                                        isLocationSelected
                                            ? null
                                            : location.title;
                                    exploreEventCubit
                                            .selectedLocationFilterMap =
                                        location.filter?.toJson() ?? {};
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
                            controller: exploreEventCubit.dateController,
                            focusNode: FocusNode(),
                            decoration: InputDecoration(
                              hintText: StringConstant.selectDate,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 10.w),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide:
                                    const BorderSide(color: AppColor.greyColor),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {},
                                child: const Icon(
                                  Icons.date_range,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            onChanged: (val) {},
                          ),
                        ),
                        TableCalendar(
                          focusedDay: exploreEventCubit.focusedDay,
                          firstDay: DateTime.utc(2010, 3, 14),
                          lastDay: DateTime.utc(2030, 3, 14),
                          calendarFormat: exploreEventCubit.calendarFormat,
                          rangeStartDay: exploreEventCubit.rangeStart,
                          rangeSelectionMode: RangeSelectionMode.toggledOn,
                          rangeEndDay: exploreEventCubit.rangeEnd,
                          onRangeSelected: _onRangeSelected,
                          availableCalendarFormats: {
                            CalendarFormat.month: StringConstant.monthCalendar,
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
                              isSameDay(exploreEventCubit.selectedDay, day),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          onDaySelected: _onDaySelected,
                          onPageChanged: (focusedDay) {
                            exploreEventCubit.focusedDay = focusedDay;
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
                items: exploreEventCubit.sortBy,
                selectedItem: exploreEventCubit.selectedSortByIndex,
                onItemSelected: (value) => setState(
                    () => exploreEventCubit.selectedSortByIndex = value),
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
                  itemCount: exploreEventCubit.orderBy.length,
                  itemBuilder: (context, index) {
                    final item = exploreEventCubit.orderBy[index];
                    final isOrderBySelected =
                        exploreEventCubit.selectedOrderByIndex == item['title'];
                    return InkWell(
                      onTap: () {
                        print(
                            'Selected index order by: ${exploreEventCubit.selectedOrderByIndex}');
                        print('Selected title order by: ${item['title']}');
                        setState(() {
                          exploreEventCubit.selectedOrderByIndex =
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
