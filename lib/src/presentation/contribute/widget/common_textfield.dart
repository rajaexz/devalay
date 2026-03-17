import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonTextfield extends StatelessWidget {
  const CommonTextfield({
    super.key,
    this.title,
    this.hintText,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.isEnabled = false,
    this.focusNode,
    this.keyboardType,
    this.maxLength,
    this.prefixText,
    this.readOnly,
    this.validator,
    this.onChanged,
    this.isRequired = false,
  });

  final String? title;
  final TextEditingController controller;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool? readOnly;
  final int? maxLength;
  final String? prefixText;
  final TextInputType? keyboardType;
  final bool isEnabled;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (Figma style)
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: RichText(
              text: TextSpan(
                text: title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF374151),
                ),
                children: isRequired
                    ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFFFF9500),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        // Input field (Figma style)
        if (!isEnabled)
          Container(
            constraints: BoxConstraints(
              minHeight: 42.h,
              maxHeight: maxLines != null ? (maxLines! * 20.h) + 22.h : double.infinity,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: AppColor.blackColor,
                  selectionColor: AppColor.greyColor.withOpacity(0.4),
                  selectionHandleColor: AppColor.greyColor,
                ),
              ),
              child: TextFormField(
                cursorColor: AppColor.blackColor,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: controller,
                minLines: minLines,
                maxLines: maxLines,
                maxLength: maxLength,
                validator: validator,
                onChanged: onChanged,
                focusNode: focusNode,
                readOnly: readOnly ?? false,
                keyboardType: keyboardType,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixText: prefixText,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 12.w,
                  ),
                  // Figma border styling
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFD1D5DB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF9500),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}