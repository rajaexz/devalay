import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CloseButtonWidget extends StatelessWidget {
  const CloseButtonWidget({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: const Color(0xff1C274C).withOpacity(0.82),
            shape: BoxShape.circle,
            border: Border.all(color: accentColor),
          ),
          child: const Center(
            child: Icon(Icons.close, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
