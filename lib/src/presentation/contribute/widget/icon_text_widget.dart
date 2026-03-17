import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class IconTextWidget extends StatelessWidget {
  const IconTextWidget(
      {super.key,
      required this.onTap,
      required this.imageUrl,
      required this.text});
  final VoidCallback onTap;
  final String imageUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(10.sp),
              height: 45.h,
              width: 45.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: accentColor),
              ),
              // ignore: deprecated_member_use
              child: SvgPicture.network(imageUrl, color: accentColor)),
          Gap(10.h),
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black.withOpacity(0.67))),
        ],
      ),
    );
  }
}

class CommonIconWidget extends StatelessWidget {
  const CommonIconWidget({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.sp),
        height: 45.h,
        width: 45.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: accentColor),
        ),
        child: SvgPicture.network(imageUrl, color: accentColor));
  }
}
