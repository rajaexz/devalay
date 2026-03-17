import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../application/explore/explore_devalay/explore_devalay_cubit.dart';
import '../../../application/explore/explore_devalay/explore_devalay_state.dart';
import '../../../application/feed/feed_home/feed_home_cubit.dart';
import '../../../application/feed/feed_home/feed_home_state.dart';
import '../../../core/shared_preference.dart';
import '../../../data/model/explore/explore_devotees_model.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../../core/utils/colors.dart';
import '../../core/widget/custom_cache_image.dart';
import '../custom_widget/custom_intro_button.dart';

class FollowPeopleScreen extends StatefulWidget {
  const FollowPeopleScreen({super.key, required this.onNext, this.onBack});
  final Function() onNext;
  final VoidCallback? onBack;

  @override
  State<FollowPeopleScreen> createState() => _FollowPeopleScreenState();
}

class _FollowPeopleScreenState extends State<FollowPeopleScreen> {
  late ExploreDevalayCubit exploreDevalayCubit;
  final ScrollController _scrollController = ScrollController();
  String? userid;

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
            builder: (context, state) {
              if (state is ExploreDevalayLoaded) {
                if (state.exploreDevotees == null ||
                    state.exploreDevotees!.isEmpty) {
                  // return Center(
                  //   child: NoMediaView(
                  //     onRefresh: () {
                  //       exploreDevalayCubit.fetchGetAllExploreDevoteesData(
                  //           loadMoreData: true);
                  //     },
                  //     title: StringConstant.noDataAvailable,
                  //     subtitle: StringConstant.noDataMessage,
                  //     icon: Icons.refresh,
                  //   ),
                  // );
                   return const Center(child: CustomLottieLoader());
                }

                return ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.exploreDevotees!.length + 1,
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                  ),
                  itemBuilder: (context, index) {
                    if (index < state.exploreDevotees!.length) {
                      final devotee = state.exploreDevotees![index];
                      return Column(
                        children: [
                          buildDevoteeCard(
                              devotee, userid ?? '', index, context),
                        ],
                      );
                    } else {
                      return state.loadingState
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(child: CustomLottieLoader()),
                            )
                          : const SizedBox();
                    }
                  },
                );
              }
              return const Center(child: CustomLottieLoader());
            },
          ),
        ),
        Gap(25.h),
        Expanded(
          flex: 1,
          child: CustomIntroButton(
            calledFrom: "first",
            onNextTap: () {
              widget.onNext();
            },
            // onBackTap: () {
            //   widget.onNext;
            // },
          ),
        ),
        Gap(25.h),
      ],
    );
  }
}

Widget buildDevoteeCard(
    ExploreUser devotee, String userId, index, BuildContext context) {
  return Container(
    margin: EdgeInsets.only(bottom: 4.h),
    child: Card(
      elevation: 2.5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CustomCacheImage(
                  imageUrl: devotee.dp ?? StringConstant.defaultImage,
                  height: 56.sp,
                  width: 56.sp,
                  borderRadius: BorderRadius.circular(30.sp),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        devotee.name ?? StringConstant.noName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColor.blackColor),
                      ),
                      Gap(2.h),
                        Row(
                          children: [
                            Text(
                            "${devotee.followers?.length ?? 0} followers",
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                      fontSize: 12.sp,
                                      ),
                            ),
                            Gap(5.w),
                            Text(
                            "${devotee.postCount ?? 0} posts",
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                      fontSize: 12.sp,
                                      ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BlocBuilder<FeedHomeCubit, FeedHomeState>(
                  builder: (context, state) {
                    final isFollowingRequest =
                        devotee.followingRequests ?? false;
                    final isFollowing = devotee.following ?? false;
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
                        if (
                        // userId == null ||
                            devotee.id == null
                        // ||
                            // clickedPostIndex == null
                        ) {
                          return;
                        }

                        final feedHomeCubit =
                        context.read<FeedHomeCubit>();
                        if (isFollowing) {
                          await feedHomeCubit.feedPostFollowing(
                            followingUserId: devotee.id!,
                            userId: int.parse(userId),
                            isFollowing: false,
                            clickedPostIndex: 0,
                          );
                          devotee.following = false;
                        } else {
                          if (!isFollowing && isFollowingRequest) {
                            await feedHomeCubit.feedPostFollowingRequest(
                              followingUserId: devotee.id!,
                              userId: int.parse(userId),
                              isFollowing: false,
                              clickedPostIndex: 0,
                            );
                            devotee.followingRequests = false;
                          } else {
                            await feedHomeCubit.feedPostFollowingRequest(
                              followingUserId: devotee.id!,
                              userId: int.parse(userId),
                              isFollowing: true,
                              clickedPostIndex: 0,
                            );
                            devotee.followingRequests = true;
                          }
                        }
                        // Refresh the explore devotees list after follow action
                        context.read<ExploreDevalayCubit>().fetchGetAllExploreDevoteesData(isUpdate: true);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 3.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
