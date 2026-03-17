import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomExplore extends StatelessWidget implements PreferredSizeWidget {
  const CustomExplore(
      {super.key,
      required this.favoriteIcon,
      required this.savedIcon,
      required this.backOnTap,
      required this.favoriteOnTap,
      required this.shareOnTap,
      this.saveOnTap,
      this.likedCount,
      this.savedCount,
      this.viewedCount});
  final Widget favoriteIcon;
  final Widget savedIcon;
  final VoidCallback backOnTap;
  final VoidCallback favoriteOnTap;
  final VoidCallback shareOnTap;
  final VoidCallback? saveOnTap;
  final String? likedCount;
  final String? savedCount;
  final String? viewedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0.w),
      child: Row(
        children: [
          InkWell(
            onTap: favoriteOnTap,
            child: SizedBox(
              width: 50.w,
              child: Row(
                children: [
                  favoriteIcon,
                  SizedBox(width: 8.w),
                  Center(
                    child: Text(
                      likedCount ?? "",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColor.whiteColor
                                    : AppColor.blackColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 25.w),
          InkWell(
            onTap: saveOnTap,
            child: SizedBox(
              width: 50.w,
              child: Row(
                children: [
                  savedIcon,
                  SizedBox(width: 8.w),
                  Center(
                    child: Text(
                      savedCount ?? "",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColor.whiteColor
                                    : AppColor.blackColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 25.w),
          InkWell(
              child: SvgPicture.asset(
            "assets/icon/view.svg",
            height: 20.h,
            width: 20.w,
          )),
          SizedBox(width: 8.w),
          Center(
            child: Text(
              viewedCount ?? "",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.whiteColor
                        : AppColor.blackColor,
                  ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: shareOnTap,
            child: SizedBox(
              width: 76.w,
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icon/Messanger.svg",
                    height: 20.h,
                    width: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Center(
                    child: Text(
                      StringConstant.shareAction,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColor.whiteColor
                            : AppColor.blackColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // InkWell(
          //   onTap: shareOnTap,
          //     child: SvgPicture.asset(
          //       "assets/icon/Messanger.svg",
          //       height: 20.h,
          //       width: 20.w,
          //     )),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
