import 'package:devalay_app/src/presentation/explore_search/dev/widget/about_dev.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../application/explore/explore_dev/explore_dev_cubit.dart';
import '../../../application/explore/explore_dev/explore_dev_state.dart';
import '../../../data/model/explore/single_gods_model.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/image_Helper.dart';
import '../../core/helper/loader.dart';
import '../../core/helper/sharing_service.dart';
import '../../core/utils/colors.dart';
import '../../core/widget/custom_cache_image.dart';
import '../widget/custom_explore.dart';

class ExploreDevDetails extends StatefulWidget {
  final String id;
  const ExploreDevDetails({super.key, required this.id});

  @override
  State<ExploreDevDetails> createState() => _ExploreDevDetailsState();
}

class _ExploreDevDetailsState extends State<ExploreDevDetails>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  List<Tab> get myTabs => [
    Tab(text: StringConstant.about),
    Tab(text: StringConstant.mentions),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ExploreDevCubit>().fetchSingleExploreGodData(widget.id);
    _tabController = TabController(length: myTabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          selectedIndex = _tabController.index;
        });
      }
    });
    getViewed();
  }

  void getViewed() async {
    await context.read<ExploreDevCubit>().changeViewStatus(widget.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget getSelectedTabContent(SingleGodModel? singleGod) {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
          child: AboutDev(
            singleGod: singleGod,
          ),
        );
      case 1:
        return const Center(child: Text("No Data"),);
      default:
        return const SizedBox();
    }}

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        top: false,
        child: BlocBuilder<ExploreDevCubit, ExploreDevState>(
          builder: (context, state) {
            if (state is ExploreDevLoaded) {
              if (state.loadingState) {
                return const Scaffold(
                  body: Center(child: CustomLottieLoader()),
                );
              }
              if (state.errorMessage.isNotEmpty) {
                return Center(child: Text(state.errorMessage));
              }

              return Scaffold(
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
                        )),
                    title: Text(
                      state.singleGod?.title ?? "",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColor.blackColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  body: NestedScrollView(headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                    final bannerList = state.singleGod?.images?.banner;
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
                                  Text(
                                    state.singleGod?.subtitle ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColor.blackColor),
                                  ),
                                  Gap(20.h),
                                  CustomExplore(
                                    favoriteIcon:
                                    state.singleGod?.liked == true
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
                                    state.singleGod?.saved == true
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
                                            .read<ExploreDevCubit>()
                                            .fetchExploreDevData();
                                      }
                                    },
                                    favoriteOnTap: () {
                                      if (mounted) {
                                        context
                                            .read<ExploreDevCubit>()
                                            .changeSingleLikeStatus(
                                            state.singleGod?.id
                                                .toString(),
                                            state.singleGod!.liked!
                                                ? 'false'
                                                : 'true');
                                      }
                                    },
                                    shareOnTap: () {
                                      SharingService.shareContent(
                                          contentType: 'Dev',
                                          id: state.singleGod!.id
                                              .toString(),
                                         );
                                    },
                                    saveOnTap: () {
                                      if (mounted) {
                                        context
                                            .read<ExploreDevCubit>()
                                            .changeSingleSavedStatus(
                                            state.singleGod?.id
                                                .toString(),
                                            state.singleGod!.saved!
                                                ? 'false'
                                                : 'true');
                                      }
                                    },
                                    likedCount: state.singleGod?.likedCount
                                        .toString(),
                                    savedCount: state.singleGod?.savedCount
                                        .toString() ??
                                        '0',
                                    viewedCount: state.singleGod?.viewedCount.toString() ??'0',

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
                  }, body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: getSelectedTabContent(state.singleGod),
                  ),)
              );
            }

            return const Scaffold(
              body: Center(child: CustomLottieLoader()),
            );
          },
        ),
      );
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
