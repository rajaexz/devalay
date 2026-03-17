import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/utils/colors.dart';

class CommonsHeaderText extends StatelessWidget {
  const CommonsHeaderText({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
  });

  final String title;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step counter - right aligned (Figma style)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Step $currentStep of $totalSteps',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Gap(12.h),
          // Title - left aligned, bold (Figma style)
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
