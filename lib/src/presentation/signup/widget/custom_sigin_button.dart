import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSignInButton extends StatelessWidget {
  const CustomSignInButton(
      {super.key, required this.onTap, required this.text});

  final VoidCallback onTap;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.sp),
        child: Container(
          height: 50.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColor.gradientDarkColor, AppColor.appbarBgColor],
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: text,
        ),
      ),
    );
  }
}
