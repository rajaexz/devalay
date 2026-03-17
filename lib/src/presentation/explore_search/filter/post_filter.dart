
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
import 'package:gap/gap.dart';

import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
class PostFilterWidget extends StatefulWidget {
  final String textType;
  const PostFilterWidget({super.key, required this.textType});

  @override
  State<PostFilterWidget> createState() => _PostFilterWidgetState();
}

class _PostFilterWidgetState extends State<PostFilterWidget> {
  late GobelSearchCubit gobelSearchCubit;

  @override
  void initState() {
    gobelSearchCubit = context.read<GobelSearchCubit>();
    super.initState();
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
            color: Theme.of(context).colorScheme.background,  borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            border: Border.all(   color: Theme.of(context).colorScheme.secondary, width: 2.w),
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
                        gobelSearchCubit.filterTypes.length,
                        (index) => GestureDetector(
                          onTap: () => setState(
                              () => gobelSearchCubit.selectedFilter = index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.sp),
                            child: Text(gobelSearchCubit.filterTypes[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color:
                                            gobelSearchCubit.selectedFilter ==
                                                    index
                                                ? accentColor
                                                : (Theme.of(context).brightness == Brightness.dark ?AppColor.whiteColor: AppColor.blackColor))),
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
                  final String filterQuery = buildFilterQuery();
                  debugPrint('${StringConstant.filterGuery}: $filterQuery');

                 
                  context.read<GobelSearchCubit>().applyFilters(filterQuery, widget.textType);

                  Navigator.pop(context);
                },
                clearTap: () {
                  setState(() {
                    gobelSearchCubit.selectedLocationIndex = null;
                    gobelSearchCubit.selectedDevIndex = null;
                    gobelSearchCubit.selectedSortByIndex = '';
                    gobelSearchCubit.selectedOrderByIndex = 'Decending';
                    gobelSearchCubit.searchLocationController.clear();
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

  String buildFilterQuery() {
    final List<String> queryParams = [];


    if (gobelSearchCubit.selectedSortByIndex != null) {
      String sortBy = gobelSearchCubit.selectedSortByIndex!.toLowerCase();

      if (sortBy == 'added date') sortBy = 'recent';

      if (sortBy == 'alphabetically') sortBy = 'alphabetically';

      queryParams.add('&sort_by=$sortBy');
    }

    if (gobelSearchCubit.selectedOrderByIndex != null) {
      String orderBy =
          gobelSearchCubit.selectedOrderByIndex == 'Ascending' ? 'asce' : 'desc';
      queryParams.add('&order_by=$orderBy');
    }

    return queryParams.isEmpty ? '' : queryParams.join('');
  }

  Widget _buildSelectedFilterContent() {
    switch (gobelSearchCubit.selectedFilter) {
      case 0:
        return SizedBox(
            height: 300.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: ShortListFilterWidget(
                items: gobelSearchCubit.sortBy,
                selectedItem: gobelSearchCubit.selectedSortByIndex,
                onItemSelected: (value) => setState(
                    () => gobelSearchCubit.selectedSortByIndex = value),
              ),
            ));
      case 1:
        return SizedBox(
          height: 300.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: const Column(
              children: [
                // ListView.separated(
                //   shrinkWrap: true,
                //   itemCount: gobelSearchCubit.orderBy.length,
                //   itemBuilder: (context, index) {
                //     final item = gobelSearchCubit.orderBy[index];
                //     final isOrderBySelected =
                //         gobelSearchCubit.selectedOrderByIndex == item['title'];
                //     return InkWell(
                //       onTap: () {
                //          setState(() {
                //           gobelSearchCubit.selectedOrderByIndex =
                //               isOrderBySelected ? null : item['title'];
                //         });
                //       },
                //       child: Row(
                //         children: [
                //           Checkbox(
                //             value: isOrderBySelected,
                //             onChanged: (val) {
                //               setState(() {
                //                 gobelSearchCubit.selectedOrderByIndex =
                //                     val == true ? item['title'] : null;
                //               });
                //             },
                //             activeColor: accentColor,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(4),
                //             ),
                //           ),
                //           Gap(10.w),
                //           Expanded(
                //             child: Text(item['title'],
                //                 style: Theme.of(context).textTheme.bodyMedium),
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                //   separatorBuilder: (context, index) {
                //     return Gap(10.h);
                //   },
                // )
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
