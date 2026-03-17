import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomChoiceChipTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabSelected;
  final int initialIndex;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  const CustomChoiceChipTabBar({
    super.key,
    required this.tabs,
    required this.onTabSelected,
    this.initialIndex = 0,
    this.selectedColor = const Color(0xffEC9111),
    this.unselectedColor = const Color(0xffEC9111),
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = AppColor.appbarBgColor,
  });

  @override
  _CustomChoiceChipTabBarState createState() => _CustomChoiceChipTabBarState();
}

class _CustomChoiceChipTabBarState extends State<CustomChoiceChipTabBar> {
  int selectedChipIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedChipIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: 10.sp),
            child: ChoiceChip(
              autofocus: true,
              label: Text(widget.tabs[index]),
              labelStyle: TextStyle(
                  color: selectedChipIndex == index
                      ? widget.selectedTextColor
                      : widget.unselectedTextColor,
                  fontSize: 12),
              selected: selectedChipIndex == index,
              backgroundColor: widget.unselectedColor.withOpacity(0.2),
              selectedColor: widget.selectedColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              onSelected: (bool selected) {
                setState(() {
                  selectedChipIndex = index;
                });
                widget.onTabSelected(index);
              },
            ),
          );
        }),
      ),
    );
  }
}
