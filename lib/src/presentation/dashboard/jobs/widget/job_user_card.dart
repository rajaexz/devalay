import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/widget/custom_cache_image.dart';

/// Job User Card - Figma Design
/// Shows user info with avatar, name, location, followers
class JobUserCard extends StatelessWidget {
  final String? userName;
  final String? userLocation;
  final String? userAvatar;
  final String? followersCount;
  final String? postsCount;
  final String? phoneNumber;
  final String? address;
  final String? dateTime;
  final bool showPhoneNumber;

  const JobUserCard({
    super.key,
    this.userName,
    this.userLocation,
    this.userAvatar,
    this.followersCount,
    this.postsCount,
    this.phoneNumber,
    this.address,
    this.dateTime,
    this.showPhoneNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // Avatar
              ClipOval(
                child: userAvatar != null && userAvatar!.isNotEmpty
                    ? CustomCacheImage(
                        imageUrl: userAvatar!,
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 48.w,
                        height: 48.h,
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                          size: 28.sp,
                        ),
                      ),
              ),
              Gap(12.w),
              
              // Name and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'User Name',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (userLocation != null) ...[
                      Gap(2.h),
                      Text(
                        userLocation!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (followersCount != null || postsCount != null) ...[
                      Gap(2.h),
                      Text(
                        '${followersCount ?? "0"} followers  ${postsCount ?? "0"} posts',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Phone Number
          if (showPhoneNumber && phoneNumber != null) ...[
            Gap(16.h),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: phoneNumber!,
            ),
          ],
          
          // Location/Address
          if (address != null) ...[
            Gap(12.h),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: address!,
            ),
          ],
          
          // Date & Time
          if (dateTime != null) ...[
            Gap(12.h),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date & Time',
              value: dateTime!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: Colors.grey.shade600,
        ),
        Gap(8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Gap(2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple User Info Section (without card)
class JobUserInfoSection extends StatelessWidget {
  final String? userName;
  final String? phoneNumber;
  final String? address;
  final String? dateTime;

  const JobUserInfoSection({
    super.key,
    this.userName,
    this.phoneNumber,
    this.address,
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Name
        if (userName != null)
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'User Name',
            value: userName!,
          ),
        
        // Location
        if (address != null) ...[
          Gap(16.h),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: address!,
          ),
        ],
        
        // Date & Time
        if (dateTime != null) ...[
          Gap(16.h),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & Time',
            value: dateTime!,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Colors.grey.shade700,
        ),
        Gap(14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Gap(2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

