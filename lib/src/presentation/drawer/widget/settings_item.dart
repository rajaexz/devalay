import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SettingsItem extends StatelessWidget {
  final String url;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showArrow;

  const SettingsItem({
    super.key,
    required this.url,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
          // decoration: BoxDecoration(
          //   border: Border(
          //     bottom: BorderSide(
          //       color: Theme.of(context).dividerColor.withOpacity(0.2),
          //       width: 0.5,
          //     ),
          //   ),
          // ),
          child: Row(
            children: [
              rowImageIcon(
                context: context,
                onTap: () {},
                isSVG: true,
                imag: url,
                text: "",
                h: 20.h,
                w: 20.w,
                s: 0,
              ),
              Gap(13.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  size: 25.sp,
                  color: AppColor.blackColor,
                ),
              Gap(8.w),
            ],
          ),
        ),
      ),
    );
  }
}
