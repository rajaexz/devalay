import 'package:devalay_app/src/presentation/contribute/add_festival/festival/under_review_festival_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/utils/colors.dart';
import 'approved_festival_widget.dart';
import 'draft_festival_widget.dart';

class AddFestivalWidget extends StatefulWidget {
  const AddFestivalWidget({super.key});

  @override
  State<AddFestivalWidget> createState() => _AddFestivalWidgetState();
}

class _AddFestivalWidgetState extends State<AddFestivalWidget> {
  int selectedChipIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.sp),
      child: Column(
        children: [
          Gap(10.h),
          Row(
            children: [
              ChoiceChip(
                autofocus: true,
                label: Text(StringConstant.tabDraft),
                labelStyle: selectedChipIndex == 0
                    ? Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColor.whiteColor)
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xff241601)),
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
              Gap(20.w),
              ChoiceChip(
                autofocus: true,
                label: Text(StringConstant.tabUnderReview),
                labelStyle: selectedChipIndex == 1
                    ? Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColor.whiteColor)
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xff241601)),
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
              Gap(20.w),
              ChoiceChip(
                label:  Text(StringConstant.approved) ,
                labelStyle: selectedChipIndex == 2
                    ? Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColor.whiteColor)
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xff241601)),
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
          Expanded(
            child: getSelectedWidget(selectedChipIndex),
          ),
        ],
      ),
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const DraftFestivalWidget();
      case 1:
        return const UnderReviewFestivalWidget();
      case 2:
        return const ApprovedFestivalWidget();
      default:
        return  Center(child: Text(StringConstant.tabDraft),);
    }
  }
}
