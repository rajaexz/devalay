import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../contribute/add_temple/temple/draft_temple_widget.dart';
import '../../profile/widget/custom_tabbar.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  int selectedIndex = 0;
  List<String> tabTitle = [
    "General",
    "Account",
    "Payment",
    "Services",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appbarBgColor,
        elevation: 0,
        title: const Text(
          "Help Center",
          style: TextStyle(color: AppColor.whiteColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(10.h),
            CustomChoiceChipTabBar(
                tabs: tabTitle,
                onTabSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                }),
            Expanded(child: getSelectedWidget(selectedIndex))
          ],
        ),
      ),
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text("General"),);
      case 1:
        return const Center(child: Text("Account"),);
      case 2:
        return const Center(child: Text("Payment"),);
      case 3:
        return const Center(child: Text("Services"),);

      default:
        return const DraftTempleWidget();
    }
  }
}
