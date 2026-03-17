import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CommonHeaderText extends StatelessWidget {
  const CommonHeaderText(
      {super.key, required this.title, required this.progress});
  final String title;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            Text('$progress %', style: Theme.of(context).textTheme.bodyMedium)
          ],
        ),
        Gap(10.h),
        LinearProgressIndicator(
          value: progress / 100,
          minHeight: 6,
          backgroundColor: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5.r),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
        Gap(40.h)
      ],
    );
  }
}
