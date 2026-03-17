import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  VoidCallback onTap;
  String buttonAssets;
  String textButton;
   double fontSize;
  Color? textColor;
  Color? btnColor;
  BorderRadius? borderRadius;
  EdgeInsets? mypadding ;
  CustomButton({
    super.key,
    required this.onTap,
    required this.buttonAssets,
    required this.textButton,
    this.mypadding,
    this.textColor = AppColor.blackColor,
    this.btnColor = AppColor.lightGrayColor,
    this.borderRadius,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return     InkWell(
        onTap: onTap,
        child: Container(
          padding: mypadding,
          decoration: BoxDecoration(
            color: btnColor,
            border: Border.all(
              color: btnColor == AppColor.appbarBgColor
                  ? Colors.transparent
                  : AppColor.blackColor.withOpacity(0.1),
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (buttonAssets.isNotEmpty)
                Image.asset(buttonAssets.toString(), height: 24, width: 24),
              const Gap(10),
              Text(
                textButton.isEmpty ? "Click Button" : textButton.toString(),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                      color: textColor,
                    ),
              ),
            ],
          ),
        ),
      );
 
  }
}

class CustomRoundedButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? toPadding;
  final double elevation;
  final Gradient? gradient;
  final TextStyle? textStyle;
  final bool isLoading;

  const CustomRoundedButton({
    super.key,
    required this.onTap,
    this.text = "Post",
    this.icon,
    this.backgroundColor = AppColor.appbarBgColor,
    this.textColor = Colors.white,
    this.borderRadius = 20.0,
    this.padding,
    this.elevation = 3.0,
    this.gradient,
    this.textStyle,
    this.toPadding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIconOnly = icon != null && text.isEmpty;

    return Container(
      padding:
          toPadding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      alignment: Alignment.center,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(isIconOnly ? 100 : borderRadius),
        child: Material(
          elevation: elevation,
          borderRadius: BorderRadius.circular(borderRadius),
          color: isLoading ? Colors.grey.shade200 : backgroundColor,
          child: Container(
            width: isIconOnly ? 35.w : null,
            height: isIconOnly ? 35.w : null,
            padding: isIconOnly
                ? EdgeInsets.zero
                : (padding ??
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
            decoration: BoxDecoration(
              shape: isIconOnly ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  isIconOnly ? null : BorderRadius.circular(borderRadius),
              color: gradient == null
                  ? (isLoading ? Colors.grey : backgroundColor)
                  : null,
              gradient: isLoading ? null : gradient,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : isIconOnly
                      ? Icon(icon, color: textColor, size: 24.w)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: textColor, size: 18),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              text,
                              style: textStyle ??
                                  Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: textColor),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

//  button widget

Widget buildButton(
    {required String text,
    required Color color,
    required VoidCallback onTap,
    context}) {
  return SizedBox(
    height: 38.h,
    width: 93.w,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        side: BorderSide(
            color: color == AppColor.appbarBgColor
                ? Colors.transparent
                : AppColor.blackColor.withOpacity(0.1)),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: color == AppColor.appbarBgColor
                  ? AppColor.whiteColor
                  : AppColor.blackColor,
            ),
      ),
    ),
  );
}
//Chip

Widget buildChipTab({
  required String label,
  required int index,
  required int selectedTab,
  required BuildContext context,
  required Function(int) onTabSelected,
}) {
  final bool isSelected = selectedTab == index;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return ChoiceChip(
    label: Text(
      label,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color:  (isSelected ? Colors.white : Colors.black)

          ),
    ),
    selected: isSelected,
    selectedColor: isSelected
        ? AppColor.appbarBgColor
        : AppColor.appbarBgColor,
    backgroundColor: isSelected
        ? AppColor.whiteColor.withOpacity(0.1)
        : AppColor.appbarBgColor2,
    side: BorderSide(
      color: isSelected
          ? AppColor.appbarBgColor
          :  AppColor.appbarBorderColor2 ,
    ),
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    onSelected: (_) => onTabSelected(index),
  );
}

// New Design Button
Widget buildChipButton(
    String label, bool isSelected, VoidCallback onTap, context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDarkMode
                ? AppColor.whiteColor.withOpacity(0.1)
                : AppColor.appbarBgColor2)
            : (isDarkMode ? Colors.transparent : AppColor.whiteColor),
        border: Border.all(
          color: isSelected
              ? AppColor.appbarBorderColor2
              : (isDarkMode ? Colors.white30 : AppColor.blackColor),
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12.sp,
              color: isDarkMode
                  ? (isSelected ? Colors.black : Colors.white)
                  : AppColor.blackColor,
            ),
      ),
    ),
  );
}

//for icon

Widget rowIconText(
    {IconData? icon,
    String? text,
    Color? iconColor,
    required BuildContext context,
    final VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        Gap(5.h),
        Text(text!,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.whiteColor
                    : AppColor.lightTextColor)),
      ],
    ),
  );
}

// for image
Widget rowImageIcon(
    {String? imag,
    String? text,
    required BuildContext context,
    h,
    w,
    required double s,
    required bool isSVG,
    final VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      children: [
        isSVG
            ?  SvgPicture.asset(
                imag ?? 'assets/logo/app_logo.png',
                height: h,
                width: w,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.whiteColor
                    : null,
              )
            : Image.asset(
                imag ?? 'assets/logo/app_logo.png',
                height: h,
                width: w,
                fit: BoxFit.cover,
              ),
        Gap(s),
        Text(text ?? "",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.whiteColor
                  : AppColor.lightTextColor,
            )),
      ],
    ),
  );
}
