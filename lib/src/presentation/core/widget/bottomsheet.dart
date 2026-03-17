import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showDevBottomSheet(
    {required BuildContext context,
    required Widget child,
    required bool isfull}) {
  showModalBottomSheet(

    enableDrag: true,
    context: context,
    isScrollControlled: isfull,
    backgroundColor: AppColor.transparentColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
    ),
    builder: (context) => child,
  );
}