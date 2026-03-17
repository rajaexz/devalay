
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/dashboard/god/dev_approved.dart';
import 'package:devalay_app/src/presentation/dashboard/god/dev_daraf.dart';
import 'package:devalay_app/src/presentation/dashboard/god/dev_manage.dart';
import 'package:devalay_app/src/presentation/dashboard/god/dev_rejected.dart';
import 'package:devalay_app/src/presentation/dashboard/god/dev_review.dart';
import 'package:devalay_app/src/presentation/dashboard/god/dev_submitted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class DevView extends StatefulWidget {
  const DevView({super.key});

  @override
  State<DevView> createState() => _DevViewState();
}

class _DevViewState extends State<DevView> {
 

  int selectedIndex = 0;
  String? admin;
  bool isAdminLoaded = false;
  late ContributeDevCubit contributeDevCubit;

  @override
  void initState() {
    super.initState();
    contributeDevCubit = ContributeDevCubit();
    getAdmin();
  }

  //get admin

  Future<void> getAdmin() async {
    admin = await PrefManager.getAdmin();
    admin == 'true';
    setState(() {
      isAdminLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget buildChipTab(String label, int index) {
      final bool isSelected = selectedIndex == index;
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            label: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(),
            ),
            selected: isSelected,
            selectedColor: AppColor.appbarBgColor2,
            side: BorderSide(
              color: isSelected
                  ? AppColor.appbarBgColor2
                  : AppColor.blackColor.withOpacity(0.1),
            ),
            backgroundColor: isSelected
                ? AppColor.appbarBgColor2.withOpacity(0.1)
                : AppColor.whiteColor,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            visualDensity: VisualDensity.compact, // minimizes space usage
            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap, // reduces touch area height
            onSelected: (_) => setState(() => selectedIndex = index),
          ));
    }

    List<String> tabTitle = isAdminLoaded && admin == 'true'
        ? [
            StringConstant.darft,
            StringConstant.submit,
            StringConstant.approved,
            StringConstant.rejected,
            StringConstant.manageTemple,
            StringConstant.reviewTemple,
          ]
        : [
            StringConstant.darft,
            StringConstant.submit,
            StringConstant.approved,
            StringConstant.rejected,
          ];

    Widget getSelectedWidget(int index) {
      switch (index) {
        case 0:
          return const DevDaraf();
        case 1:
          return const DevSubmitted();
        case 2:
          return const DevApproved();
        case 3:
          return const DevRejected();
        case 4:
          return const DevManage();
        case 5:
          return const DevReview();
        default:
          return  SizedBox(child: Text(StringConstant.noDataAvailable),);
      }
    }

    return Column(
      children: [
        Gap(10.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            //make Curve to the left and right
            clipBehavior: Clip.antiAlias,

            scrollDirection: Axis.horizontal,
            itemCount: tabTitle.length,
            itemBuilder: (context, index) {
              return buildChipTab(tabTitle[index], index);
            },
          ),
        ),

        Gap(10.h),
        Expanded(child: getSelectedWidget(selectedIndex))
        // Add more ItemCarts as needed
      ],
    );
  }
}



