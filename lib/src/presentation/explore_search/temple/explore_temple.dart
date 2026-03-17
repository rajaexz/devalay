import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart' show PrefManager;
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart' show showGuestLoginDialog;
import 'package:devalay_app/src/presentation/explore_search/widget/custom_tile_explore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/explore/explore_devalay/explore_devalay_cubit.dart';
import '../../../core/router/router.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';

class ExploreTemple extends StatefulWidget {
  const ExploreTemple({super.key});

  @override
  State<ExploreTemple> createState() => _ExploreTempleState();
}

class _ExploreTempleState extends State<ExploreTemple> {
  final scrollController = ScrollController();
       late bool isGuest;
  @override
  void initState() {
    super.initState();

    getGuest();
    context.read<ExploreDevalayCubit>().fetchExploreDevalayData();
    scrollController.addListener(scrollListener);
  }
void getGuest() async {
  isGuest = await PrefManager.getIsGuest();
  }
  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ExploreDevalayCubit>()
          .fetchExploreDevalayData(loadMoreData: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
        builder: (context, state) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      if (state is ExploreDevalayLoaded) {
        if (state.loadingState &&
            (state.exploreDevalayList?.isEmpty ?? false)) {
          return const Center(child: CustomLottieLoader());
        }

        if (state.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              state.errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          );
        }

        final exploreDevalayList = state.exploreDevalayList;

        if (exploreDevalayList == null || exploreDevalayList.isEmpty) {
          return Center(
            child: Text(
              StringConstant.noDataAvailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp),
          child: SingleChildScrollView(
              controller: scrollController,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: exploreDevalayList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = exploreDevalayList[index];
                    final imageUrl = (item.images?.banner != null &&
                            item.images!.banner!.isNotEmpty)
                        ? item.images!.banner!.first.image
                        : StringConstant.defaultImage;
                    return CustomTile(
                      boxOnTap: () {
                        isGuest == true ? showGuestLoginDialog(context) :
   
                        AppRouter.push("/singleDevalay/${item.id.toString()}");
                      },
                      favoriteOnTap: () {
                        bool islike = !item.liked!;
                        isGuest == true ? showGuestLoginDialog(context) :context.read<ExploreDevalayCubit>().changeLikeStatus(
                              item.id.toString(),
                              islike.toString(),
                            );
                      },
                      saveOnTap: () {
                        isGuest == true ? showGuestLoginDialog(context) :context.read<ExploreDevalayCubit>().changeSavedStatus(
                            item.id.toString(), item.saved! ? 'false' : 'true');
                      },
                      imageUrl: imageUrl ?? StringConstant.defaultImage,
                      location: item.city ?? '',
                      title: item.title ?? '',
                      likes: item.likedCount ?? 0,
                      viewedCount: item.viewedCount ?? 0,
                      bookmarks: item.savedCount ?? 0,
                      isLiked: item.liked ?? false,
                      isSaved: item.saved ?? false,
                    );
                  })),
        );
      }
      return const Center(child: CustomLottieLoader());
    });
  }
}
