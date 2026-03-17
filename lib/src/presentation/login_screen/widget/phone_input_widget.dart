import 'package:country_code_picker/country_code_picker.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/signup/widget/custom_sigin_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable phone input widget with country code picker.
/// 
/// Usage:
/// ```dart
/// PhoneInputWidget(
///   controller: phoneController,
///   error: phoneError,
///   onCountryChanged: (code) => selectedCountryCode = code,
///   onPhoneChanged: (value) => setState(() => phoneError = null),
/// )
/// ```
class PhoneInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final String initialCountryCode;
  final ValueChanged<String>? onCountryChanged;
  final ValueChanged<String>? onPhoneChanged;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.error,
    this.initialCountryCode = 'IN',
    this.onCountryChanged,
    this.onPhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInputContainer(context),
        if (error != null) _buildErrorText(),
      ],
    );
  }

  Widget _buildInputContainer(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: error != null ? Colors.red : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCountryPicker(),
          _buildDivider(),
          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildCountryPicker() {
    return Center(
      child: CountryCodePicker(
        onChanged: (countryCode) {
          onCountryChanged?.call(countryCode.dialCode ?? '+91');
        },
        initialSelection: initialCountryCode,
        favorite: const ['+91', 'IN'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
          fontSize: 16.sp,
          color: AppColor.blackColor,
        ),
        flagWidth: 25.w,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50.h,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildPhoneField() {
    return Expanded(
      child: CustomSignInField(
        height: 50,
        keyboardType: TextInputType.number,
        validator: null,
        controller: controller,
        hintText: StringConstant.enterPhonePlaceholder, // this text too large 
        

        vertical: 14.sp,
        horizontal: 10.sp,
        onChanged: onPhoneChanged,
      ),
    );
  }

  Widget _buildErrorText() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error!,
          style: TextStyle(
            color: Colors.red,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

