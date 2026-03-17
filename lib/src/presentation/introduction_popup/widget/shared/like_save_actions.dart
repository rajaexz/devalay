import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// Reusable Like and Save action buttons widget.
/// 
/// Used in temple cards, event cards, and other list items.
class LikeSaveActions extends StatelessWidget {
  const LikeSaveActions({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeTap,
    required this.isSaved,
    required this.saveCount,
    required this.onSaveTap,
  });

  final bool isLiked;
  final int likeCount;
  final VoidCallback onLikeTap;
  
  final bool isSaved;
  final int saveCount;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context: context,
          onTap: onLikeTap,
          isActive: isLiked,
          activeIcon: "assets/icon/liked.svg",
          inactiveIcon: "assets/icon/like.svg",
          count: likeCount,
        ),
        SizedBox(width: 25.w),
        _buildActionButton(
          context: context,
          onTap: onSaveTap,
          isActive: isSaved,
          activeIcon: "assets/icon/saved.svg",
          inactiveIcon: "assets/icon/active_save_icon.svg",
          count: saveCount,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onTap,
    required bool isActive,
    required String activeIcon,
    required String inactiveIcon,
    required int count,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 50.w,
        height: 30.h,
        child: Row(
          children: [
            SvgPicture.asset(
              isActive ? activeIcon : inactiveIcon,
              key: ValueKey<bool>(isActive),
              height: 20.h,
              width: 20.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '$count',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

