import 'package:carousel_slider/carousel_slider.dart';
import 'package:devalay_app/src/data/model/explore/single_festival_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/custom_dots_indicator.dart';

class AboutFestival extends StatefulWidget {
  const AboutFestival({super.key, this.singleFestival});
  final SingleFestivalModel? singleFestival;
  @override
  State<AboutFestival> createState() => _AboutFestivalState();
}

class _AboutFestivalState extends State<AboutFestival> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.singleFestival?.newDescription == ''
            ? const SizedBox.shrink()
            : Html(
          data:  widget.singleFestival?.newDescription ??
              '',
        ),
        Gap(22.h),
        (widget.singleFestival?.images?.gallery == null ||
                widget.singleFestival!.images!.gallery!.isEmpty)
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
                itemCount: widget.singleFestival?.images?.gallery?.length ?? 0,
                itemBuilder: (context, index, realIndex) {
                  final item =
                  widget.singleFestival?.images?.gallery?[index];
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
              widget.singleFestival?.images?.gallery?.length ?? 0,
              visibleCount: 5,
            )
          ],
        ),
        Gap(20.h),
      ],
    );
  }
}
