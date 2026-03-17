import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/landing_screen.dart/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TempleCompleteScreen extends StatelessWidget {
  const TempleCompleteScreen({
    super.key,
    this.templeId,
    this.governingId,
    this.calledFrom,
  });
  
  final String? calledFrom;
  final String? templeId;
  final String? governingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Icon (Figma style - folded paper icon)
                Image.asset(
                  "assets/icon/complete_successfully.png",
                  height: 84.h,
                  width: 73.w,
                ),
                Gap(24.h),
                
                // Success Message (Figma style)
                Text(
                  StringConstant.successfullySubmitted,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(24.h),
                
                // Done Button (Figma style - Orange #FF9500)
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 42.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: const Color(0xFFFF9500),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      StringConstant.done,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
