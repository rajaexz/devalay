import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSettingTile extends StatelessWidget {
  const CustomSettingTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 16.sp),
              child: Icon(icon, size: 30.sp),
            ),
            Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.sp),
              child: const Icon(
                Icons.chevron_right,
                color: AppColor.blackColor
              ),
            ),
          ],
        ),
      ),
    );
  }
}