import 'package:devalay_app/src/application/feed/feed_%20comment.dart/feed_comment_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_%20comment.dart/feed_comment_state.dart';
import 'package:devalay_app/src/data/model/feed/feed_comment_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_comment_reply_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CommentWidget extends StatelessWidget {
  final FeedComment comment;
  final int? currentUserId;
  final String postId;
  final void Function(int, String, int) onReply;

  const CommentWidget({
    this.currentUserId,
    required this.comment,
    required this.postId,
    required this.onReply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCommentCubit, FeedCommentState>(
      builder: (context, state) {
        final cubit = context.read<FeedCommentCubit>();
        bool isReplyVisible = cubit.viewReplies[comment.id] ?? false;
        List<FeedCommentReply> filterReply = cubit.commentsReplies
            .where((e) => e.objectId == comment.id)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainCommentSection(context, cubit),
            if (isReplyVisible) _buildRepliesList(context, filterReply),
            Gap(10.h)
          ],
        );
      },
    );
  }

  Widget _buildMainCommentSection(
      BuildContext context, FeedCommentCubit cubit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(imageUrl: comment.user!.dp.toString(), radius: 20),
        Gap(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentBubble(
                userName: comment.user?.name ?? "Unknown User",
                timestamp: comment.createdAt.toString(),
                content: comment.comment ?? "",
                comment: comment,
              ),
              CommentActions(
                comment: comment,
                currentUserId: currentUserId,
                postId: postId,
                onReply: onReply,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepliesList(
      BuildContext context, List<FeedCommentReply> replies) {
    return Column(
      children: replies
          .map((reply) => ReplyWidget(
                reply: reply,
                currentUserId: currentUserId,
                onReply: onReply,
                parentCommentId: comment.id ?? 0,
              ))
          .toList(),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const UserAvatar({
    required this.imageUrl,
    this.radius = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.9,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class CommentBubble extends StatelessWidget {
  final String userName;
  final String timestamp;
  final String content;
  final Color backgroundColor;
  final FeedComment comment;

  const CommentBubble({
    required this.userName,
    required this.timestamp,
    required this.content,
    required this.comment,
    this.backgroundColor = const Color(0xFFF5F5F5),
    super.key,
  });

  Widget _buildLikeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final feedCubit = context.read<FeedCommentCubit>();
        final commentId = comment.id;
        final isLiked = comment.liked;

        if (commentId != null && isLiked != null) {
          feedCubit.feedCommentLike(
            followingUserId: commentId,
            isFollowing: !isLiked,
          );
        } else {
          debugPrint("Like action failed: commentId or liked is null");
        }
      },
      child: BlocBuilder<FeedCommentCubit, FeedCommentState>(
        builder: (context, state) {
          final isLiked = comment.liked ?? false;
          return SvgPicture.asset(
            isLiked ? "assets/icon/liked.svg" : "assets/icon/like.svg",
            height: 20.h,
            width: 20.w,
          
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Text(userName, style: Theme.of(context).textTheme.bodyMedium),
                  Gap(10.w),
                  Text(
                    HelperClass.timeAgo(timestamp),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColor.lightGrayColor
                              : AppColor.greyColor,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              _buildLikeButton(context),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.lightGrayColor
                      : AppColor.blackColor,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class CommentActions extends StatelessWidget {
  final FeedComment comment;
  final int? currentUserId;
  final String postId;
  final void Function(int, String, int) onReply;

  const CommentActions({
    required this.comment,
    required this.currentUserId,
    required this.postId,
    required this.onReply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FeedCommentCubit>();

    return BlocBuilder<FeedCommentCubit, FeedCommentState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Gap(8.h),
            Row(
              children: [
                _buildReplyButton(context),
                Gap(10.w),
                if (comment.user?.id == currentUserId)
                  _buildDeleteButton(context, cubit),
              ],
            ),
            Gap(4.w),
            _buildViewRepliesToggle(context, cubit),
          ],
        );
      },
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    return GestureDetector(
      onTap: () => onReply(
        comment.id ?? 0,
        comment.user?.name ?? "Unknown",
        1,
      ),
      child: Text(
        StringConstant.reply,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.lightGrayColor
                  : AppColor.greyColor,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, FeedCommentCubit cubit) {
    return InkWell(
      onTap: () async {
        await cubit.deleteComment(comment.id ?? 0, postId);
      },
      child: Text(
        StringConstant.delete,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.lightGrayColor
                  : AppColor.greyColor,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  Widget _buildViewRepliesToggle(BuildContext context, FeedCommentCubit cubit) {
    if (comment.commentsReplyCount == 0) return const SizedBox();

    bool isReplyVisible = cubit.viewReplies[comment.id ?? 0] ?? false;

    return InkWell(
      onTap: () => cubit.toggleViewReply(comment.id ?? 0),
      child: isReplyVisible
          ? Text(
              StringConstant.hide,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.lightGrayColor
                        : AppColor.greyColor,
                  ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Container(height: 1, color: AppColor.greyColor),
                ),
                Gap(8.w),
                Text(
                  "${StringConstant.viewReply} (${comment.commentsReplyCount})",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.lightGrayColor
                            : AppColor.greyColor,
                      ),
                ),
              ],
            ),
    );
  }
}

class ReplyWidget extends StatelessWidget {
  final FeedCommentReply reply;
  final int? currentUserId;
  final void Function(int, String, int) onReply;
  final int parentCommentId;

  const ReplyWidget({
    required this.reply,
    required this.currentUserId,
    required this.onReply,
    required this.parentCommentId,
    super.key,
  });
Widget _buildReplyLikeButton(BuildContext context) {
  return BlocBuilder<FeedCommentCubit, FeedCommentState>(
    builder: (context, state) {
      final isLiked = reply.liked ?? false;
      return GestureDetector(
        onTap: () {
          final feedCubit = context.read<FeedCommentCubit>();
          final commentId = reply.id;
          final currentLikedState = reply.liked;

          if (commentId != null && currentLikedState != null) {
            // Update the local state immediately for better UX
            reply.liked = !currentLikedState;
            
            
            feedCubit.feedCommentLike(
              followingUserId: commentId, 
              isFollowing: !currentLikedState, 
            );
          } else {
            debugPrint("Like action failed: commentId or liked is null");
          }
        },
        child: SvgPicture.asset(
          isLiked ? "assets/icon/liked.svg" : "assets/icon/like.svg",
          height: 20.h,
          width: 20.w,
          
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FeedCommentCubit>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReplyContent(context),
              Gap(10.h),
              _buildReplyActions(context, cubit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(imageUrl: reply.user!.dp.toString(), radius: 15),
          Gap(5.w),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(reply.user?.name ?? '',
                                style: Theme.of(context).textTheme.bodyMedium),
                            Gap(10.w),
                            Text(
                              HelperClass.timeAgo(reply.createdAt.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColor.lightGrayColor
                                        : AppColor.greyColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                        // Text(
                        //   reply.user?.name ?? "Unknown",
                        //   style: Theme.of(context).textTheme.bodyMedium,
                        // ),
                        const SizedBox(height: 4),
                        Text(
                          reply.comment ?? "",
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelLarge!.copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColor.lightGrayColor
                                        : AppColor.blackColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildReplyLikeButton(context),
        ],
      ),
    );
  }

  Widget _buildDeleteReplyButton(BuildContext context) {
    final cubit = context.read<FeedCommentCubit>();
    return InkWell(
      onTap: () async {
        await cubit.deleteReply(reply.id ?? 0, parentCommentId);
      },
      child: Text(
        StringConstant.delete,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.lightGrayColor
                  : AppColor.greyColor,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  Widget _buildReplyActions(BuildContext context, FeedCommentCubit cubit) {
    return BlocBuilder<FeedCommentCubit, FeedCommentState>(
      builder: (context, state) {
        bool isReplyToRepliesVisible =
            cubit.replyingViewReplies[reply.id!] ?? false;
        List<FeedCommentReply> replyToRepliesFilter =
            cubit.replyToReplies.where((e) => e.objectId == reply.id).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 95),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildReplyToReplyButton(context),
                          Gap(10.w),
                          if (reply.user?.id == currentUserId)
                            _buildDeleteReplyButton(context),
                        ],
                      ),
                      Gap(15.w),
                      _buildViewNestedRepliesToggle(context, cubit),
                    ])),
            if (isReplyToRepliesVisible) ...[
              Gap(10.h),
              _buildNestedRepliesList(context, replyToRepliesFilter),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReplyToReplyButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onReply(
          reply.id ?? 0,
          reply.user?.name ?? "Unknown",
          2,
        );
      },
      child: Text(
        StringConstant.reply,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.lightGrayColor
                  : AppColor.greyColor,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  Widget _buildViewNestedRepliesToggle(
      BuildContext context, FeedCommentCubit cubit) {
    if (reply.commentsReplyCount == 0) return const SizedBox();

    bool isReplyToRepliesVisible =
        cubit.replyingViewReplies[reply.id!] ?? false;
    return GestureDetector(
      onTap: () => cubit.toggleViewReplyToReplies(
        commentId: reply.id ?? 0,
        isTrue: false,
      ),
      child: isReplyToRepliesVisible
          ? Text(
              StringConstant.hide,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.lightGrayColor
                        : AppColor.greyColor,
                  ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Container(
                    height: 1,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.lightGrayColor
                        : AppColor.greyColor,
                  ),
                ),
                Gap(8.w),
                Text(
                  "${StringConstant.viewReply} (${reply.commentsReplyCount})",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.lightGrayColor
                            : AppColor.greyColor,
                      ),
                ),
              ],
            ),
    );
  }

  Widget _buildNestedRepliesList(
      BuildContext context, List<FeedCommentReply> nestedReplies) {
    return Container(
      margin: EdgeInsets.only(left: 53.w),
      child: Column(
        children: nestedReplies
            .map((nestedReply) => NestedReplyWidget(
                  reply: nestedReply,
                  currentUserId: currentUserId,
                  parentCommentId: parentCommentId,
                ))
            .toList(),
      ),
    );
  }
}

class NestedReplyWidget extends StatelessWidget {
  final FeedCommentReply reply;
  final int? currentUserId;
  final int parentCommentId;

  const NestedReplyWidget({
    required this.reply,
    required this.currentUserId,
    required this.parentCommentId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(imageUrl: reply.user!.dp.toString(), radius: 15),
        Gap(5.w),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reply.user?.name ?? "Unknown",
                            style: Theme.of(context).textTheme.bodyMedium!,
                          ),
                          Gap(10.w),
                          Text(
                            HelperClass.timeAgo(reply.createdAt.toString()),
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColor.lightGrayColor
                                          : AppColor.greyColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reply.comment ?? "",
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColor.lightGrayColor
                                  : AppColor.blackColor,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
                Gap(10.w),
                if (reply.user?.id == currentUserId)
                  _buildDeleteNestedReplyButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteNestedReplyButton(BuildContext context) {
    final cubit = context.read<FeedCommentCubit>();
    return rowImageIcon(
      context: context,
      onTap: () async {
        await cubit.deleteReplyToReplies(reply.id ?? 0, parentCommentId);
      },
      isSVG: true,
      h: 20.h,
      w: 20.w,
      s: 0,
      imag: "assets/icon/delete.svg",
    );
  }
}
