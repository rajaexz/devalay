import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/presentation/contribute/add_dev/dev/under_review_dev_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/utils/colors.dart';
import 'approved_dev_widget.dart';
import 'draft_dev_widget.dart';

class AddDevWidget extends StatefulWidget {
  const AddDevWidget({super.key});

  @override
  State<AddDevWidget> createState() => _AddDevWidgetState();
}

class _AddDevWidgetState extends State<AddDevWidget> {
  int selectedChipIndex = 0;
  late ContributeDevCubit _contributeDevCubit;

  @override
  void initState() {
    super.initState();
    _contributeDevCubit = ContributeDevCubit();
  }

  @override
  void dispose() {
    _contributeDevCubit.close();
    super.dispose();
  }
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
                label:   Text(StringConstant.tabUnderReview) ,
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
                label:   Text(StringConstant.approved) ,
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
        return const DraftDevWidget();
      case 1:
        return const UnderReviewDevWidget();
      case 2:
        return const ApprovedDevWidget();
      default:
        return  Center(child: Text(StringConstant.tabDraft),);
    }
  }
}
