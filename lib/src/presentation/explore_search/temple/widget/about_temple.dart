import 'package:carousel_slider/carousel_slider.dart';
import 'package:devalay_app/src/presentation/explore_search/widget/custom_dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../data/model/explore/single_devalay_model.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../../core/widget/translatable_text_widget.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key, required this.singleDevalay});
  final SingleDevalyModel? singleDevalay;

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.singleDevalay?.description == ''
            ? const SizedBox.shrink()
            : TranslatableTextWidget(
                text: widget.singleDevalay?.description ?? '',
                style: Theme.of(context).textTheme.labelSmall,
              ),
        widget.singleDevalay?.legend == ''
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(18.h),
                  Text(
                    StringConstant.legend,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Gap(8.h),
                  TranslatableTextWidget(
                    text: widget.singleDevalay?.legend ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  // Gap(8.h),
                  // AspectRatio(
                  //   aspectRatio: 4.sp / 3.sp,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount:
                  //         widget.singleDevalay?.images?.gallery?.length ?? 0,
                  //     itemBuilder: (context, index) {
                  //       final descriptionItem =
                  //           widget.singleDevalay?.images?.gallery?[1];
                  //
                  //       return AspectRatio(
                  //         aspectRatio: 4.sp / 3.sp,
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             ImageHelper.showImagePreview(
                  //                 context, descriptionItem?.image);
                  //           },
                  //           child: CustomCacheImage(
                  //               borderRadius: BorderRadius.circular(5.r),
                  //               imageUrl: descriptionItem?.image),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
        (widget.singleDevalay?.images?.gallery == null ||
                widget.singleDevalay!.images!.gallery!.isEmpty)
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
                      itemCount: widget.singleDevalay?.images?.gallery?.length ?? 0,
                      itemBuilder: (context, index, realIndex) {
                        final item =
                            widget.singleDevalay?.images?.gallery?[index];
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
                        widget.singleDevalay?.images?.gallery?.length ?? 0,
                    visibleCount: 5,
                  )
                ],
              ),
        widget.singleDevalay?.etymology == ''
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(18.h),
                  Text(
                    StringConstant.etymology,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Gap(8.h),
                  TranslatableTextWidget(
                    text: widget.singleDevalay?.etymology ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
        widget.singleDevalay?.templeHistory == ''
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(18.h),
                  Text(
                    StringConstant.history,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Gap(8.h),
                  TranslatableTextWidget(
                    text: widget.singleDevalay?.templeHistory ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
        widget.singleDevalay?.architecture == ''
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(18.h),
                  Text(
                    StringConstant.architecture,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Gap(8.h),
                  TranslatableTextWidget(
                    text: widget.singleDevalay?.architecture ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
        widget.singleDevalay?.governedBy?.description == ''
            ? const SizedBox.shrink()
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(18.h),
            Text(
              StringConstant.governingBodyCommission,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.bold),
            ),
            Gap(8.h),
            TranslatableTextWidget(
              text: widget.singleDevalay?.governedBy?.description ?? '',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        Gap(20.h)
      ],
    );
  }
}
