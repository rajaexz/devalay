import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma-style Profile Options Menu (Block/Report dropdown)
class ProfileOptionsMenu extends StatelessWidget {
  final VoidCallback? onBlock;
  final VoidCallback? onReport;
  final Color? iconColor;

  const ProfileOptionsMenu({
    super.key,
    this.onBlock,
    this.onReport,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: iconColor ?? Colors.black87,
        size: 24.sp,
      ),
      offset: Offset(0, 40.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      elevation: 4,
      onSelected: (value) {
        switch (value) {
          case 'block':
            onBlock?.call();
            break;
          case 'report':
            onReport?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'block',
          height: 40.h,
          child: Row(
            children: [
              Icon(
                Icons.block_outlined,
                size: 20.sp,
                color: Colors.black87,
              ),
              SizedBox(width: 10.w),
              Text(
                'Block',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'report',
          height: 40.h,
          child: Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 20.sp,
                color: Colors.black87,
              ),
              SizedBox(width: 10.w),
              Text(
                'Report',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shows block confirmation dialog
Future<bool?> showBlockConfirmationDialog(BuildContext context, String userName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Block $userName?'),
      content: Text(
        'They won\'t be able to find your profile, posts or stories. '
        'They won\'t be notified that you blocked them.',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Block',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

/// Shows report options dialog
Future<String?> showReportOptionsDialog(BuildContext context) {
  final reasons = [
    'Spam',
    'Nudity or sexual activity',
    'Hate speech or symbols',
    'Violence or dangerous organizations',
    'Bullying or harassment',
    'False information',
    'Scam or fraud',
    'Other',
  ];

  return showModalBottomSheet<String>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Why are you reporting this account?',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ...reasons.map(
            (reason) => ListTile(
              title: Text(
                reason,
                style: TextStyle(fontSize: 14.sp),
              ),
              onTap: () => Navigator.pop(context, reason),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    ),
  );
}

