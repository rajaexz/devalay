import 'package:devalay_app/src/presentation/explore/widget/custom_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterHeaderWidget extends StatelessWidget {
  const FilterHeaderWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 20.sp),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ,
          ),
        ),
        const CustomDivider(),
      ],
    );
  }
}
