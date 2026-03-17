import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/colors.dart';

/// Figma-style Follow/Following button
/// - Following: Orange filled (#FF9500), white text
/// - Follow: White with grey border, black text
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  const FollowButton({
    super.key,
    required this.isFollowing,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 80.w,
      height: height ?? 28.h,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.orangeColor,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing
                    ? AppColor.orangeColor
                    : Colors.white,
                foregroundColor: isFollowing
                    ? Colors.white
                    : Colors.black,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  side: isFollowing
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade400),
                ),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

/// Small Follow button for inline use (like in suggestions)
class SmallFollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SmallFollowButton({
    super.key,
    required this.isFollowing,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.h,
      child: isLoading
          ? SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.orangeColor,
              ),
            )
          : TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isFollowing)
                    Icon(
                      Icons.add,
                      size: 14.sp,
                      color: Colors.black87,
                    ),
                  Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Full-width Follow button for profile pages
class FullWidthFollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? customText;

  const FullWidthFollowButton({
    super.key,
    required this.isFollowing,
    this.onPressed,
    this.isLoading = false,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 35.h,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.orangeColor,
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: isFollowing
                    ? AppColor.orangeColor
                    : Colors.white,
                foregroundColor: isFollowing
                    ? Colors.white
                    : Colors.black,
                side: isFollowing
                    ? BorderSide.none
                    : BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              child: Text(
                customText ?? (isFollowing ? 'Following' : 'Follow'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

/// Message button for profile pages
class MessageButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MessageButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 35.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        child: Text(
          'Message',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

