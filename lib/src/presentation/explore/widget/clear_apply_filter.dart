import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClearApplyFilter extends StatelessWidget {
  const ClearApplyFilter({
    super.key,
    required this.applyTap,
    required this.clearTap,
    required this.title,
    required this.buttonText,
  });
  final VoidCallback applyTap;
  final VoidCallback clearTap;
  final String title;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.sp, vertical: 20.sp),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: clearTap,
              child: Container(
                height: 40.h, // Match Apply button height
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(5.r),
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: InkWell(
              onTap: applyTap,
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColor.appbarBgColor,
                      AppColor.gradientDarkColor
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
