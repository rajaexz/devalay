import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonInfoSection extends StatelessWidget {
  const CommonInfoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.address,
    required this.website,
  });

  final String title;
  final String subtitle;
  final String address;
  final String website;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColor.blackColor;
    final mutedTextColor = textColor.withOpacity(0.9);
    final iconColor = isDark ? Colors.white70 : AppColor.blackColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          Gap(10.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: mutedTextColor,
            ),
          ),
          Gap(10.h),
          if (address.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: iconColor),
                Gap(10.w),
                Expanded(
                  child: Text(
                    address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: mutedTextColor,
                    ),
                  ),
                ),
              ],
            ),
          Gap(10.h),
          if (website.isNotEmpty)
            Row(
              children: [
                Icon(Icons.link, color: iconColor),
                Gap(10.w),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(website);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    website,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: mutedTextColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          Divider(
            height: 5,
            thickness: 0.5,
            color: isDark
                ? Colors.white24
                : AppColor.appbarBgColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
