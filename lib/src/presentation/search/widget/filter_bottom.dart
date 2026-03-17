
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:flutter_svg/svg.dart';


class FilterBottomSheet extends StatefulWidget {
  final Function(String) onFilterSelected;
  final String initialSelectedFilter;
  final TextEditingController searchController;
  final Function() onApplyFilter;

  const FilterBottomSheet({
    super.key,
    required this.onFilterSelected,
    required this.initialSelectedFilter,
    required this.searchController,
    required this.onApplyFilter,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialSelectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:Theme.of(context).brightness == Brightness.dark ? AppColor.lightTextColor:  AppColor.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        border: Border(
          right: BorderSide(color: accentColor, width: 2.w),
          left: BorderSide(color: accentColor, width: 2.w),
          top: BorderSide(color: accentColor, width: 2.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(10.h),
          Container(
            alignment: Alignment.center,
            width: 70,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 25.0, top: 10, bottom: 10, right: 25.0),
            child: Column(
              children: [
                Gap(13.h),
                _buildFilterOption(
                  icon: "assets/icon/Vector.svg",
                  text: StringConstant.dev,
                ),
                Gap(13.h),
                _buildFilterOption(
                  icon: "assets/icon/praying.svg",
                 text: StringConstant.appName,
                ),
                Gap(13.h),
                _buildFilterOption(
                  icon: "assets/icon/star.svg",
                  
                  text: StringConstant.festival,
                ),
                Gap(13.h),
                _buildFilterOption(
                  icon: "assets/icon/calender.svg",
               
                  text: StringConstant.events,
                ),
                Gap(13.h),
                _buildFilterOption(
                  icon: "assets/icon/yag.svg",
                  text: StringConstant.pujas,
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      mypadding: null,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onFilterSelected("");
                      },
                      btnColor: Colors.transparent,
                      textColor: AppColor.greyColor,
                      textButton: StringConstant.cleanFilter,
                      buttonAssets: '',
                    ),
                    CustomButton(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onFilterSelected(selectedFilter);
                        widget.onApplyFilter();
                      },
                      mypadding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      btnColor: AppColor.appbarBgColor,
                      textColor: AppColor.lightGrayColor,
                      textButton: StringConstant.applyFilter,
                      buttonAssets: '',
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterOption({required String icon, required String text}) {
    bool isSelected = selectedFilter == text;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(31, 55, 50, 50),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: Offset(2, 3),
                  ),
                ],
                border: Border.all(
                  color: AppColor.appbarBgColor,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  icon,
                  height: 20.h,
                  width: 25.w,
                  colorFilter: const ColorFilter.mode(
                    AppColor.appbarBgColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Gap(10.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? AppColor.appbarBgColor :  (   Theme.of(context).brightness == Brightness.dark ? AppColor.whiteColor:  AppColor.blackColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}