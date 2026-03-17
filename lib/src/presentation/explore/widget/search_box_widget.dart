import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBoxWidget extends StatelessWidget {
  const SearchBoxWidget({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.onChanged,
    required this.onTap,
    required this.hintText,
  });
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function() onTap;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: TextField(
        controller: textEditingController,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: AppColor.greyColor),
          ),
          suffixIcon: InkWell(
            onTap: onTap,
            child:  Icon(
              CupertinoIcons.search,
              color:Theme.of(context).brightness == Brightness.dark ?  AppColor.whiteColor:Colors.black ,

            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
