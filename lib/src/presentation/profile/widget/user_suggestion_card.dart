import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/widget/custom_cache_image.dart';
import 'follow_button.dart';

/// Figma-style User Suggestion Card
/// Shows suggested user with avatar, name, location, and follow button
class UserSuggestionCard extends StatelessWidget {
  final String? avatarUrl;
  final String userName;
  final String? location;
  final bool isFollowing;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onMoreTap;
  final bool isLoading;

  const UserSuggestionCard({
    super.key,
    this.avatarUrl,
    required this.userName,
    this.location,
    this.isFollowing = false,
    this.onTap,
    this.onFollowTap,
    this.onMoreTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar
            ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? CustomCacheImage(
                      imageUrl: avatarUrl!,
                      height: 40.h,
                      width: 40.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 40.h,
                      width: 40.w,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: 24.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (location != null && location!.isNotEmpty)
                    Text(
                      location!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            // Follow Button
            SmallFollowButton(
              isFollowing: isFollowing,
              onPressed: onFollowTap,
              isLoading: isLoading,
            ),
            // More Options
            if (onMoreTap != null)
              IconButton(
                onPressed: onMoreTap,
                icon: Icon(
                  Icons.more_vert,
                  size: 20.sp,
                  color: Colors.grey.shade600,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

