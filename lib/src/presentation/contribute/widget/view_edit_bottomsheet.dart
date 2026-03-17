import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ViewEditBottomsheet extends StatelessWidget {
  const ViewEditBottomsheet(
      {super.key,
      required this.viewTap,
      required this.editTap,
      required this.deleteTap});
  final VoidCallback viewTap;
  final VoidCallback editTap;
  final VoidCallback deleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: accentColor, width: 2),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(15.h),
            Container(
              height: 5.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: AppColor.blackColor,
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            Gap(15.h),
            InkWell(
              onTap: viewTap,
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined),
                  Gap(10.w),
                  const Text('View')
                ],
              ),
            ),
            Gap(20.h),
            InkWell(
                onTap: editTap,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined),
                    Gap(10.w),
                    const Text('Edit')
                  ],
                )),
            Gap(20.h),
            InkWell(
              onTap: deleteTap,
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  Gap(10.w),
                   Text(  StringConstant.delete)
                ],
              ),
            ),
            Gap(30.h),
          ],
        ),
      ),
    );
  }
}
