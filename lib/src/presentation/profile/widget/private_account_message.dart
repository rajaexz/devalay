import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma-style Private Account Message
/// Shows lock icon with "This account is private" message
class PrivateAccountMessage extends StatelessWidget {
  final String? customTitle;
  final String? customMessage;

  const PrivateAccountMessage({
    super.key,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock Icon
          Icon(
            Icons.lock_outline,
            size: 20.sp,
            color: Colors.black54,
          ),
          SizedBox(width: 14.w),
          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customTitle ?? 'This account is private',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  customMessage ?? 'Follow this account to see their post and connections',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

