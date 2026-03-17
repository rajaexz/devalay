import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BorderedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;
  final Color inactiveBorderColor;

  const BorderedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.blue,
    this.inactiveBorderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? activeColor : inactiveBorderColor,
          width: value ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(2.0.r),
      ),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        side: BorderSide.none, // Remove default checkbox border
        fillColor: MaterialStateProperty.all(Colors.white),
        checkColor: activeColor,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
