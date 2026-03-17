import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../core/helper/image_Helper.dart';
import '../../core/widget/custom_cache_image.dart';
import '../../core/widget/translatable_text_widget.dart';

class CustomTile extends StatefulWidget {
  final String imageUrl;
  final String? location;
  final String title;
  final String? dateRange;
  final int likes;
  final int bookmarks;
  final int? viewedCount;
  final VoidCallback boxOnTap;
  final VoidCallback favoriteOnTap;
  final bool isLiked;
  final bool isSaved;
  // final VoidCallback shareOnTap;
  final VoidCallback? saveOnTap;

  const CustomTile({
    super.key,
    required this.boxOnTap,
    required this.imageUrl,
    this.location,
    required this.title,
    this.dateRange,
    required this.likes,
    required this.bookmarks,
    this.viewedCount,
    required this.isLiked,
    required this.isSaved,
    required this.favoriteOnTap,
    // required this.shareOnTap,
    this.saveOnTap,
  });

  @override
  State<CustomTile> createState() => _CustomTileState();
}

class _CustomTileState extends State<CustomTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.sp),
      child: InkWell(
        onTap: widget.boxOnTap,
        child: Row(
          children: [
            SizedBox(
              height: 86.h,
              child: GestureDetector(
                onDoubleTap: () {
                  ImageHelper.showImagePreview(
                    context,
                    widget.imageUrl,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: CustomCacheImage(
                      imageUrl: widget.imageUrl,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero, topRight: Radius.zero),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(4.h),
                  Text(
                    widget.location ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xff555151)),
                  ),
                  Gap(4.h),
                  TranslatableTextWidget(
                    text: widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: const Color(0xff14191E)),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      InkWell(
                        onTap: widget.favoriteOnTap,
                        child: SizedBox(
                          width: 50.w,
                          height: 30.h,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                widget.isLiked
                                    ? "assets/icon/liked.svg"
                                    : "assets/icon/like.svg",
                                key: ValueKey<bool>(widget.isLiked),
                                height: 20.h,
                                width: 20.w,
                              ),
                              SizedBox(width: 4.w),
                              Text('${widget.likes}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 25.w),
                      InkWell(
                        onTap: widget.saveOnTap,
                        child: SizedBox(
                          width: 50.w,
                          height: 30.h,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                widget.isSaved
                                    ? "assets/icon/saved.svg"
                                    : "assets/icon/active_save_icon.svg",
                                key: ValueKey<bool>(widget.isSaved),
                                height: 20.h,
                                width: 20.w,
                              ),
                              SizedBox(width: 4.w),
                              Text('${widget.bookmarks}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      InkWell(
                        // onTap: widget.shareOnTap,
                        child: SvgPicture.asset(
                          "assets/icon/view.svg",
                          height: 20.h,
                          width: 20.w,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text('${widget.viewedCount}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
