import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonExploreAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const CommonExploreAppbar(
      {super.key,
      required this.favoriteIcon,
      this.savedIcon,
      required this.backOnTap,
      required this.favoriteOnTap,
      required this.shareOnTap,
      this.saveOnTap,
      this.likedCount});
  final Widget favoriteIcon;
  final Widget? savedIcon;
  final VoidCallback backOnTap;
  final VoidCallback favoriteOnTap;
  final VoidCallback shareOnTap;
  final VoidCallback? saveOnTap;
  final String? likedCount;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: backOnTap,
            icon:  Icon(Icons.arrow_back, color:Theme.of(context).brightness == Brightness.dark ?AppColor.whiteColor : AppColor.blackColor,
                    )),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w),
            child: Row(
              children: [
          InkWell(onTap: favoriteOnTap, child: favoriteIcon),
          SizedBox(width: 8.w),
          Center(
            child: Text(
              likedCount ?? "",
              style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color:Theme.of(context).brightness == Brightness.dark ?AppColor.whiteColor : AppColor.blackColor,
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          IconButton(
            onPressed: saveOnTap,
            icon: savedIcon ?? const SizedBox(),
          ),
         
          IconButton(
            onPressed: shareOnTap,
            icon: Icon(
              Icons.share_outlined,
              size: 20.h,
             color:Theme.of(context).brightness == Brightness.dark ?AppColor.whiteColor : AppColor.blackColor,
                    
            ),
          ),
              ],
            ),
          ),
        ],
        );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
