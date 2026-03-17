// ignore_for_file: deprecated_member_use

import 'package:devalay_app/src/presentation/contribute/add_temple/temple/approved_temple_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_temple/temple/draft_temple_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_temple/temple/under_review_temple_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AddTempleWidget extends StatefulWidget {
  const AddTempleWidget({super.key});

  @override
  State<AddTempleWidget> createState() => _AddTempleWidgetState();
}

class _AddTempleWidgetState extends State<AddTempleWidget> {
  int selectedChipIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.sp),
      child: Column(
          children: [
          Gap(20.h),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                label: Text(StringConstant.tabDraft),
                  labelStyle: selectedChipIndex == 0
                      ? Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColor.whiteColor)
                      : Theme.of(context)
                          .textTheme
                          .bodySmall
                        ?.copyWith(color: const Color(0xff241601)),
                  selected: selectedChipIndex == 0,
                  backgroundColor: AppColor.appbarBgColor.withOpacity(0.2),
                  selectedColor: AppColor.orangeColor,
                  shape: selectedChipIndex == 0
                      ? RoundedRectangleBorder(
                          side: BorderSide(
                              color: const Color(0xff4F1500).withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(30.r))
                      : RoundedRectangleBorder(
                          side: BorderSide(
                              color: const Color(0xff4F1500).withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(30.r)),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedChipIndex = 0;
                    });
                  },
                ),
                ChoiceChip(
                label: Text(StringConstant.tabUnderReview),
                  labelStyle: selectedChipIndex == 1
                      ? Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColor.whiteColor)
                      : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xff241601)),
                  selected: selectedChipIndex == 1,
                  backgroundColor: AppColor.appbarBgColor.withOpacity(0.2),
                  selectedColor: AppColor.orangeColor,
                  shape: selectedChipIndex == 1
                      ? RoundedRectangleBorder(
                          side: BorderSide(
                              color: const Color(0xff4F1500).withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(30.r))
                      : RoundedRectangleBorder(
                          side: BorderSide(
                              color: const Color(0xff4F1500).withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(30.r)),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedChipIndex = 1;
                    });
                  },
                ),
                ChoiceChip(
                label: Text(StringConstant.approved),
                  labelStyle: selectedChipIndex == 2
                      ? Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColor.whiteColor)
                      : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xff241601)),
                  selected: selectedChipIndex == 2,
                  backgroundColor: AppColor.appbarBgColor.withOpacity(0.2),
                  selectedColor: AppColor.orangeColor,
                  shape: selectedChipIndex == 2
                      ? RoundedRectangleBorder(
                          side: BorderSide(
                              color: const Color(0xff4F1500).withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(30.r))
                      : RoundedRectangleBorder(
                          side: BorderSide(
                              color: const Color(0xff4F1500).withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(30.r)),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedChipIndex = 2;
                    });
                  },
                ),
              ],
            ),
            Gap(20.h),
            Expanded(child: getSelectedWidget(selectedChipIndex)),
          ],
      ),
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const DraftTempleWidget();
      case 1:
        return const UnderReviewTempleWidget();
      case 2:
        return const ApprovedTempleWidget();
      default:
        return const DraftTempleWidget();
    }
  }
}
