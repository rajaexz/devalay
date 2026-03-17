import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/explore/explore_devotees_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/image_helper.dart'
    // ignore: library_prefixes
    as imageHelperLower;
import 'package:devalay_app/src/presentation/core/helper/sharing_service.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart';
import 'package:devalay_app/src/presentation/feed/feed_create_screen/feed_create_screen.dart'
    show FeedEditScreen;
import 'package:devalay_app/src/presentation/feed/widget/post_content_widget.dart';
import 'package:devalay_app/src/presentation/profile/profile_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:devalay_app/src/presentation/feed/feed_comment_screen/feed_comment_screen.dart';

class PostCardCommon<T> extends StatelessWidget {
  const PostCardCommon({
    super.key,
    required this.feedData,
    required this.userId,
    required this.location,
    required this.getUser,
    required this.eyes,
    required this.getId,
    required this.getText,
    required this.getCreatedAt,
    required this.getLiked,
    required this.getLikedCount,
    required this.getSaved,
    required this.getReport,
    required this.getCommentsCount,
    required this.getMedia,
    required this.getLikedUsers,
    required this.onLikeToggle,
    required this.onDelete,
    required this.onSaveToggle,
    this.clickedPostIndex = 0,
  });

  final T feedData;
  final String? userId;

  final FeedGetData? Function(T data) getUser;
  final int? Function(T data) getId;
  final FeedGetData Function(T data) getText;
  final String? Function(T data) getCreatedAt;
  final bool? Function(T data) getLiked;
  final String? Function(T data) location;
  final int? Function(T data) getLikedCount;
  final String? Function(T data) eyes;
  final bool? Function(T data) getSaved;
  final bool? Function(T data) getReport;

  final int? Function(T data) getCommentsCount;
  final List<Media>? Function(T data) getMedia;
  final List<ExploreUser>? Function(T data) getLikedUsers;
  final int? clickedPostIndex;

  final void Function(BuildContext context, int id) onDelete;
  final void Function(BuildContext context, int id, bool isSaved) onSaveToggle;

  final void Function(BuildContext context, String postId, bool isLiked)
      onLikeToggle;

