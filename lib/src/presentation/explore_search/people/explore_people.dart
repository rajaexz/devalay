import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../application/explore/explore_devalay/explore_devalay_cubit.dart';
import '../../../application/explore/explore_devalay/explore_devalay_state.dart';
import '../../../core/shared_preference.dart';
import '../../../data/model/explore/explore_devotees_model.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/image_Helper.dart';
import '../../core/helper/loader.dart';
import '../../core/utils/colors.dart';
import '../../core/widget/No_data_found.dart';
import '../../core/widget/custom_cache_image.dart';
import '../../profile/profile_main_screen.dart';

class ExplorePeople extends StatefulWidget {
  const ExplorePeople({super.key});

  @override
  State<ExplorePeople> createState() => _ExplorePeopleState();
}

class _ExplorePeopleState extends State<ExplorePeople> {
  late ExploreDevalayCubit exploreDevalayCubit;
  final ScrollController _scrollController = ScrollController();
  String? userid;
  // Track loading state for each user's follow button
  final Set<int> _loadingFollowIds = {};

  @override
  void initState() {
    exploreDevalayCubit = context.read<ExploreDevalayCubit>();
    exploreDevalayCubit.fetchGetAllExploreDevoteesData();
    _scrollController.addListener(_scrollListener);
    getUserData();
    super.initState();
  }

  void _scrollListener() {
    final state = exploreDevalayCubit.state;
    if (state is ExploreDevalayLoaded &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.loadingState) {
      exploreDevalayCubit.fetchGetAllExploreDevoteesData(loadMoreData: true);
    }
  }

  getUserData() async {
    userid = await PrefManager.getUserDevalayId();
    if (mounted) setState(() {});
  }

  /// Handle follow/unfollow button press - Real-time like postCard.dart
  Future<void> handleFollowToggle(ExploreUser devotee) async {
    if (userid == null || userid!.isEmpty) {
      debugPrint('User ID not available');
      return;
    }

    final devoteeId = int.tryParse(devotee.id.toString());
    final currentUserId = int.tryParse(userid!);

    if (devoteeId == null || currentUserId == null) {
      debugPrint('Invalid user IDs');
      return;
    }

    // Determine current follow status
    final bool isCurrentlyFollowing = devotee.followingStatus == true;
    final bool hasFollowRequest = devotee.followingRequestsStatus == true;

    // Set loading state
    setState(() {
      _loadingFollowIds.add(devoteeId);
    });

    try {
      if (isCurrentlyFollowing) {
        // Already following -> Unfollow
        await exploreDevalayCubit.postFollowing(
          followingUserId: devoteeId,
          userId: currentUserId,
          isFollowing: false,
        );
      } else if (hasFollowRequest) {
        // Follow request sent -> Cancel request
        await exploreDevalayCubit.postFollowing(
          followingUserId: devoteeId,
          userId: currentUserId,
          isFollowing: false,
        );
      } else {
        // Not following -> Send follow request
        await exploreDevalayCubit.postFollowing(
          followingUserId: devoteeId,
          userId: currentUserId,
          isFollowing: true,
        );
      }
    } catch (e) {
      debugPrint('Follow error: $e');
    } finally {
      // Remove loading state
      if (mounted) {
        setState(() {
          _loadingFollowIds.remove(devoteeId);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.appbarBgColor,
          onRefresh: () async {
            await exploreDevalayCubit.fetchGetAllExploreDevoteesData();
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
                  builder: (context, state) {
                    
                    if (state is ExploreDevalayLoaded) {
                      if (state.exploreDevotees == null ||
                          state.exploreDevotees!.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator()
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.exploreDevotees!.length + 1,
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 8.h),
                        itemBuilder: (context, index) {
                          if (index < state.exploreDevotees!.length) {
                            final devotee = state.exploreDevotees![index];
                            final devoteeId = int.tryParse(devotee.id.toString()) ?? 0;
                            final isLoading = _loadingFollowIds.contains(devoteeId);
                            return buildDevoteeCard(
                              devotee: devotee,
                              usedId: userid ?? '',
                              index: index,
                              context: context,
                              isLoading: isLoading,
                              onFollowPressed: () => handleFollowToggle(devotee),
                            );
                          } else {
                            return state.loadingState
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: const Center(
                                        child: CustomLottieLoader()),
                                  )
                                : const SizedBox();
                          }
                        },
                      );
                    }
                       return Center(
                          child: NoMediaView(
                            onRefresh: () {
                              exploreDevalayCubit
                                  .fetchGetAllExploreDevoteesData(
                                      loadMoreData: true);
                            },
                            title: StringConstant.noDataAvailable,
                            subtitle: StringConstant.noDataMessage,
                            icon: Icons.refresh,
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma-style People Card - Real-time follow like postCard.dart
/// - Avatar: 56x56 circular
/// - Name: Bold, black
/// - Stats: "100K followers · 660"
/// - Follow Button: Orange filled (Following) / Grey (Requested) / White outline (Follow)
Widget buildDevoteeCard({
  required ExploreUser devotee,
  required String usedId,
  required int index,
  required BuildContext context,
  required bool isLoading,
  required VoidCallback onFollowPressed,
}) {
  // Determine follow status - same logic as postCard.dart
  final bool isFollowing = devotee.followingStatus == true;
  final bool hasFollowRequest = devotee.followingRequestsStatus == true;

  // Get button text based on status (like postCard.dart)
  String buttonText;
  if (isFollowing) {
    buttonText = StringConstant.following;
  } else if (hasFollowRequest) {
    buttonText = StringConstant.requestSent;
  } else {
    buttonText = StringConstant.follow;
  }

  // Format follower count (e.g., 100K)
  String formatCount(int? count) {
    if (count == null || count == 0) return '0';
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
  }

  // Get follower count - check if followers list exists, otherwise default to 0
  final followerCount = formatCount(
    devotee.followers != null ? devotee.followers!.length : 0,
  );
  final postCount = devotee.postCount?.toString() ?? '0';

  return Container(
    margin: EdgeInsets.only(bottom: 4.h),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileMainScreen(
                id: int.parse(devotee.id.toString()),
                profileType: "Devotee",
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              // Avatar (56x56 circular) - Figma style
              Hero(
                tag: 'devotee_${devotee.id}',
                child: GestureDetector(
                  onTap: () {
                    if (devotee.dp != null) {
                      ImageHelper.showImagePreview(
                          context, devotee.dp.toString());
                    }
                  },
                  child: ClipOval(
                    child: CustomCacheImage(
                      isPerson: true,
                      imageUrl: devotee.dp ?? StringConstant.defaultImage,
                      height: 56.h,
                      width: 56.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Gap(12.w),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name (Bold)
                    Text(
                      devotee.name ?? StringConstant.noName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(2.h),
                    // Stats: "100K followers · 660"
                    Text(
                      '$followerCount followers  $postCount posts',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(8.w),
              // Follow Button (Real-time like postCard.dart)
              SizedBox(
                width: 90.w,
                height: 28.h,
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.orangeColor,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: onFollowPressed,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? AppColor.orangeColor
                              : hasFollowRequest
                                  ? Colors.grey.shade300
                                  : Colors.white,
                          foregroundColor: isFollowing
                              ? Colors.white
                              : Colors.black87,
                          side: BorderSide(
                            color: isFollowing
                                ? AppColor.orangeColor
                                : Colors.grey.shade400,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
