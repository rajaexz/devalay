

import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/feed/widget/postCard.dart';
import 'package:devalay_app/src/presentation/profile/widget/profile_shimer.dart' show buildProfileShimmer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  int? id;
  String? prolifeType;
  ProfileScreen({super.key, this.id, this.prolifeType});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userid;
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    // Get current user's ID first
    userid = await PrefManager.getUserDevalayId();
    
    // Determine which profile ID to use
    String? profileId;
    
    if (widget.id != null) {
      profileId = widget.id.toString();
    } else if (userid != null && userid!.isNotEmpty) {
      profileId = userid;
    }
    
    if (profileId != null && profileId.isNotEmpty && profileId != "null") {
      if (mounted) {
        context.read<ProfileCubit>().init(profileId);
      }
    } else {
      debugPrint("ProfileScreen: No valid profile ID available");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.errorMessage,
                  
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final feedList = state.feedList ?? [];

          if (feedList.isEmpty) {
            return NoMediaView(
              onRefresh: () {
                _initializeProfile();
              },
              title:  StringConstant.noDataAvailable,
              subtitle:
                  StringConstant.noDataAvailableSubtitle,
              icon: Icons.podcasts,
            );
          }

          return ListView.separated(
           
            itemCount: feedList.length,
            itemBuilder: (context, index) {
              return BlocBuilder<FeedHomeCubit, FeedHomeState>(
                builder: (context, feedState) {
                     if (feedState is FeedHomeLoaded && feedState.feedList != null) {
   
                    final currentFeed = feedList[index];

                    return PostCardCommon<FeedGetData>(
                              getLikedUsers: (data) => data.likedUsers,
                      clickedPostIndex: index,
                      feedData: currentFeed,
                            eyes:(data) => data.eyes.toString(),
                      getReport: (data) => data.report,
                      userId: widget.prolifeType == "profile"
                          ? userid
                          : null,
                      getUser: (data) => data,
                       location: (data)=>data.location,
                      getId: (data) => data.id,
                      getText: (data) => data,
                      getCreatedAt: (data) => data.createdAt,
                      getLiked: (data) => data.liked,
                      getLikedCount: (data) => data.likedCount,
                      getSaved: (data) => data.saved,
                      getCommentsCount: (data) => data.commentsCount,
                      getMedia: (data) => data.media,
                      
                      onDelete: (ctx, id) =>
                          ctx.read<ProfileCubit>().feedPostDelete(id),
                      onSaveToggle: (ctx, id, isSaved) => ctx
                          .read<ProfileCubit>()
                          .feedPostSaved(id.toString(), isSaved),
           
                   
                      onLikeToggle: (ctx, id, isLiked) {
                        ctx
                            .read<ProfileCubit>()
                            .feedPostLike2(id, isLiked, ctx);
                      },
                    );
                  }
                  return const SizedBox();
                },
              );
            },
            separatorBuilder: (context, index) => Gap(12.h),
          );
        }

        return  buildProfileShimmer();
      },
    );
  }
}
