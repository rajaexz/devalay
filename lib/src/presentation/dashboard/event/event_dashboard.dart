
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_draft.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_approved.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_manage_temple.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_rejected.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_review_temple_widget.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_submitted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class EventViewDaraf extends StatefulWidget {
  const EventViewDaraf({super.key});

  @override
  State<EventViewDaraf> createState() => _EventViewDarafState();
}

class _EventViewDarafState extends State<EventViewDaraf> {
  int selectedIndex = 0;
  String? admin;
  bool isAdminLoaded = false;
  late ContributeEventCubit contributeEventCubit;

  @override
  void initState() {
    super.initState();
    contributeEventCubit = ContributeEventCubit();
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
          return const EventDraft();
        case 1:
          return const EventSubmitted();
        case 2:
          return const EventApproved();
        case 3:
          return const EventRejected();
        case 4:
          return const EventManageTemple();
        case 5:
          return const EventReviewTempleWidget();
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

