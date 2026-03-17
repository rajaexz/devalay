import 'package:devalay_app/src/application/explore/explore_festival/explore_festival_cubit.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/explore/widget/clear_apply_filter.dart';
import 'package:devalay_app/src/presentation/explore/widget/close_button_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/custom_divider_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/filter_header_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/list_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class FestivalFilterWidget extends StatefulWidget {
  const FestivalFilterWidget({super.key});

  @override
  State<FestivalFilterWidget> createState() => _FestivalFilterWidgetState();
}

class _FestivalFilterWidgetState extends State<FestivalFilterWidget> {
  late ExploreFestivalCubit exploreFestivalCubit;

  @override
  void initState() {
    super.initState();
    exploreFestivalCubit = context.read<ExploreFestivalCubit>();
    exploreFestivalCubit.selectedDay = exploreFestivalCubit.focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(exploreFestivalCubit.selectedDay, selectedDay)) {
      setState(() {
        exploreFestivalCubit.selectedDay = selectedDay;
        exploreFestivalCubit.focusedDay = focusedDay;
        exploreFestivalCubit.dateController.text = _formatDate(selectedDay);
      });
    }
  }

  String buildFilterQuery() {
    final List<String> queryParams = [];

    if (exploreFestivalCubit.selectedLocationIndex != null &&
        exploreFestivalCubit.selectedLocationFilterMap.isNotEmpty) {
      final city = exploreFestivalCubit.selectedLocationFilterMap['city'];
      final state = exploreFestivalCubit.selectedLocationFilterMap['state'];
      final country = exploreFestivalCubit.selectedLocationFilterMap['country'];

      if (city != null) queryParams.add('&city=$city');
      if (state != null) queryParams.add('&state=$state');
      if (country != null) queryParams.add('&country=$country');
    }

    if (exploreFestivalCubit.rangeStart != null &&
        exploreFestivalCubit.rangeEnd != null) {
      final start =
          DateFormat('yyyy-MM-dd').format(exploreFestivalCubit.rangeStart!);
      final end =
          DateFormat('yyyy-MM-dd').format(exploreFestivalCubit.rangeEnd!);
      queryParams.add('&start_date=$start');
      queryParams.add('&end_date=$end');
    } else {
      queryParams.add('');
      queryParams.add('');
    }

    if (exploreFestivalCubit.selectedSortByIndex != null) {
      String sortBy = exploreFestivalCubit.selectedSortByIndex!.toLowerCase();

      if (sortBy == 'added date') sortBy = 'recent';

      if (sortBy == 'alphabetically') sortBy = 'alphabetically';

      queryParams.add('sort_by=$sortBy');
    }

    if (exploreFestivalCubit.selectedOrderByIndex != null) {
      String orderBy = exploreFestivalCubit.selectedOrderByIndex == 'Ascending'
          ? 'asce'
          : 'desc';
      queryParams.add('&order_by=$orderBy');
    }

    return queryParams.isEmpty ? '' : queryParams.join('');
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      exploreFestivalCubit.selectedDay = null;
      exploreFestivalCubit.focusedDay = focusedDay;
      exploreFestivalCubit.rangeStart = start;
      exploreFestivalCubit.rangeEnd = end;

      if (start != null && end != null) {
        exploreFestivalCubit.dateController.text =
            "${_formatDate(start)} - ${_formatDate(end)}";
      } else if (start != null) {
        exploreFestivalCubit.dateController.text = _formatDate(start);
      } else {
        exploreFestivalCubit.dateController.text = '';
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Selected index order by: $exploreFestivalCubit.selectedOrderByIndex');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CloseButtonWidget(onTap: () => Navigator.pop(context)),
        Gap(10.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            border: Border.all(color: accentColor, width: 2.w),
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
                        exploreFestivalCubit.filterTypes.length,
                        (index) => GestureDetector(
                          onTap: () => setState(() =>
                              exploreFestivalCubit.selectedFilter = index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.sp),
                            child: Text(exploreFestivalCubit.filterTypes[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: exploreFestivalCubit
                                                    .selectedFilter ==
                                                index
                                            ? accentColor
                                            : AppColor.blackColor)),
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

                  // Use GobelSearchCubit for consistent API calls
                  context.read<GobelSearchCubit>().applyFilters(filterQuery, 'Festival');

                  Navigator.pop(context);
                },
                clearTap: () {
                  setState(() {
                    exploreFestivalCubit.selectedLocationIndex = null;

                    exploreFestivalCubit.selectedSortByIndex = '';
                    exploreFestivalCubit.selectedOrderByIndex = 'Decending';
                    exploreFestivalCubit.selectedLocationFilterMap = {};

                    exploreFestivalCubit.searchLocationController.clear();
                    exploreFestivalCubit.dateController.text =
                          StringConstant.noDataAvailable;
                    exploreFestivalCubit.rangeEnd = null;
                    exploreFestivalCubit.rangeStart = null;
                  });
                  
                  // Clear filters and reload data
                  context.read<GobelSearchCubit>().applyFilters('', 'Festival');
                  
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
    switch (exploreFestivalCubit.selectedFilter) {
      case 0:
        return SizedBox(
          height: 350.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40.h,
                  child: TextField(
                    controller: exploreFestivalCubit.dateController,
                    focusNode: exploreFestivalCubit.focusNode,
                    decoration: InputDecoration(
                      hintText: 'Select date',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 10.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: AppColor.greyColor),
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
                  focusedDay: exploreFestivalCubit.focusedDay,
                  firstDay: DateTime.utc(2010, 3, 14),
                  lastDay: DateTime.utc(2030, 3, 14),
                  calendarFormat: exploreFestivalCubit.calendarFormat,
                  rangeStartDay: exploreFestivalCubit.rangeStart,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  rangeEndDay: exploreFestivalCubit.rangeEnd,
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
                    rightChevronIcon: Icon(Icons.chevron_right, size: 20),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: EdgeInsets.all(1.sp),
                    defaultTextStyle: const TextStyle(fontSize: 12),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        color: const Color(0xffFF9500).withOpacity(0.88)),
                    weekendStyle: TextStyle(
                        color: const Color(0xffFF9500).withOpacity(0.88)),
                  ),
                  rowHeight: 25,
                  selectedDayPredicate: (day) =>
                      isSameDay(exploreFestivalCubit.selectedDay, day),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: _onDaySelected,
                  onPageChanged: (focusedDay) {
                    exploreFestivalCubit.focusedDay = focusedDay;
                  },
                ),
              ],
            ),
          ),
        );

      case 1:
        return SizedBox(
            height: 300.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: ShortListFilterWidget(
                items: exploreFestivalCubit.sortBy,
                selectedItem: exploreFestivalCubit.selectedSortByIndex,
                onItemSelected: (value) => setState(
                    () => exploreFestivalCubit.selectedSortByIndex = value),
              ),
            ));
      case 2:
        return SizedBox(
          height: 300.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: exploreFestivalCubit.orderBy.length,
                  itemBuilder: (context, index) {
                    final item = exploreFestivalCubit.orderBy[index];
                    final isOrderBySelected =
                        exploreFestivalCubit.selectedOrderByIndex ==
                            item['title'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          exploreFestivalCubit.selectedOrderByIndex =
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
