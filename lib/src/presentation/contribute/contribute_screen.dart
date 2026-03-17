
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/presentation/contribute/contribution_bottomsheet.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ContributeScreen extends StatelessWidget {
  const ContributeScreen({super.key});

  @override
  Widget build(BuildContext context) {


  Future<void> loadUserImage() async {
  }

    loadUserImage();
    void showDevalayBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColor.transparentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        builder: (context) => const ContributionBottomsheet(),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(
          side: BorderSide(color: AppColor.orangeColor, width: 2.sp),
        ),
        onPressed: () {
          showDevalayBottomSheet();
        },
        backgroundColor: AppColor.whiteColor,
        child: Icon(Icons.add, color: AppColor.orangeColor, size: 40.sp),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      


          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(10.h),
                  commonBox(context, () {
                    AppRouter.push(RouterConstant.contributeTemple);
                  },
                      StringConstant.temples,
                      StringConstant.addeByYou,
                      StringConstant.monitored,
                      StringConstant.pendingForApproval,
                      'assets/background/temple_bg.png'),
                  Gap(10.h),
                  commonBox(context, () {
                    AppRouter.push(RouterConstant.contributeEvents);
                  },
                      StringConstant.events,
                      StringConstant.addeByYou,
                      StringConstant.monitored,
                      StringConstant.pendingForApproval,
                      "assets/background/event1.png"),
                  Gap(10.h),
                  commonBox(context, () {
                    AppRouter.push(RouterConstant.contributePujas);
                  },
                      StringConstant.pujas,
                      StringConstant.addeByYou,
                      StringConstant.monitored,
                      StringConstant.pendingForApproval,
                      'assets/background/puja_bg.png'),
                  Gap(10.h),
                  commonBox(context, () {
                    AppRouter.push(RouterConstant.contributeFestivals);
                  },
                      StringConstant.festival,
                      StringConstant.addeByYou,
                      StringConstant.monitored,
                      StringConstant.pendingForApproval,
                      'assets/background/festival_bg.png'),
                  Gap(10.h),
                  commonBox(context, () {
                    AppRouter.push(RouterConstant.contributeDevs);
                  },
                      StringConstant.dev,
                      StringConstant.addeByYou,
                      StringConstant.monitored,
                      StringConstant.pendingForApproval,
                      'assets/background/dev_bg.png'),
                  Gap(10.h),
                  commonBox(context, () {
                 
                  }, StringConstant.donation, '', '', '',
                      'assets/background/donation_bg.png'),
                  Gap(50.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget commonBox(
      BuildContext context,
      VoidCallback onTap,
      String firstHeading,
      String secondHeading,
      String thirdHeading,
      String fourthHeading,
      String imageUrl) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.sp),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColor.lightTextColor
                : const Color(0xffFDF3DE),
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 20.sp, top: 20.sp, right: 10.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(firstHeading,
                            style: Theme.of(context).textTheme.labelMedium),
                        Gap(15.h),
                        Text(secondHeading,
                            style: Theme.of(context).textTheme.bodySmall),
                        Gap(5.h),
                        Text(thirdHeading,
                            style: Theme.of(context).textTheme.bodySmall),
                        Gap(5.h),
                        Text(fourthHeading,
                            style: Theme.of(context).textTheme.bodySmall),
                      ]),
                ),
                Image.asset(imageUrl, height: 120, width: 120)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
