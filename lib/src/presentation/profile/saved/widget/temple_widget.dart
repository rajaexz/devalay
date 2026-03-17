import 'package:devalay_app/src/presentation/core/helper/image_helper.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTile extends StatefulWidget {
  final String imageUrl;
  final String location;
  final String title;
  final String? dateRange;
  final int likes;
  final int bookmarks;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback shareOnTap;
  final VoidCallback? saveOnTap;
  final VoidCallback? likeOnTap;

  const CustomTile({
    super.key,
    this.likeOnTap,
    this.onTap,
    required this.imageUrl,
    required this.location,
    required this.title,
    this.dateRange,
    required this.likes,
    required this.bookmarks,
    required this.isLiked,
    required this.isSaved,
    required this.shareOnTap,
    this.saveOnTap,
  });

  @override
  State<CustomTile> createState() => _CustomTileState();
}

class _CustomTileState extends State<CustomTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9.sp),
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
                    Text(
                      widget.dateRange ?? widget.location,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xff555151)),
                    ),
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xff14191E)),
                    ),
                    SizedBox(height: 8.w),
                    Row(
                      children: [
                        // Like Button with fixed size container
                        InkWell(
                          onTap: widget.likeOnTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 22.w,
                            height: 22.h,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              widget.isLiked
                                  ? "assets/icon/liked.svg"
                                  : "assets/icon/like.svg",
                              key: ValueKey<bool>(widget.isLiked),
                              height: 20.h,
                              width: 20.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.likes}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(width: 35.w),
                        // Save Button with fixed size container
                        InkWell(
                          onTap: widget.saveOnTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 18.w,
                            height: 18.h,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              widget.isSaved
                                  ? "assets/icon/saved.svg"
                                  : "assets/icon/save.svg",
                              key: ValueKey<bool>(widget.isSaved),
                              height: 18.h,
                              width: 18.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.bookmarks}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(width: 35.w),
                        // Share Button
                        InkWell(
                          onTap: widget.shareOnTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 16.w,
                            height: 16.h,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/icon/share.svg",
                              height: 16.h,
                              width: 16.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
