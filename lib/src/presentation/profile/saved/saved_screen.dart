import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/profile/saved/widget/devs_screen.dart';
import 'package:devalay_app/src/presentation/profile/saved/widget/festival_screen.dart';
import 'package:devalay_app/src/presentation/profile/saved/widget/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../saved/widget/events_screen.dart';
import '../saved/widget/temples_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int selectedIndex = 0;
  List<String> tabTitle = [
    StringConstant.temples,
    StringConstant.events,
    StringConstant.gods,
    StringConstant.festivals,
    StringConstant.post,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gap(20.h),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 10.sp),
          child: SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabTitle.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: buildChipTab(
                      label: tabTitle[index],
                      index: index,
                      selectedTab: selectedIndex,
                      context: context,
                      onTabSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ));
              },
            ),
          ),
        ),
        Gap(10.h),
        Expanded(child: getSelectedWidget(selectedIndex))
      ],
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const TemplesScreen();
      case 1:
        return const EventsScreen();
      case 2:
        return const DevsScreen();
      case 3:
        return const FestivalScreen();
      case 4:
        return const PostScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
