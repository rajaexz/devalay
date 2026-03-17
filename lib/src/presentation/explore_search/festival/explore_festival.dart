import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart' show showGuestLoginDialog;
import 'package:devalay_app/src/presentation/explore_search/festival/explore_festival_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/explore/explore_festival/explore_festival_cubit.dart';
import '../../../application/explore/explore_festival/explore_festival_state.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../widget/custom_tile_festival.dart';

class ExploreFestival extends StatefulWidget {
  const ExploreFestival({super.key});

  @override
  State<ExploreFestival> createState() => _ExploreFestivalState();
}

class _ExploreFestivalState extends State<ExploreFestival> {
  final scrollController = ScrollController();
  late ExploreFestivalCubit exploreFestivalCubit;
late bool isGuest;
  @override
  void initState() {
    super.initState();
    getGuest();
    exploreFestivalCubit = context.read<ExploreFestivalCubit>();
    exploreFestivalCubit.fetchExploreFestivalData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ExploreFestivalCubit>()
          .fetchExploreFestivalData(loadMoreData: true);
    }
  }
  void getGuest() async {
  isGuest = await PrefManager.getIsGuest();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreFestivalCubit, ExploreFestivalState>(
        builder: (context, state) {
      if (state is ExploreFestivalLoaded) {
        if (state.loadingState &&
            (state.exploreFestivalList?.isEmpty ?? false)) {
          return const Center(child: CustomLottieLoader());
        }
        if (state.errorMessage.isNotEmpty) {
          return Center(child: Text(state.errorMessage));
        }
        final exploreFestivalList = state.exploreFestivalList;
        if (exploreFestivalList == null || exploreFestivalList.isEmpty) {
          return Center(child: Text(StringConstant.noDataAvailable));
        }
        return Padding(
          padding: EdgeInsets.all(10.sp),
          child: SingleChildScrollView(
              controller: scrollController,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exploreFestivalList.length,
                  itemBuilder: (context, index) {
                    final item = exploreFestivalList[index];
                    final imageUrl = (item.images?.gallery != null &&
                            item.images!.gallery!.isNotEmpty)
                        ? item.images!.gallery!.first.image
                        : StringConstant.defaultImage;
                    return CustomTileFestival(
                      boxOnTap: () {
                     isGuest == true ? showGuestLoginDialog(context) :   Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ExploreFestivalDetails(id: item.id.toString())));
                      },
                      favoriteOnTap: () {
                        isGuest == true ? showGuestLoginDialog(context) :context.read<ExploreFestivalCubit>().changeLikeStatus(
                            item.id.toString(),
                            item.liked! ? 'false' : 'true');
                      },
                      saveOnTap: (){
                        isGuest == true ? showGuestLoginDialog(context) :context.read<ExploreFestivalCubit>().changeSavedStatus(
                            item.id.toString(), item.saved! ? 'false' : 'true');
                      },
                      imageUrl: imageUrl ?? StringConstant.defaultImage,
                      location: item.subtitle ?? '',
                      title: item.title ?? '',
                      likes: item.likedCount ?? 0,
                      bookmarks: item.savedCount ?? 0,
                      viewedCount: item.viewedCount,
                      isLiked: item.liked ?? false,
                      isSaved: item.saved ?? false,
                    );
                  })
              ),
        );
      }
      return const Center(child: CustomLottieLoader());
    });
  }
}