  @override
  Widget build(BuildContext context) {
    final user = getUser(feedData);
    final postId = getId(feedData);

    if (user == null || postId == null) {
      return Center(child: Text(StringConstant.postDataNotAvailable));
    }

    void showReportDialog(BuildContext context) async {
      final feedHomeCubit = context.read<FeedHomeCubit>();
      await feedHomeCubit.fetchReportReasons();
      int? selectedReasonId;
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(StringConstant.reportPost),
                content: DropdownButton<int>(
                  value: selectedReasonId,
                  hint: Text(StringConstant.selectReason),
                  isExpanded: true,
                  items: feedHomeCubit.reportReasons.map((reason) {
                    return DropdownMenuItem<int>(
                      value: reason.id,
                      child: Text(reason.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReasonId = value;
                    });
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(StringConstant.cancel),
                  ),
                  TextButton(
                    onPressed: selectedReasonId != null
                        ? () {
                            Navigator.pop(context);
                            feedHomeCubit.isReportPost(
                                postId.toString(), selectedReasonId!);
                          }
                        : null,
                    child: Text(StringConstant.report),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return FutureBuilder<bool>(
      future: PrefManager.getIsGuest(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text(""));
        }

        final bool isGuest = snapshot.data!;

        return Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColor.blackColor
              : AppColor.whiteColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 15.0, bottom: 15.0, left: 15.0, right: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (user.user?.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileMainScreen(
                                    id: int.parse(user.user!.id!.toString()),
                                    profileType:
                                        (user.user!.id.toString() == userId)
                                            ? "profile"
                                            : "devotee",
                                  ),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            backgroundImage:
                                imageHelperLower.ImageHelper.getProfileImage(
                                    user.user?.dp ?? ""),
                            radius: 20,
                          ),
                        ),
                        Gap(10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.user?.name ?? StringConstant.noName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                location(feedData) ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (userId != null &&
                            user.user?.id != null &&
                            userId != user.user?.id.toString())
                          BlocBuilder<FeedHomeCubit, FeedHomeState>(
                            builder: (context, state) {
                              final isFollowingRequest =
                                  user.user?.followingRequests ?? false;
                              final isFollowing = user.user?.following ?? false;
                              String buttonText;
                              if (isFollowing) {
                                buttonText = StringConstant.following;
                              } else {
                                if (!isFollowing && isFollowingRequest) {
                                  buttonText = StringConstant.requestSent;
                                } else {
                                  buttonText = StringConstant.follow;
                                }
                              }

                              return OutlinedButton(
                                onPressed: () async {
                                  if (isGuest == true) {
                                    showGuestLoginDialog(context);
                                  } else {
                                    if (userId == null ||
                                        user.user?.id == null ||
                                        clickedPostIndex == null) {
                                      return;
                                    }

                                    final feedHomeCubit =
                                        context.read<FeedHomeCubit>();
                                    if (isFollowing) {
                                      await feedHomeCubit.feedPostFollowing(
                                        followingUserId: user.user!.id!,
                                        userId: int.parse(userId!),
                                        isFollowing: false,
                                        clickedPostIndex: clickedPostIndex!,
                                      );
                                      user.user!.following = false;
                                    } else {
                                      if (!isFollowing && isFollowingRequest) {
                                        await feedHomeCubit
                                            .feedPostFollowingRequest(
                                          followingUserId: user.user!.id!,
                                          userId: int.parse(userId!),
                                          isFollowing: false,
                                          clickedPostIndex: clickedPostIndex!,
                                        );
                                        user.user!.followingRequests = false;
                                      } else {
                                        await feedHomeCubit
                                            .feedPostFollowingRequest(
                                          followingUserId: user.user!.id!,
                                          userId: int.parse(userId!),
                                          isFollowing: true,
                                          clickedPostIndex: clickedPostIndex!,
                                        );
                                        user.user!.followingRequests = true;
                                      }
                                    }

                                    // ignore: invalid_use_of_protected_member
                                    feedHomeCubit.emit(state);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size.zero,
                                ),
                                child: Text(
                                  buttonText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              );
                            },
                          ),
                        Gap(5.w),
                        PopupMenuButton<String>(
                          offset: const Offset(-15, 40),
                          icon: Icon(Icons.more_vert,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColor.whiteColor
                                  : AppColor.blackColor),
                          onSelected: (value) async {
                            if (isGuest == true) {
                              showGuestLoginDialog(context);
                            } else {
                              if (value == 'delete') {
                                onDelete(context, getId(feedData)!);
                              } else if (value == 'report') {
                                showReportDialog(context);
                              } else if (value == 'block') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(StringConstant.blockContent),
                                      content: Text(
                                          StringConstant.whatWouldYouLikeToBlock),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(StringConstant.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            // Show loading indicator
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(StringConstant.blockingUser),
                                                  ],
                                                ),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );

                                            await context
                                                .read<FeedHomeCubit>()
                                                .blockUser(
                                                    postId,
                                                    user.user!.id,
                                                    userId.toString());

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      StringConstant.userBlockedSuccessfully),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(StringConstant.blockUser),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            // Show loading indicator for post blocking
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(StringConstant.blockingPost),
                                                  ],
                                                ),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );

                                            // Block the specific post only
                                            await context
                                                .read<FeedHomeCubit>()
                                                .blockPost(
                                                    postId,
                                                    user.user!.id,
                                                    userId.toString());

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      StringConstant.postBlockedSuccessfully),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(StringConstant.blockPost),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          itemBuilder: (context) {
                            final isOwner = getUser(feedData)?.user?.id ==
                                int.tryParse(userId ?? "");
                            final isReport = getReport(feedData) ?? false;

                            return <PopupMenuEntry<String>>[
                              if (isOwner)
                                PopupMenuItem<String>(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FeedEditScreen(
                                          existingPost: feedData as FeedGetData,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18),
                                      const SizedBox(width: 8),
                                      Text(StringConstant.edit),
                                    ],
                                  ),
                                ),
                              if (isOwner)
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete, size: 18),
                                      const SizedBox(width: 8),
                                      Text(StringConstant.delete),
                                    ],
                                  ),
                                ),
                              if (!isOwner && !isReport)
                                PopupMenuItem<String>(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flag, size: 18),
                                      const SizedBox(width: 8),
                                      Text(StringConstant.report),
                                    ],
                                  ),
                                ),
                              if (!isOwner && !isReport)
                                PopupMenuItem<String>(
                                  value: 'block',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.block, size: 18),
                                      const SizedBox(width: 8),
                                      Text(StringConstant.block),
                                    ],
                                  ),
                                ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (getMedia(feedData) != null && getMedia(feedData)!.isNotEmpty)
                imageHelperLower.MyMediaViewer(
                  mediaList: getMedia(feedData)!,
                  postId: postId.toString(),
                  isLiked: getLiked(feedData) ?? false,
                  onLikeToggle: (postId, isLiked) =>
                      onLikeToggle(context, postId, isLiked),
                  onBlockMedia: (mediaId) {
                    context.read<FeedHomeCubit>().blockMedia(mediaId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(StringConstant.thisVideoBlocked)),
                    );
                  },
                ),
              Container(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 0, top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Align left
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        BlocBuilder<FeedHomeCubit, FeedHomeState>(
                          builder: (context, state) {
                            if (state is FeedHomeLoaded) {
                              return InkWell(
                                onTap: () {
                                  if (isGuest == true) {
                                    showGuestLoginDialog(context);
                                  } else {
                                    onLikeToggle(
                                      context,
                                      postId.toString(),
                                      !(getLiked(feedData) ?? false),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24.w,
                                      height: 27.h,
                                      child: getLiked(feedData) ?? false
                                          ? SvgPicture.asset(
                                              'assets/icon/liked.svg',
                                              fit: BoxFit.cover,
                                            )
                                          : SvgPicture.asset(
                                              'assets/icon/like.svg',
                                              colorFilter: ColorFilter.mode(
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? AppColor.whiteColor
                                                    : Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Gap(6.w),
                                    Text(
                                      "${getLikedCount(feedData) ?? 0}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        Gap(31.w),
                        rowImageIcon(
                          context: context,
                          onTap: () {
                            if (isGuest == true) {
                              showGuestLoginDialog(context);
                            } else {
                              _navigateToComments(context, postId.toString());
                            }
                          },
                          isSVG: true,
                          h: 20.h,
                          s: 6,
                          w: 20.w,
                          text: "${getCommentsCount(feedData) ?? 0}",
                          imag: "assets/icon/comments.svg",
                        ),
                        Gap(31.w),
                        rowImageIcon(
                          context: context,
                          onTap: () {},
                          isSVG: true,
                          h: 23.h,
                          s: 6,
                          w: 20.w,
                          text: eyes(feedData).toString(),
                          imag: "assets/icon/eye.svg",
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        rowImageIcon(
                          context: context,
                          onTap: () {
                            SharingService.shareContent(
                              contentType: 'Post',
                              id: postId.toString(),
                            );
                          },
                          isSVG: true,
                          h: 18.h,
                          s: 6,
                          w: 18.w,
                          imag: "assets/icon/share.svg",
                        ),
                        Gap(10.h),
                        BlocBuilder<FeedHomeCubit, FeedHomeState>(
                          builder: (context, state) {
                            final isSaved = getSaved(feedData) ?? false;

                            return rowImageIcon(
                              context: context,
                              onTap: () {
                                if (isGuest == true) {
                                  showGuestLoginDialog(context);
                                } else {
                                  onSaveToggle(
                                      context, getId(feedData)!, !isSaved);
                                }
                              },
                              isSVG: true,
                              h: 20.h,
                              w: 20.w,
                              s: 15,
                              imag: isSaved
                                  ? "assets/icon/saved.svg"
                                  : "assets/icon/save.svg",
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (getLikedUsers(feedData)?.isNotEmpty ?? false) Gap(10.h),
              if (getMedia(feedData) != null && getMedia(feedData)!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      if (getLikedUsers(feedData)?.isNotEmpty ?? false)
                        CircleAvatar(
                          backgroundImage:
                              imageHelperLower.ImageHelper.getProfileImage(
                                  getLikedUsers(feedData)?.first.dp ?? ""),
                          radius: 10,
                        ),
                      if (getLikedUsers(feedData)?.isNotEmpty ?? false)
                        Gap(5.w),
                      // ignore: prefer_is_empty
                      if (getLikedUsers(feedData)?.length != 0)
                        Text(
                          "${StringConstant.likedBy} ${getLikedUsers(feedData)?.first.name ?? ''}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(),
                        ),
                      if ((getLikedUsers(feedData)?.length ?? 0) > 1)
                        Text(
                          " ${(getLikedUsers(feedData)?.length ?? 0) - 1} ${((getLikedUsers(feedData)?.length ?? 0) - 1) > 1 ? StringConstant.andOthers : StringConstant.andOther}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(),
                        ),
                    ],
                  ),
                ),
              if (getLikedUsers(feedData)?.isNotEmpty ?? false) Gap(5.h),
              if (!getText(feedData)
                  .textHtml!
                  .toString()
                  .contains("<p><br></p>"))
                PostContentWidget(
                  tags: (feedData as FeedGetData).tags ?? [],
                  postContent: getText(feedData).textHtml!,
                  postId: postId.toString(),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
                child: Text(
                  HelperClass.timeAgo(getCreatedAt(feedData) ??
                      DateTime.now().toIso8601String()),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToComments(BuildContext context, String postId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      StringConstant.commentsTab,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: FeedCommentScreen(
                  id: postId,
                  isAppbar: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Check if context is still mounted before using it
    if (context.mounted) {
      context.read<FeedHomeCubit>().fetchFeedSinglePostData(id: postId);
    }
  }
}
