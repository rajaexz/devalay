import 'package:devalay_app/src/presentation/explore_search/event/widget/about_event.dart';
import 'package:devalay_app/src/presentation/explore_search/event/widget/mentions_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../../application/explore/explore_event/explore_event_cubit.dart';
import '../../../application/explore/explore_event/explore_event_state.dart';
import '../../../data/model/explore/single_event_model.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/image_Helper.dart';
import '../../core/helper/loader.dart';
import '../../core/helper/sharing_service.dart';
import '../../core/utils/colors.dart';
import '../../core/widget/custom_cache_image.dart';
import '../widget/custom_explore.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreEventDetails extends StatefulWidget {
  final String id;
  const ExploreEventDetails({super.key, required this.id});

  @override
  State<ExploreEventDetails> createState() => _ExploreEventDetailsState();
}

class _ExploreEventDetailsState extends State<ExploreEventDetails>
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
      context.read<ExploreEventCubit>().fetchSingleEventData(widget.id);
    }

    _tabController = TabController(length: myTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    _initializeTabWidgets();
    getViewed();
  }

  void getViewed() async {
    await context.read<ExploreEventCubit>().changeViewStatus(widget.id);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {
        selectedIndex = _tabController.index;
      });

      // Load mention data only when Mentions tab is selected and widget is not yet created
      if (selectedIndex == 1 && _mentionWidget == null) {
        _loadMentionData();
      }
    }
  }

  void _initializeTabWidgets() {
    _aboutWidget = null; // This will be created dynamically in getSelectedTabContent
    _mentionWidget = null; // This will be created when needed
  }

  void _loadMentionData() {
    if (_mentionWidget == null && mounted) {
      setState(() {
        _mentionWidget = MentionEvent(id: widget.id);
      });
    }
  }

  Future<void> _openLocationInMap(String address) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    final String appleMapsUrl = 'https://maps.apple.com/?q=${Uri.encodeComponent(address)}';

    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
          await launchUrl(Uri.parse(appleMapsUrl), mode: LaunchMode.externalApplication);
        } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
        }
      } else {
        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Widget getSelectedTabContent(SingleEventModel? singleEvent) {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
          child: AboutEvent(singleEvent: singleEvent),
        );
      case 1:
      // Return cached widget if available, otherwise show loader and trigger creation
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
        child: BlocBuilder<ExploreEventCubit, ExploreEventState>(
          builder: (context, state) {
            if (state is ExploreEventLoaded) {
              if (state.loadingState && state.singleEvent == null) {
                return const Scaffold(
                  body: Center(child: CustomLottieLoader()),
                );
              }
              if (state.errorMessage.isNotEmpty &&
                  state.singleEvent == null) {
                return Scaffold(
                  body: Center(child: Text(state.errorMessage)),
                );
              }

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColor.whiteColor,
                  elevation: 0,
                  leadingWidth: 30.sp,
                  leading: InkWell(
                    onTap: () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColor.blackColor,
                    ),
                  ),
                  title: Text(
                    state.singleEvent?.title ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    final bannerList = state.singleEvent?.images?.banner;
                    final imageUrl = (bannerList != null && bannerList.isNotEmpty)
                        ? bannerList[0].image ?? StringConstant.defaultImage
                        : StringConstant.defaultImage;
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  ImageHelper.showImagePreview(context, imageUrl);
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
                              padding: EdgeInsets.symmetric(horizontal: 15.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      _openLocationInMap(
                                          state.singleEvent?.address ?? '');
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset("assets/icon/location_redirect.svg",),
                                        Gap(10.w),
                                        Expanded(
                                          child: Text(
                                            state.singleEvent?.address ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: AppColor.blackColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Gap(20.h),
                                  CustomExplore(
                                    favoriteIcon:
                                    state.singleEvent?.liked == true
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
                                    state.singleEvent?.saved == true
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
                                            .read<ExploreEventCubit>()
                                            .fetchExploreEventData();
                                      }
                                    },
                                    favoriteOnTap: () {
                                      if (mounted) {
                                        context
                                            .read<ExploreEventCubit>()
                                            .changeSingleLikeStatus(
                                            state.singleEvent?.id
                                                .toString(),
                                            state.singleEvent!.liked!
                                                ? 'false'
                                                : 'true');
                                      }
                                    },
                                    shareOnTap: () {
                                      SharingService.shareContent(
                                          contentType: 'Event',
                                          id: state.singleEvent!.id
                                              .toString(),
                                        );
                                    },
                                    saveOnTap: () {
                                      if (mounted) {
                                        context
                                            .read<ExploreEventCubit>()
                                            .changeSingleSavedStatus(
                                            state.singleEvent?.id
                                                .toString(),
                                            state.singleEvent!.saved!
                                                ? 'false'
                                                : 'true');
                                      }
                                    },
                                    likedCount: state.singleEvent?.likedCount
                                        .toString(),
                                    savedCount: state.singleEvent?.savedCount
                                        .toString() ??
                                        '0',
                                    viewedCount: state.singleEvent?.viewedCount.toString() ??'0',
                                  ),
                                  Gap(26.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black,
                            indicatorColor: Colors.black,
                            indicatorWeight: 3,
                            tabs: myTabs,
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: getSelectedTabContent(state.singleEvent),
                  ),
                ),
              );
            }
            return const Scaffold(
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


