import 'package:devalay_app/src/presentation/core/helper/image_helper.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class BigCardWidget extends StatelessWidget {
  const BigCardWidget({
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
      padding: EdgeInsets.symmetric(horizontal: width * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            // borderRadius: BorderRadius.circular(5.r),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: GestureDetector(
                onDoubleTap: () {
                  ImageHelper.showImagePreview(context, imageUrl);
                },
                onTap: boxOnTap,
                child: CustomCacheImage(imageUrl: imageUrl, ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              InkWell(
                onTap: favoriteOnTap,
                borderRadius: BorderRadius.circular(50),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey<bool>(isLiked),
                    size: width * 0.05,
                    color: isLiked ? AppColor.redColor : colorScheme.onBackground,
                  ),
                ),
              ),
              SizedBox(width: 6.h),
              Text(
                likedCount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              SizedBox(width: 15.h),
              InkWell(
                onTap: shareOnTap,
                borderRadius: BorderRadius.circular(50),
                child: Icon(
                  Icons.share_outlined,
                  size: width * 0.05,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
