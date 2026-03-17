import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Custom button widget for introduction/onboarding flows.
/// 
/// Shows Next button always, and optionally Back button.
/// Set [showBackButton] to false or use [calledFrom] = "first" to hide back button.
class CustomIntroButton extends StatelessWidget {
  const CustomIntroButton({
    super.key,
    this.calledFrom,
    required this.onNextTap,
    this.onBackTap,
    this.nextText,
    this.showBackButton,
  });

  /// Legacy parameter - use "first" to hide back button
  final String? calledFrom;
  
  /// Callback when Next button is tapped
  final VoidCallback onNextTap;
  
  /// Callback when Back button is tapped
  final VoidCallback? onBackTap;
  
  /// Custom text for Next button (defaults to "Next")
  final String? nextText;
  
  /// Whether to show the back button (overrides calledFrom)
  final bool? showBackButton;

  /// Determine if back button should be visible
  bool get _shouldShowBackButton {
    if (showBackButton != null) return showBackButton!;
    return calledFrom != "first";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back button (with spacing placeholder when hidden)
            if (_shouldShowBackButton)
              _buildBackButton(context)
            else
              SizedBox(width: 100.w), // Maintain spacing for alignment
            
            Gap(14.w),
            
            // Next button
            _buildNextButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
                onTap: onBackTap ?? () => Navigator.pop(context),
                child: Container(
                    alignment: Alignment.center,
                    width: 100.w,
                    height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xff555151),
            width: 0.5.sp,
          ),
          color: AppColor.whiteColor,
        ),
        child: Text(
          StringConstant.back,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColor.blackColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
                onTap: onNextTap,
                child: Container(
                    alignment: Alignment.center,
                    width: 100.w,
                    height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 22.sp),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
          color: AppColor.orangeColor,
                    ),
        child: Text(
          nextText ?? StringConstant.next,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColor.whiteColor,
          ),
        ),
      ),
    );
  }
}
