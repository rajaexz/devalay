import 'package:devalay_app/src/presentation/contribute/widget/icon_text_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/explore/widget/close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../create/create_temple/create_temple_screen.dart';
import 'add_dev/devs_widget/add_dev_screen.dart';
import 'add_event/events_widget/add_event_screen.dart';
import 'add_festival/festival_widget/add_festival_screen.dart';
import 'add_puja/puja_widget/add_puja_screen.dart';

class ContributionBottomsheet extends StatelessWidget {
  const ContributionBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CloseButtonWidget(onTap: () => Navigator.pop(context)),
        Gap(10.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            border: Border.all(color: accentColor, width: 2.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(20.h),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 50.sp, vertical: 30.sp),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateTemple()));
                            },
                            imageUrl:
                                'https://d3nvzmos5mh5ca.cloudfront.net/devalay/static/images/svg/add_devalay.svg',
                            text: StringConstant.temples),
                        IconTextWidget(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddEventScreen()));
                            },
                            imageUrl:
                                'https://d3nvzmos5mh5ca.cloudfront.net/devalay/static/images/svg/add_event.svg',
                            text: StringConstant.events),
                        IconTextWidget(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddPujaScreen()));
                            },
                            imageUrl:
                                'https://d3nvzmos5mh5ca.cloudfront.net/devalay/static/images/svg/add_puja.svg',
                            text: StringConstant.pujas),
                      ],
                    ),
                    Gap(50.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFestivalScreen()));
                            },
                            imageUrl:
                                'https://d3nvzmos5mh5ca.cloudfront.net/devalay/static/images/svg/add_festival.svg',
                            text: StringConstant.festivals),
                        IconTextWidget(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDevScreen()));
                            },
                            imageUrl:
                                'https://d3nvzmos5mh5ca.cloudfront.net/devalay/static/images/svg/add_dev.svg',
                            text: StringConstant.dev),
                        IconTextWidget(
                            onTap: () {},
                            imageUrl:
                                'https://d3nvzmos5mh5ca.cloudfront.net/devalay/static/images/svg/add_puja.svg',
                            text: StringConstant.donation)
                      ],
                    ),
                  ],
                ),
              ),
              Gap(20.h)
            ],
          ),
        ),
      ],
    );
  }
}
