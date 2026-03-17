import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/profile/likes/widget/devs_screen.dart';
import 'package:devalay_app/src/presentation/profile/likes/widget/events_screen.dart';
import 'package:devalay_app/src/presentation/profile/likes/widget/festival_screen.dart';
import 'package:devalay_app/src/presentation/profile/likes/widget/post_screen.dart';
import 'package:devalay_app/src/presentation/profile/likes/widget/temples_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  int selectedIndex = 0;
  final List<String> tabTitle = [
    StringConstant.temples,
    StringConstant.events,
    StringConstant.festival,
    StringConstant.dev,
    StringConstant.post,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(10.h),
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: tabTitle.length,
                separatorBuilder: (context, index) => Gap(10.w),
                itemBuilder: (context, index) => _buildChipTab(tabTitle[index], index),
              ),
            ),
            Gap(10.h),
            Expanded(
              child: getSelectedWidget(selectedIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const TemplesScreen();
      case 1:
        return const EventsScreen();
      case 2:
        return const FestivalScreen();
      case 3:
        return const DevsScreen();
      case 4:
        return const PostScreen();
      default:
        return const SizedBox();
    }
  }
  Widget _buildChipTab(String label, int index) {
    final bool isSelected = selectedIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child:   ChoiceChip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isSelected ? AppColor.whiteColor : AppColor.blackColor,
            ),
      ),
      selected: isSelected,
      selectedColor: AppColor.appbarBgColor,
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : AppColor.appbarBgColor .withOpacity(0.1),
      ),
      backgroundColor: isSelected
          ? AppColor.greyColor.withOpacity(0.08)
          : AppColor.appbarBgColor2,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      visualDensity: VisualDensity.compact, // minimizes space usage
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap, // reduces touch area height
      onSelected: (_) => setState(() => selectedIndex = index),
    )
    );
    }
}


