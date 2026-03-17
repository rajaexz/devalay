import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';

class EventCompleteScreen extends StatelessWidget {
  const EventCompleteScreen({super.key, this.devId, this.calledFrom});
  final String? calledFrom;
  final String? devId;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap(100.h),
        CustomCacheImage(
          imageUrl:
              'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/assets/thanks.png',
          color: AppColor.transparentColor,
          height: 200.h,
          width: 200.w,
        ),
        Gap(30.h),
        Align(
          alignment: Alignment.center,
          child: Text(StringConstant.yourContributionHasbeen,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center),
        ),
        Gap(50.h),
        GestureDetector(
            onTap: () async {
              //        (calledFrom == 'review')

              (calledFrom == 'review')
                  ? context
                      .read<ContributeEventCubit>()
                      .fetchSingleContributeEventData(devId!, value: 'true')
                  : context
                      .read<ContributeEventCubit>()
                      .fetchSingleContributeEventData(devId!, value: 'false');
              Navigator.pop(context);
            },
            child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.sp, vertical: 5.sp),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    gradient: const LinearGradient(colors: [
                      AppColor.gradientDarkColor,
                      AppColor.appbarBgColor
                    ])),
                child: Text(StringConstant.done,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColor.whiteColor)))),
        const Spacer(),
        Center(
            child: Container(
                height: 10.h,
                width: 180.w,
                decoration: BoxDecoration(
                    color: AppColor.blackColor,
                    borderRadius: BorderRadius.circular(6.r))))
      ],
    );
  }
}
