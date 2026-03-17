import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/introduction_popup/widget/shared/like_save_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Reusable content card for temples, events, etc.
/// 
/// Provides consistent styling across introduction flow screens.
class IntroContentCard extends StatelessWidget {
  const IntroContentCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeTap,
    required this.isSaved,
    required this.saveCount,
    required this.onSaveTap,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  
  // Like/Save state
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLikeTap;
  final bool isSaved;
  final int saveCount;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 6.sp),
        child: Row(
          children: [
            _buildImage(),
            SizedBox(width: 12.w),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 105.h,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: CustomCacheImage(
            imageUrl: imageUrl ?? StringConstant.defaultImage,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(4.h),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xff555151),
          ),
        ),
        Gap(4.h),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xff14191E),
          ),
        ),
        SizedBox(height: 10.h),
        LikeSaveActions(
          isLiked: isLiked,
          likeCount: likeCount,
          onLikeTap: onLikeTap,
          isSaved: isSaved,
          saveCount: saveCount,
          onSaveTap: onSaveTap,
        ),
      ],
    );
  }
}

