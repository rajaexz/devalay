import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class CommonDrawerTile extends StatelessWidget {
  const CommonDrawerTile(
      {super.key,
      required this.onTap,
      required this.imageUrl,
      required this.title});
  final VoidCallback onTap;
  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.sp, bottom: 5.sp),
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Image.asset(imageUrl),
                Gap(10.w),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 14.sp),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}

class CommonDrawerSvgTile extends StatelessWidget {
  const CommonDrawerSvgTile(
      {super.key,
      required this.onTap,
      required this.imageUrl,
      required this.title});
  final VoidCallback onTap;
  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.sp, bottom: 5.sp),
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                SvgPicture.asset(imageUrl),
                Gap(10.w),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 14.sp),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
