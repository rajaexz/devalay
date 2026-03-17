import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/notification_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class NotiCard extends StatefulWidget {
  final NotificationModel notification;

  const NotiCard({
    super.key,
    required this.notification,
  });

  @override
  State<NotiCard> createState() => _NotiCardState();
}

class _NotiCardState extends State<NotiCard> {
  String? currentUserId;
  bool _isLoading = false;
  ActionUser? _currentActionUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _currentActionUser = widget.notification.actionUser;
  }

  Future<void> _loadCurrentUser() async {
    currentUserId = await PrefManager.getUserDevalayId();
  }

  bool get _isFollowRequest => 
      widget.notification.type == 'people' ||
      (widget.notification.notificationMsge?.toLowerCase().contains('follow') ?? false) ||
      (widget.notification.notificationMsge?.toLowerCase().contains('started following') ?? false);


  String _getFollowButtonText() {
    final actionUser = _currentActionUser;
    if (actionUser == null) return StringConstant.follow;
    
    if (actionUser.followingStatus == true) {
      return StringConstant.following;
    } else if (actionUser.followingRequestsStatus == true) {
      return StringConstant.requestSent;
    } else {
      return StringConstant.follow;
    }
  }


  Future<void> _handleFollowAction() async {
    if (currentUserId == null || _currentActionUser?.id == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final feedHomeCubit = context.read<FeedHomeCubit>();
      final actionUser = _currentActionUser!;
      final isFollowing = actionUser.followingStatus ?? false;
      final isFollowingRequest = actionUser.followingRequestsStatus ?? false;

      if (isFollowing) {
        // Unfollow
        await feedHomeCubit.feedPostFollowing(
          followingUserId: actionUser.id!,
          userId: int.parse(currentUserId!),
          isFollowing: false,
          clickedPostIndex: 0,
        );
        // Update local state
        setState(() {
          _currentActionUser = actionUser.copyWith(
            followingStatus: false,
            followingRequestsStatus: false,
          );
        });
      } else {
        if (isFollowingRequest) {
          // Cancel follow request
          await feedHomeCubit.feedPostFollowingRequest(
            followingUserId: actionUser.id!,
            userId: int.parse(currentUserId!),
            isFollowing: false,
            clickedPostIndex: 0,
          );
          // Update local state
          setState(() {
            _currentActionUser = actionUser.copyWith(
              followingRequestsStatus: false,
            );
          });
        } else {
          // Send follow request
          await feedHomeCubit.feedPostFollowingRequest(
            followingUserId: actionUser.id!,
            userId: int.parse(currentUserId!),
            isFollowing: true,
            clickedPostIndex: 0,
          );
          // Update local state
          setState(() {
            _currentActionUser = actionUser.copyWith(
              followingRequestsStatus: true,
            );
          });
        }
      }
    } catch (e) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update follow status')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeText = HelperClass.timeAgo(widget.notification.createdAt!);
    final String profileImage = _currentActionUser?.dp ?? "";
    final String postImage = (widget.notification.post?.media.isNotEmpty == true)
        ? (widget.notification.post!.media.first.file ?? "")
        : "";
    final String profileName = _currentActionUser?.name ?? "";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 44.h,
          width: 44.w,
          child: CustomCacheImage(
              borderRadius: BorderRadius.circular(50),
              imageUrl: profileImage,
              showLogo: profileImage.isEmpty),
        ),
        Gap(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: "$profileName ",
                          style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(
                          text: '${widget.notification.notificationMsge} .',
                          style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(
                          text: timeText,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColor.greyColor,
                                  )),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodySmall),
              if (_isFollowRequest) ...[
                Gap(8.h),
                Row(
                  children: [
                    CustomButton(
                      onTap: _isLoading ? () {} : _handleFollowAction,
                      textButton: _getFollowButtonText(),
                      buttonAssets: '',
                      fontSize: 12,
                      mypadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      textColor: Colors.white,
                    ),
                    Gap(8.w),
                    if (_isLoading)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Gap(20.w),
        SizedBox(
          height: 44.h,
          width: 44.w,
          child: Stack(
            children: [
              CustomCacheImage(
                  borderRadius: BorderRadius.circular(0),
                  imageUrl: postImage,
                  showLogo: postImage.isEmpty),
          
            ],
          ),
        ),
      ],
    );
  }
}
