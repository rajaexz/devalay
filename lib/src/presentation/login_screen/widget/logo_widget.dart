import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        child: SvgPicture.asset(
          "assets/logo/DEVALAY 1.svg",
          height: 100.h,
        color: const Color(0xfff58148),
        ));
  }
}