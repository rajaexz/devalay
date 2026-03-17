import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final int visibleCount;

  const CustomDotsIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    this.visibleCount = 5,
  });

  @override
  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox();

    int dotsToShow = itemCount < visibleCount ? itemCount : visibleCount;
    int startIndex = 0;
    int endIndex = itemCount;

    bool showLeftShadow = false;
    bool showRightShadow = false;

    if (itemCount > visibleCount) {
      int maxStartIndex = itemCount - visibleCount;
      startIndex = (currentIndex - (visibleCount ~/ 2)).clamp(0, maxStartIndex);
      endIndex = (startIndex + visibleCount).clamp(0, itemCount);
      dotsToShow = endIndex - startIndex;

      showLeftShadow = startIndex > 0;
      showRightShadow = endIndex < itemCount;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showLeftShadow) _buildShadowDot(),
        ...List.generate(dotsToShow, (i) {
          int dotIndex = itemCount <= visibleCount ? i : startIndex + i;
          bool isActive = dotIndex == currentIndex;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.sp),
            width: isActive ? 8.0.w : 6.0.w,
            height: isActive ? 8.0.h : 6.0.h,
            decoration: BoxDecoration(
              color: isActive ? AppColor.appbarBgColor : Colors.grey.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          );
        }),
        if (showRightShadow) _buildShadowDot(),
      ],
    );
  }

  Widget _buildShadowDot() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.sp),
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}
