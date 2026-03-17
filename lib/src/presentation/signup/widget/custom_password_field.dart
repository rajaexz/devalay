import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomPasswordField extends StatelessWidget {
  CustomPasswordField(
      {super.key,
      required this.controller,
      required this.obscure,
      required this.icon,
      required this.onPressed,
      this.focusNode,
      required this.hint});
  final TextEditingController controller;
  final bool obscure;
  final IconData icon;
  FocusNode? focusNode;
  final Function()? onPressed;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.sp),
      child: SizedBox(
        height: 70.h,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          obscureText: obscure,
          focusNode: focusNode,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: 12.sp),
            focusColor: const Color(0xff1F41BB),
            filled: true,
            fillColor: AppColor.transparentColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xff1F41BB), width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            hintText: hint,
            hintStyle: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColor.placeHolderColor.withOpacity(0.6)),
            suffixIcon: IconButton(
                icon: Icon(
                  icon,
                  color: AppColor.orangeColor,
                ),
                onPressed: onPressed),
          ),
        ),
      ),
    );
  }
}
