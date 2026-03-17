import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../data/model/explore/single_event_model.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/custom_dots_indicator.dart';

class AboutEvent extends StatefulWidget {
  AboutEvent({super.key, required this.singleEvent});
  SingleEventModel? singleEvent;

  @override
  State<AboutEvent> createState() => _AboutEventState();
}

class _AboutEventState extends State<AboutEvent> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.singleEvent?.description == ''
            ? const SizedBox.shrink()
            : Text(
          widget.singleEvent?.description ?? '',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Gap(30.h),
        widget.singleEvent?.howToCelebrate?.isNotEmpty == true
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstant.howToCelebrate,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                  color: AppColor.blackColor, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            Text(
              widget.singleEvent?.howToCelebrate ?? '',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
            Gap(10.h),
          ],
        )
            : const SizedBox.shrink(),
        widget.singleEvent?.dos?.isNotEmpty == true
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              StringConstant.dos,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                  color: AppColor.blackColor, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            Text(
              widget.singleEvent?.dos ?? '',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
            Gap(10.h),
          ],
        )
            : const SizedBox.shrink(),
        widget.singleEvent?.donts?.isNotEmpty == true
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstant.donts,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                  color: AppColor.blackColor, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            Text(
              widget.singleEvent?.dos ?? '',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
            Gap(10.h),
          ],
        )
            : const SizedBox.shrink(),
        widget.singleEvent?.images?.gallery?.isNotEmpty == true
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstant.gallery,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                  color: AppColor.blackColor, fontWeight: FontWeight.bold),
            ),
            Gap(8.h),
            SizedBox(
              width: double.infinity,
              child: CarouselSlider.builder(
                itemCount: widget.singleEvent?.images?.gallery?.length,
                itemBuilder: (context, index, realIndex) {
                  final item =
                  widget.singleEvent?.images?.gallery?[index];
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
                    onPageChanged: (index, reason){
                      setState(() {
                        currentIndex = index;
                      });
                    }
                ),),
            ),
            Gap(15.h),
            CustomDotsIndicator(currentIndex: currentIndex, itemCount: widget.singleEvent?.images?.gallery?.length ?? 0, visibleCount: 5,)
          ],
        )
            : const SizedBox.shrink(),
        Gap(20.h)
      ],
    );
  }
}
