import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CommonFooterText extends StatelessWidget {
  const CommonFooterText({
    super.key,
    this.calledFrom,
    required this.onNextTap,
    this.onBackTap,
    this.nextText,
  });
  
  final String? calledFrom;
  final VoidCallback onNextTap;
  final VoidCallback? onBackTap;
  final String? nextText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button (Figma style)
            calledFrom != "first"
                ? Expanded(
                    child: GestureDetector(
                      onTap: onBackTap ?? () => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.center,
                        height: 42.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: const Color(0xFFDADADA),
                            width: 1,
                          ),
                          color: AppColor.whiteColor,
                        ),
                        child: Text(
                          StringConstant.back,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColor.blackColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Spacer(),
            Gap(10.w),
            // Next Button (Figma style - Orange #FF9500)
            Expanded(
              child: GestureDetector(
                onTap: onNextTap,
                child: Container(
                  alignment: Alignment.center,
                  height: 42.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: const Color(0xFFFF9500),
                  ),
                  child: Text(
                    nextText ?? StringConstant.next,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
