import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomSignInField extends StatelessWidget {
  CustomSignInField({
    super.key,
    this.height = 70,
    this.keyboardType,
    required this.controller,
    required this.hintText,
    this.validator,
    this.onChanged,
    this.vertical,
    this.horizontal,
    this.showErrorInField = true,
  });

  double? height;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool showErrorInField;
  final double? vertical;
  final double? horizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        autovalidateMode: showErrorInField
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        controller: controller,
        keyboardType: keyboardType,
        
        maxLength: 10,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.symmetric(vertical: vertical??0, horizontal: horizontal??12.sp),
          focusColor: AppColor.orangeColor,
          filled: true,
          fillColor: AppColor.transparentColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.r),
          ),
          errorStyle: showErrorInField
              ? null
              : const TextStyle(height: 0, color: Colors.transparent),
          hintText: hintText,
          hintStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColor.placeHolderColor.withOpacity(0.6)),
        ),
        validator: validator,
      ),
    );
  }
}