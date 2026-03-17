import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

Widget postLikeCard(
  BuildContext context, {
  required String username,
  // required String imagePath,
  required String likes,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp, fontWeight: FontWeight.w500
              ),),
            Row(
              children: [
                rowIconText(Icons.favorite_border, likes),
                Gap(10.w),
                Icon(
                  Icons.share_outlined,
                  color: Colors.black,
                  size: 16.sp,
                ),
              ],
            ),
          ],
        ),
      ),
      const Divider(
        color: Colors.grey,
      )
    ],
  );
}

Widget rowIconText(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        color: Colors.black,
        size: 16.sp,
      ),
     Gap( 5.w),
      Text(text, style: TextStyle(fontSize: 16.sp, color: AppColor.blackColor)),
    ],
  );
}
