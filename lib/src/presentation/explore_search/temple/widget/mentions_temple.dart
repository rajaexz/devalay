import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/explore/explore_devalay/explore_devalay_cubit.dart';
import '../../../../application/explore/explore_devalay/explore_devalay_state.dart';
import '../../../../application/feed/feed_home/feed_home_cubit.dart';
import '../../../../application/feed/feed_home/feed_home_state.dart';
import '../../../../core/shared_preference.dart';
import '../../../../data/model/feed/feed_home_model.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/loader.dart';
import '../../../core/widget/No_data_found.dart';
import '../../../feed/widget/postCard.dart';

class Mention extends StatefulWidget {
  String? id;
  String? profileType;
  Mention({super.key, this.id, this.profileType});

  @override
  State<Mention> createState() => _MentionState();
}

class _MentionState extends State<Mention> with AutomaticKeepAliveClientMixin {
  String? userid;
  bool isFetchingMore = false;
  ExploreDevalayCubit? _exploreDevalayCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exploreDevalayCubit ??= context.read<ExploreDevalayCubit>();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.id != null) {
        context.read<ExploreDevalayCubit>().resetMentionData();
        context
            .read<ExploreDevalayCubit>()
            .initMentionData(id: widget.id.toString(), contentType: "devalay");
      }
    });
  }

  @override
  void dispose() {
    _exploreDevalayCubit?.resetMentionData();
    super.dispose();
  }

  Future<void> getUserData() async {
    if (mounted) {
      userid = await PrefManager.getUserDevalayId();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _safeRefresh() {
    if (mounted && widget.id != null) {
      context
          .read<ExploreDevalayCubit>()
          .refreshMentionData(id: widget.id.toString(), contentType: "devalay");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
      builder: (context, state) {
        if (state is ExploreDevalayLoaded) {
          if (state.loadingState && (state.feedData?.isEmpty ?? true)) {
            return const Center(child: CustomLottieLoader());
          }

          if (state.errorMessage.isNotEmpty &&
              (state.feedData?.isEmpty ?? true)) {
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

          final feedList = state.feedData ?? [];

          if (feedList.isEmpty) {
            return NoMediaView(
              onRefresh: _safeRefresh,
              title: StringConstant.noDataAvailable,
              subtitle: StringConstant.noDataAvailableSubtitle,
              icon: Icons.podcasts,
            );
          }

          return ListView.separated(
            padding: EdgeInsets.only( bottom: 20.h),
            itemCount: feedList.length,
            itemBuilder: (context, index) {
              return BlocBuilder<FeedHomeCubit, FeedHomeState>(
                builder: (context, feedState) {
                  if (feedState is FeedHomeLoaded &&
                      feedState.feedList != null) {
                    final currentFeed = feedList[index];

                    return PostCardCommon<FeedGetData>(
                      getLikedUsers: (data) => data.likedUsers,
                       location: (data)=>data.location,
                      clickedPostIndex: index,
                      feedData: currentFeed,
                           eyes:(data) => data.eyes.toString(),
                      getReport: (data) => data.report,
                      userId: userid,
                      getUser: (data) => data,
                      getId: (data) => data.id,
                      getText: (data) => data,
                      getCreatedAt: (data) => data.createdAt,
                      getLiked: (data) => data.liked,
                      getLikedCount: (data) => data.likedCount,
                      getSaved: (data) => data.saved,
                      getCommentsCount: (data) => data.commentsCount,
                      getMedia: (data) => data.media,
                      onDelete: (ctx, id) {
                        if (mounted) {
                          ctx.read<ExploreDevalayCubit>().feedPostDelete(id);
                        }
                      },
                      onSaveToggle: (ctx, id, isSaved) {
                        if (mounted) {
                          ctx
                              .read<ExploreDevalayCubit>()
                              .feedPostSaved(id.toString(), isSaved);
                        }
                      },
                  
                      onLikeToggle: (ctx, id, isLiked) {
                        if (mounted) {
                          ctx
                              .read<ExploreDevalayCubit>()
                              .feedPostLike2(id, isLiked, ctx);
                        }
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

        return const Center(child: CustomLottieLoader());
      },
    );
  }
}
