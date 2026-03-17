import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/explore/widget/read_more_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

Widget postCard(BuildContext context,
    {required String username,
    required String timeAgo,
    String? content,
    String? imagePath,
    required int likes,
    required int comments,
    required int shares,
    required bool isFollowVisible}) {
  return Container(
    // height: 500,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0.sp, horizontal: 12.sp),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/icon/profile_pic.png'),
                    radius: 20.r,
                  ),
                  Gap(10.w),
                  Text(
                    username,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp, fontWeight: FontWeight.w600
                    ),
                  ),
                  Gap(10.w),
                  Text(timeAgo,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  const Spacer(),
                  if (isFollowVisible)
                    TextButton(
                      onPressed: () {},
                      child: Text("+ Follow",
                          style: TextStyle(
                              color: AppColor.gradientDarkColor,
                              fontSize: 14.sp)),
                    ),
                  const Icon(
                    Icons.more_vert,
                    color: AppColor.blackColor,
                  ),
                ],
              ),
              if (content != null) ...[
                Gap(10.h),
                SeeMoreTextWidget(
                  title: content,
                ),
              ]
            ],
          ),
        ),
        if (imagePath != null) ...[
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.r),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ],
        Gap(10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              rowIconText(Icons.favorite_border, "$likes"),
              rowIconText(Icons.comment, "$comments"),
              rowIconText(Icons.share, "$shares"),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
        )
      ],
    ),
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
      Gap( 5.h),
      Text(text, style: TextStyle(fontSize: 16.sp, color: AppColor.blackColor)),
    ],
  );
}
