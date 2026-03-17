import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/explore/widget/clear_apply_filter.dart';
import 'package:devalay_app/src/presentation/explore/widget/close_button_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/custom_divider_widget.dart';
import 'package:devalay_app/src/presentation/explore/widget/filter_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class ContributeEventFilterWidget extends StatefulWidget {
  const ContributeEventFilterWidget({
    super.key,
  }); 

  @override
  State<ContributeEventFilterWidget> createState() =>
      _ContributeEventFilterWidgetState();
}

class _ContributeEventFilterWidgetState
    extends State<ContributeEventFilterWidget> {
  late ContributeEventCubit contributeEventCubit;

  @override
  void initState() {
    super.initState();
    contributeEventCubit = context.read<ContributeEventCubit>();
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
                        contributeEventCubit.filterTypes.length,
                        (index) => GestureDetector(
                          onTap: () => setState(() =>
                              contributeEventCubit.selectedChipIndex = index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.sp),
                            child: Text(
                              contributeEventCubit.filterTypes[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: contributeEventCubit
                                                .selectedChipIndex ==
                                            index
                                        ? accentColor
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColor.whiteColor
                                            : AppColor.blackColor),
                                  ),
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
              ClearApplyFilter(
                title: StringConstant.cleanFilter,
                buttonText: StringConstant.applyFilter,
                applyTap: () async {
                  try {
                    // Show loading state
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
 
                    // await context.read<ContributeEventCubit>().applyFilter(
                    //       sortBy: contributeEventCubit.selectedSortByIndex,
                    //       orderBy: contributeEventCubit.selectedOrderByIndex,
                    //     );

                    if (mounted) Navigator.pop(context);

                    if (mounted) Navigator.pop(context);

                    debugPrint('Filter applied successfully');
                  } catch (e) {
                    if (mounted) Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Filter failed: $e')),
                    );
                    debugPrint('Filter error: $e');
                  }
                },
                clearTap: () async {
                  try {
                    // Show loading state
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Clear local selections
                    setState(() {
                      contributeEventCubit.selectedSortByIndex = null;
                      contributeEventCubit.selectedOrderByIndex =
                          ''; // Default value
                    });

                    contributeEventCubit.clearFilters();
                    contributeEventCubit.applyFilter(
                      newSectionIndex: contributeEventCubit.sectionIndex,
                    );

                    // Close loading dialog
                    if (mounted) Navigator.pop(context);

                    debugPrint('Filters cleared successfully');
                  } catch (e) {
                    // Close loading dialog
                    if (mounted) Navigator.pop(context);

                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Clear filters failed: $e')),
                    );
                    debugPrint('Clear filters error: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFilterContent() {
    switch (contributeEventCubit.selectedChipIndex) {
      case 0: // Sort By
        return SizedBox(
          height: 300.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: contributeEventCubit.sortBy.length,
              itemBuilder: (context, index) {
                final item = contributeEventCubit.sortBy[index];
                final isSelected =
                    contributeEventCubit.selectedSortByIndex == item;

                return InkWell(
                  onTap: () {
                    setState(() {
                      contributeEventCubit.selectedSortByIndex =
                          isSelected ? null : item;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 12.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.transparent,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? accentColor
                              : AppColor.lightTextColor,
                          size: 20.sp,
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isSelected ? accentColor : null,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Gap(8.h),
            ),
          ),
        );

      case 1: // Order By
        return SizedBox(
          height: 300.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: contributeEventCubit.orderBy.length,
              itemBuilder: (context, index) {
                final item = contributeEventCubit.orderBy[index];
                final isSelected =
                    contributeEventCubit.selectedOrderByIndex == item['title'];

                return InkWell(
                  onTap: () {
                    setState(() {
                      contributeEventCubit.selectedOrderByIndex = item['title'];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 12.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.transparent,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.network(
                          item['icon'],
                          color: isSelected
                              ? accentColor
                              : AppColor.lightTextColor,
                          height: 20.h,
                          width: 20.w,
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Text(
                            item['title'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isSelected ? accentColor : null,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: accentColor,
                            size: 20.sp,
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Gap(8.h),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
