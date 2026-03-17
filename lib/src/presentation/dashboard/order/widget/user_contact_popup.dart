import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// User Contact Info Popup - Figma Design
/// Shows Email ID and Contact Number in a popup card
class UserContactPopup extends StatelessWidget {
  final String? email;
  final String? contactNumber;

  const UserContactPopup({
    super.key,
    this.email,
    this.contactNumber,
  });

  static void show(BuildContext context, {String? email, String? contactNumber}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => UserContactPopup(
        email: email,
        contactNumber: contactNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email ID
            _buildContactRow(
              icon: Icons.person_outline,
              label: 'Email Id',
              value: email ?? 'N/A',
            ),
            Gap(10.h),
            
            // Contact Number
            _buildContactRow(
              icon: Icons.person_outline,
              label: 'Contact Number',
              value: contactNumber ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: Colors.black.withOpacity(0.9),
            ),
            Gap(8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          ],
        ),
        Gap(4.h),
        Padding(
          padding: EdgeInsets.only(left: 28.w),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

