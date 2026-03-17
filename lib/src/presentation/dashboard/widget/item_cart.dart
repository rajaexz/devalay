import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ContributionType {
  temple,
  event,
  dev,
}

enum WhichType {
  draft,
  submitted,
  approved,
  rejected,
  review,
  manage,
}

class ItemCart extends StatefulWidget {
  final String title;
  final WhichType? whisType;
  final String imageUrl;
  final double progress;
  final String lastEdited;
  final dynamic contributeCubit;
  final bool isDraft;
  final ContributionType type;

  final String id;
  final String? governedById;
  final String? screen;
  final bool isIcon;
  final VoidCallback? onItemDeleted;
  final VoidCallback? onTap;

  const ItemCart({
    super.key,
    this.whisType,
    required this.contributeCubit,
    required this.isDraft,
    required this.title,
    required this.imageUrl,
    required this.progress,
    required this.lastEdited,
    this.isIcon = true,
    required this.type,
    required this.id,
    this.governedById,
    this.screen,
    this.onItemDeleted,
    this.onTap,
  });

  @override
  State<ItemCart> createState() => _ItemCartState();
}

class _ItemCartState extends State<ItemCart> {
  String _getViewRoute() {
    switch (widget.type) {
      case ContributionType.temple:
        return widget.screen == 'Approved'
            ? "/singleDevalay/${widget.id}"
            : '/viewTemple/${widget.id}/${widget.governedById}/draft';
      case ContributionType.event:
        return '/viewEvent/${widget.id}/draft';
      case ContributionType.dev:
        return '/viewDev/${widget.id}/draft';
    }
  }

  String _getEditRoute() {
    switch (widget.type) {
      case ContributionType.temple:
        return '/addTemple/${widget.id}/${widget.governedById}/EditTemple/0';
      case ContributionType.event:
        return '/addEvent/${widget.id}/EditEvent/0';
      case ContributionType.dev:
        return '/addDev/${widget.id}/EditDev/0';
    }
  }

  String _getContributionType() {
    switch (widget.type) {
      case ContributionType.temple:
        return 'Devalay';
      case ContributionType.event:
        return 'Event';
      case ContributionType.dev:
        return 'Dev';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6.r),
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.r),
                  bottomLeft: Radius.circular(5.r),
                ),
                child: Image.network(
                  widget.imageUrl,
                  width: 130.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 130.w,
                      height: 100.h,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                      padding: const EdgeInsets.all(2),
                      offset: const Offset(-15, 40),
                      position: PopupMenuPosition.over,
                      iconSize: 15,
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.whiteColor
                            : AppColor.blackColor,
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          AppRouter.push(_getEditRoute());
                        } else if (value == 'delete') {
                          await widget.contributeCubit.deleteItem(
                            _getContributionType(),
                            widget.id,
                          );
                          widget.onItemDeleted?.call();
                        } else if (value == 'view') {
                          AppRouter.push(_getViewRoute());
                        }
                      },
                      itemBuilder: (context) {
                        return <PopupMenuEntry<String>>[
                          if (widget.whisType == WhichType.draft ||
                              widget.whisType == WhichType.rejected)
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/Edit.svg",
                                    height: 20.h,
                                    width: 20.w,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColor.whiteColor
                                        : null,
                                  ),
                                  Gap(6.w),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColor.whiteColor
                                          : AppColor.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.whisType == WhichType.draft ||
                              widget.whisType == WhichType.rejected ||
                              widget.whisType == WhichType.review ||
                              widget.whisType == WhichType.manage)
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/delete.svg",
                                    height: 20.h,
                                    width: 20.w,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColor.whiteColor
                                        : null,
                                  ),
                                  Gap(6.w),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColor.whiteColor
                                          : AppColor.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.whisType == WhichType.submitted ||
                              widget.whisType == WhichType.approved ||
                              widget.whisType == WhichType.review ||
                              widget.whisType == WhichType.manage)
                            PopupMenuItem<String>(
                              value: 'view',
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/eye.svg",
                                    height: 20.h,
                                    width: 20.w,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColor.whiteColor
                                        : null,
                                  ),
                                  Gap(6.w),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColor.whiteColor
                                          : AppColor.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ];
                      },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.lastEdited,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
