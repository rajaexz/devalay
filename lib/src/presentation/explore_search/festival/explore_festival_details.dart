import 'package:devalay_app/src/data/model/explore/single_festival_model.dart';
import 'package:devalay_app/src/presentation/explore_search/festival/widget/about_festival.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../application/explore/explore_festival/explore_festival_cubit.dart';
import '../../../application/explore/explore_festival/explore_festival_state.dart';
import '../../../application/feed/feed_home/feed_home_cubit.dart';
import '../../../application/feed/feed_home/feed_home_state.dart';
import '../../../core/shared_preference.dart';
import '../../../data/model/feed/feed_home_model.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/image_Helper.dart';
import '../../core/helper/loader.dart';
import '../../core/helper/sharing_service.dart';
import '../../core/utils/colors.dart';
import '../../core/widget/No_data_found.dart';
import '../../core/widget/custom_cache_image.dart';
import '../../core/widget/translatable_text_widget.dart';
import '../../feed/widget/postCard.dart';
import '../widget/custom_explore.dart';

class ExploreFestivalDetails extends StatefulWidget {
  final String id;
  const ExploreFestivalDetails({super.key, required this.id});

  @override
  State<ExploreFestivalDetails> createState() => _ExploreFestivalDetailsState();
}

class _ExploreFestivalDetailsState extends State<ExploreFestivalDetails>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  Widget? _aboutWidget;
  Widget? _mentionWidget;

  List<Tab> get myTabs => [
    Tab(text: StringConstant.about),
    Tab(text: StringConstant.mentions),
  ];

  @override
  void initState() {
    super.initState();
    if (mounted) {
      context.read<ExploreFestivalCubit>().fetchSingleFestivalData(widget.id);
    }

    _tabController = TabController(length: myTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    _initializeTabWidgets();
    getViewed();
  }

  void getViewed() async {
    await context.read<ExploreFestivalCubit>().changeViewStatus(widget.id);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {
        selectedIndex = _tabController.index;
      });

      if (selectedIndex == 1 && _mentionWidget == null) {
        _loadMentionData();
      }
    }
  }

  void _initializeTabWidgets() {
    _aboutWidget = null;

  }

  void _loadMentionData() {
    if (_mentionWidget == null && mounted) {
      setState(() {
        _mentionWidget = Mention(id: widget.id);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Widget getSelectedTabContent(SingleFestivalModel? singleFestival) {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
          child: AboutFestival(singleFestival: singleFestival),
        );
      case 1:
        if (_mentionWidget != null) {
          return _mentionWidget!;
        } else {
          _loadMentionData();
          return const Center(child: CustomLottieLoader());
        }
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: BlocBuilder<ExploreFestivalCubit, ExploreFestivalState>(
          builder: (context, state) {
            if (state is ExploreFestivalLoaded) {
              if (state.loadingState) {
                return const Scaffold(
                  body: Center(child: CustomLottieLoader()),
                );
              }
              if (state.errorMessage.isNotEmpty) {
                return Scaffold(
                  body: Center(
                      child: Text(
                    state.errorMessage,
                  )),
                );
              }
              return Scaffold(
                  backgroundColor: AppColor.whiteColor,
                  appBar: AppBar(
                    backgroundColor: AppColor.whiteColor,
                    elevation: 0,
                    leadingWidth: 30.sp,
                    leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColor.blackColor,
                      ),
                    ),
                    title: Text(
                      state.singleFestival?.title ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  body: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      final bannerList = state.singleFestival?.images?.banner;
                      final imageUrl = (bannerList != null &&
                              bannerList.isNotEmpty)
                          ? bannerList[0].image ?? StringConstant.defaultImage
                          : StringConstant.defaultImage;
                      return [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    ImageHelper.showImagePreview(
                                        context, imageUrl);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.r),
                                  child: Hero(
                                    tag: imageUrl,
                                    child: CustomCacheImage(
                                      borderRadius: BorderRadius.circular(0.r),
                                      imageUrl: imageUrl,
                                      height: 292.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Gap(12.h),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 15.sp),
                                  child: Column(
                                    children: [
                                    TranslatableTextWidget(
                                      text: state.singleFestival?.subtitle ?? '',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Gap(20.h),
                                    CustomExplore(
                                      favoriteIcon:
                                          state.singleFestival?.liked == true
                                              ? SvgPicture.asset(
                                                  "assets/icon/liked.svg",
                                                  height: 20.h,
                                                  width: 20.w,
                                                )
                                              : SvgPicture.asset(
                                                  "assets/icon/like.svg",
                                                  height: 20.h,
                                                  width: 20.w,
                                                ),
                                      savedIcon:
                                          state.singleFestival?.saved == true
                                              ? SvgPicture.asset(
                                                  "assets/icon/saved.svg",
                                                  height: 20.h,
                                                  width: 20.w,
                                                )
                                              : SvgPicture.asset(
                                                  "assets/icon/active_save_icon.svg",
                                                  height: 20.h,
                                                  width: 20.w,
                                                ),
                                      backOnTap: () {
                                        if (mounted) {
                                          Navigator.pop(context);
                                          context
                                              .read<ExploreFestivalCubit>()
                                              .fetchExploreFestivalData();
                                        }
                                      },
                                      favoriteOnTap: () {
                                        if (mounted) {
                                          context
                                              .read<ExploreFestivalCubit>()
                                              .changeSingleLikeStatus(
                                                  state.singleFestival?.id
                                                      .toString(),
                                                  state.singleFestival!.liked!
                                                      ? 'false'
                                                      : 'true');
                                        }
                                      },
                                      shareOnTap: () {
                                        SharingService.shareContent(
                                            contentType: 'Festival',
                                            id: state.singleFestival!.id
                                                .toString(),
                                           );
                                      },
                                      saveOnTap: () {
                                        if (mounted) {
                                          context
                                              .read<ExploreFestivalCubit>()
                                              .changeSingleSavedStatus(
                                                  state.singleFestival?.id
                                                      .toString(),
                                                  state.singleFestival!.saved!
                                                      ? 'false'
                                                      : 'true');
                                        }
                                      },
                                      likedCount: state
                                          .singleFestival?.likedCount
                                          .toString(),
                                      savedCount: state
                                              .singleFestival?.savedCount
                                              .toString() ??
                                          '0',
                                      viewedCount: state.singleFestival?.viewedCount.toString() ??'0',
                                    ),
                                    Gap(26.h),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.black,
                              indicatorColor: Colors.orange,
                              indicatorWeight: 3,
                              tabs: myTabs)),
                          pinned: true,
                        ),
                      ];
                    },
                    body: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.sp),
                      child: getSelectedTabContent(state.singleFestival),
                    ),
                  ));
            }
            return const Scaffold(
              backgroundColor: AppColor.blackColor,
              body: Center(child: CustomLottieLoader()),
            );
          },
        ));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 15.0.sp),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return _tabBar != oldDelegate._tabBar;
  }
}

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
  ExploreFestivalCubit? _exploreFestivalCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exploreFestivalCubit ??= context.read<ExploreFestivalCubit>();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.id != null) {
        context.read<ExploreFestivalCubit>().resetMentionData();
      }
    });
  }

  @override
  void dispose() {
    _exploreFestivalCubit?.resetMentionData();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ExploreFestivalCubit, ExploreFestivalState>(
      builder: (context, state) {
        if (state is ExploreFestivalLoaded) {
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
              onRefresh: () {},
              title: StringConstant.noDataAvailable,
              subtitle: StringConstant.noDataAvailableSubtitle,
              icon: Icons.podcasts,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
            itemCount: feedList.length,
            itemBuilder: (context, index) {
              return BlocBuilder<FeedHomeCubit, FeedHomeState>(
                builder: (context, feedState) {
                  if (feedState is FeedHomeLoaded &&
                      feedState.feedList != null) {
                    final currentFeed = feedList[index];
                    return PostCardCommon<FeedGetData>(
                      getLikedUsers: (data) => data.likedUsers,
                                    eyes:(data) => data.eyes.toString(),
                  
                      clickedPostIndex: index,
                      feedData: currentFeed,
                      location: (data) => data.location,
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
                          ctx.read<ExploreFestivalCubit>().feedPostDelete(id);
                        }
                      },
                      onSaveToggle: (ctx, id, isSaved) {
                        if (mounted) {
                          ctx
                              .read<ExploreFestivalCubit>()
                              .feedPostSaved(id.toString(), isSaved);
                        }
                      },
                   
                      onLikeToggle: (ctx, id, isLiked) {
                        if (mounted) {
                          ctx
                              .read<ExploreFestivalCubit>()
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

