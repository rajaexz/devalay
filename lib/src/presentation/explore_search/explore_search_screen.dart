import 'package:devalay_app/src/core/router/router.dart' show AppRouter;
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart';
import 'package:devalay_app/src/presentation/explore_search/people/explore_people.dart';
import 'package:devalay_app/src/presentation/explore_search/temple/explore_temple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../application/profile/profile_info_about/profile_info_cubit.dart';
import '../../application/profile/profile_info_about/profile_info_state.dart';
import '../../core/shared_preference.dart';
import '../core/constants/strings.dart';
import '../core/widget/custom_cache_image.dart';
import '../profile/profile_main_screen.dart';
import 'dev/explore_dev.dart';
import 'event/explore_event.dart';
import 'festival/explore_festival.dart';

class ExploreSearchScreen extends StatefulWidget {
  const ExploreSearchScreen({super.key});

  @override
  State<ExploreSearchScreen> createState() => _ExploreSearchScreenState();
}

class _ExploreSearchScreenState extends State<ExploreSearchScreen>
    with SingleTickerProviderStateMixin {
    
  late TabController _tabController;
  String? userId;
  bool isLoading = true;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
    loadUserImage();
    getGuest();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }
  void getGuest() async {
    final bool value = await PrefManager.getIsGuest();
    if (!mounted) return;
    setState(() {
      isGuest = value;
    });
  }
  Future<void> loadUserImage() async {
    userId = await PrefManager.getUserDevalayId();
    setState(() {
      isLoading = false;
    });
  }

  // Fixed whichTab function to handle all 6 tabs
  String whichTab(int index) {
    switch (index) {
      // case 0:
        // return "Posts";
      case 0:
        return "Temple";
      case 1:
        return "Event";
      case 2:
        return "People";
      case 3:
        return "Dev";
      case 4:
        return "Festival";
      default:
        return "Posts"; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Gap(12.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [


                  Expanded(
                    child: InkWell(
                      onTap: () {
                      
                        AppRouter.push(
                            "${RouterConstant.templeSearchScreen}/${whichTab(_tabController.index)}");
                      },
                      child: Container(
                        width: 286.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColor.lightGrayColor,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15.sp),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icon/search_icon.svg",
                              height: 13.h,
                              width: 12.w,
                              color: const Color(0xff3C3C43),
                            ),
                            Gap(5.w),
                            Text(
                              StringConstant.search,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: const Color(0xff3C3C43)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap(4.w),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileMainScreen(
                            id: int.tryParse(userId ?? '0') ?? 0,
                            profileType: "profile",
                          ),
                        ),
                      );
                    },
                    icon: ClipOval(
                      child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                        builder: (context, state) {
                          final imageUrl = (state is ProfileInfoLoaded )
                              ? state.profileInfoModel!.dp
                              : StringConstant.defaultImage;
                          return CustomCacheImage(
                              isPerson: true,
                              imageUrl: imageUrl, height: 50.h, width: 50.h);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Gap(16.h),
            TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColor.blackColor,
              indicatorWeight: 1,
              indicator: UnderlineTabIndicator(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4.r),
                  topLeft: Radius.circular(4.r),
                ),
                borderSide: BorderSide(width: 3.w, color: AppColor.blackColor),
                insets: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              labelColor: AppColor.blackColor,
              unselectedLabelColor: AppColor.blackColor,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              tabs: [
                // Tab(text: StringConstant.posts),
                Tab(text: StringConstant.temples),
                Tab(text: StringConstant.events),
                Tab(text: StringConstant.people),
                Tab(text: StringConstant.devs),
                Tab(text: StringConstant.festivals),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:  [
                  // ExplorePost(),
                  const ExploreTemple(),
                  const ExploreEvent(),
                  isGuest == true ? const GuestPopScreen() :   const ExplorePeople(),
                  const ExploreDev(),
                  const ExploreFestival(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
