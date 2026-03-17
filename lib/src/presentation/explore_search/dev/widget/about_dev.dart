import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../data/model/explore/single_gods_model.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/custom_dots_indicator.dart';

class AboutDev extends StatefulWidget {
  AboutDev({super.key, this.singleGod});
  SingleGodModel? singleGod;

  @override
  State<AboutDev> createState() => _AboutDevState();
}

class _AboutDevState extends State<AboutDev> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.singleGod?.newDescription == ''
            ? const SizedBox.shrink()
            : Html(
                data: widget.singleGod?.newDescription ?? '',
              ),
        Gap(22.h),
        widget.singleGod?.images?.gallery == ''
            ? const SizedBox.shrink()
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(18.h),
            Text(
              StringConstant.gallery,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.bold),
            ),
            Gap(8.h),
            SizedBox(
              width: double.infinity,
              child: CarouselSlider.builder(
                itemCount: widget.singleGod?.images?.gallery?.length,
                itemBuilder: (context, index, realIndex) {
                  final item =
                  widget.singleGod?.images?.gallery?[index];
                  final imageUrl =
                      item?.image ?? StringConstant.defaultImage;
                  return ClipRRect(
                    child: Hero(
                      tag: 'image_$index',
                      child: CustomCacheImage(
                          borderRadius: BorderRadius.circular(5.r),
                          imageUrl: imageUrl),
                    ),
                  );
                },
                options: CarouselOptions(
                    height: 292.h,
                    viewportFraction: 1,
                    autoPlay: false,
                    autoPlayCurve: Curves.easeInOut,
                    autoPlayAnimationDuration:
                    const Duration(milliseconds: 700),
                    enableInfiniteScroll: false,
                    enlargeCenterPage: false,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    }),
              ),
            ),
            Gap(15.h),
            CustomDotsIndicator(
              currentIndex: currentIndex,
              itemCount:
              widget.singleGod?.images?.gallery?.length ?? 0,
              visibleCount: 5,
            )
          ],
        ),
        Gap(30.h),
        widget.singleGod?.aarti?.html?.isNotEmpty == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConstant.arti,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Gap(10.h),
                  Html(data: widget.singleGod?.aarti?.html ?? ''),
                  Gap(10.h),
                ],
              )
            : const SizedBox.shrink(),
        Gap(20.h)
      ],
    );
  }
}
