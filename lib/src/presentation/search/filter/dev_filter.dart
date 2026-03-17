import 'package:devalay_app/src/application/explore/explore_dev/explore_dev_cubit.dart';
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

class DevFilterWidget extends StatefulWidget {
  const DevFilterWidget({super.key});

  @override
  State<DevFilterWidget> createState() => _DevFilterWidgetState();
}

class _DevFilterWidgetState extends State<DevFilterWidget> {
  late ExploreDevCubit exploreDevCubit;
  @override
  void initState() {
    super.initState();

    exploreDevCubit = context.read<ExploreDevCubit>();
  }

  @override
  Widget build(BuildContext context) {
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
                        exploreDevCubit.filterTypes.length,
                        (index) => GestureDetector(
                          onTap: () => setState(
                              () => exploreDevCubit.selectedFilter = index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.sp),
                            child: Text(exploreDevCubit.filterTypes[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: exploreDevCubit.selectedFilter ==
                                                index
                                            ? accentColor
                                            : AppColor.blackColor)),
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
                  final String filterQuery = exploreDevCubit.buildFilterQuery();
                  debugPrint('${StringConstant.filterGuery}: $filterQuery');

                  // Use GobelSearchCubit for consistent API calls
                  context.read<GobelSearchCubit>().applyFilters(filterQuery, 'Dev');

                  Navigator.pop(context);
                },
                clearTap: () {
                  setState(() {
                    exploreDevCubit.selectedSortByIndex = '';
                    exploreDevCubit.selectedOrderByIndex = 'Decending';
                    exploreDevCubit.selectedLocationFilterMap = {};
                    exploreDevCubit.selectedDevFilterMap = {};
                    exploreDevCubit.searchLocationController.clear();
                  });
                  
                  // Clear filters and reload data
                  context.read<GobelSearchCubit>().applyFilters('', 'Dev');
                  
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
    switch (exploreDevCubit.selectedFilter) {
      case 0:
        return SizedBox(
            height: 300.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: ShortListFilterWidget(
                items: exploreDevCubit.sortBy,
                selectedItem: exploreDevCubit.selectedSortByIndex,
                onItemSelected: (value) =>
                    setState(() => exploreDevCubit.selectedSortByIndex = value),
              ),
            ));
      case 1:
        return SizedBox(
          height: 300.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: exploreDevCubit.orderBy.length,
                  itemBuilder: (context, index) {
                    final item = exploreDevCubit.orderBy[index];
                    final isOrderBySelected =
                        exploreDevCubit.selectedOrderByIndex == item['title'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          exploreDevCubit.selectedOrderByIndex =
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
