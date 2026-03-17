import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/drawer/widget/guidelines_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/privacy_policy.dart';
import 'package:devalay_app/src/presentation/drawer/widget/terms_and_conditions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// A reusable widget for terms & conditions checkbox with clickable links.
/// 
/// Usage:
/// ```dart
/// TermsCheckboxWidget(
///   isAccepted: isTermsAccepted,
///   onChanged: (value) => setState(() => isTermsAccepted = value),
/// )
/// ```
class TermsCheckboxWidget extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.isAccepted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckbox(),
        Gap(8.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: _buildTermsText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox() {
    return SizedBox(
      height: 24.h,
      width: 24.w,
      child: Checkbox(
        value: isAccepted,
        onChanged: (value) => onChanged(value ?? false),
        activeColor: AppColor.appbarBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 13.sp,
      color: AppColor.blackColor,
      height: 1.4,
    );

    final linkStyle = TextStyle(
      fontSize: 13.sp,
      color: AppColor.appbarBgColor,
      fontWeight: FontWeight.w600,
    );

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: StringConstant.iAgreeToThe),
          _buildLinkSpan(
            context: context,
            text: StringConstant.termsOfUse,
            style: linkStyle,
            screen: const TermsAndConditions(),
          ),
          const TextSpan(text: ', '),
          _buildLinkSpan(
            context: context,
            text: StringConstant.privacyPolicy,
            style: linkStyle,
            screen: const DevalayApiExample(),
          ),
          TextSpan(text: StringConstant.commaAnd),
          _buildLinkSpan(
            context: context,
            text: StringConstant.communityGuidelines,
            style: linkStyle,
            screen: const GuidelinesScreen(),
          ),
        ],
      ),
    );
  }

  WidgetSpan _buildLinkSpan({
    required BuildContext context,
    required String text,
    required TextStyle style,
    required Widget screen,
  }) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
        child: Text(text, style: style),
      ),
    );
  }
}

