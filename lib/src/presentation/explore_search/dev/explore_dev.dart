import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart'
    show showGuestLoginDialog;
import 'package:devalay_app/src/presentation/explore_search/dev/explore_dev_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/explore/explore_dev/explore_dev_cubit.dart';
import '../../../application/explore/explore_dev/explore_dev_state.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../widget/custom_tile_festival.dart';

class ExploreDev extends StatefulWidget {
  const ExploreDev({super.key});

  @override
  State<ExploreDev> createState() => _ExploreDevState();
}

class _ExploreDevState extends State<ExploreDev> {
  final scrollController = ScrollController();
  late bool isGuest;
  @override
  void initState() {
    super.initState();
    getGuest();
    context.read<ExploreDevCubit>().fetchExploreDevData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context.read<ExploreDevCubit>().fetchExploreDevData(loadMoreData: true);
    }
  }

  void getGuest() async {
    isGuest = await PrefManager.getIsGuest();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ExploreDevCubit, ExploreDevState>(
        builder: (context, state) {
          if (state is ExploreDevLoaded) {
            if (state.loadingState &&
                (state.exploreDevList?.isEmpty ?? false)) {
              return const Center(child: CustomLottieLoader());
            }
            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }

            final exploreDevList = state.exploreDevList;
            if (exploreDevList == null || exploreDevList.isEmpty) {
              return Center(child: Text(StringConstant.noDataAvailable));
            }

            return Padding(
              padding: EdgeInsets.all(10.sp),
              child: SingleChildScrollView(
                  controller: scrollController,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exploreDevList.length,
                      itemBuilder: (context, index) {
                        final item = exploreDevList[index];
                        final imageUrl = (item.images?.gallery != null &&
                                item.images!.gallery!.isNotEmpty)
                            ? item.images!.gallery!.first.image
                            : StringConstant.defaultImage;
                        return CustomTileFestival(
                          boxOnTap: () {
                            isGuest == true
                                ? showGuestLoginDialog(context)
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExploreDevDetails(
                                            id: item.id.toString())));
                          },
                          favoriteOnTap: () {
                            bool islike = !item.liked!;
                            isGuest == true
                                ? showGuestLoginDialog(context)
                                : context
                                    .read<ExploreDevCubit>()
                                    .changeLikeStatus(
                                      item.id.toString(),
                                      islike.toString(),
                                    );
                          },
                          saveOnTap: () {
                            isGuest == true
                                ? showGuestLoginDialog(context)
                                : context
                                    .read<ExploreDevCubit>()
                                    .changeSavedStatus(item.id.toString(),
                                        item.saved! ? 'false' : 'true');
                          },
                          imageUrl: imageUrl ?? StringConstant.defaultImage,
                          location: item.subtitle ?? '',
                          title: item.title ?? '',
                          likes: item.likedCount ?? 0,
                          bookmarks: item.savedCount ?? 0,
                          viewedCount: item.viewedCount ?? 0,
                          isLiked: item.liked ?? false,
                          isSaved: item.saved ?? false,
                        );
                      })),
            );
          }
          return const Center(child: CustomLottieLoader());
        },
      ),
    );
  }
}
