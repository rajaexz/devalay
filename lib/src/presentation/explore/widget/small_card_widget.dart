import 'package:devalay_app/src/presentation/core/helper/image_helper.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class SmallCardWidget extends StatelessWidget {
  const SmallCardWidget({
    super.key,
    required this.boxOnTap,
    required this.favoriteOnTap,
    required this.shareOnTap,
    required this.imageUrl,
    required this.title,
    required this.likedCount,
    required this.isLiked,
  });

  final VoidCallback boxOnTap;
  final VoidCallback favoriteOnTap;
  final VoidCallback shareOnTap;
  final String imageUrl;
  final String title;
  final String likedCount;
  final bool isLiked;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: boxOnTap,
            onDoubleTap: () {
              ImageHelper.showImagePreview(context, imageUrl,);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: CustomCacheImage(
                  imageUrl: imageUrl,borderRadius: const BorderRadius.only(topLeft: Radius.zero,topRight: Radius.zero),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              InkWell(
                onTap: favoriteOnTap,
                // borderRadius: BorderRadius.circular(50),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Image.asset("assets/icon/like.svg", height: 20,width: 20,)
                  // Icon(
                  //   isLiked ? Icons.favorite : Icons.favorite_outline,
                  //   key: ValueKey<bool>(isLiked),
                  //   size: width * 0.05,
                  //   color: isLiked ? AppColor.redColor : colorScheme.onBackground,
                  // ),
                ),
              ),
              SizedBox(width: 6.h),
              Text(
                likedCount,
                style: Theme.of(context).textTheme.bodyMedium
              ),
            ],
          ),
        ],
      ),
    );
  }
}
