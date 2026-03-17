import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/explore/explore_event/explore_event_cubit.dart';
import '../../../application/explore/explore_event/explore_event_state.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../widget/custom_tile_explore.dart';
import 'explore_event_details.dart';

class ExploreEvent extends StatefulWidget {
  const ExploreEvent({super.key});

  @override
  State<ExploreEvent> createState() => _ExploreEventState();
}

class _ExploreEventState extends State<ExploreEvent> {
  final scrollController = ScrollController();
       late bool isGuest;
   
  @override
  void initState() {
    super.initState();
    getGuest();



    context.read<ExploreEventCubit>().fetchExploreEventData();
    scrollController.addListener(scrollListener);
  }
void getGuest() async {
  isGuest = await PrefManager.getIsGuest();
  }
  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ExploreEventCubit>()
          .fetchExploreEventData(loadMoreData: true);
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreEventCubit, ExploreEventState>(
        builder: (context, state) {
      if (state is ExploreEventLoaded) {
        if (state.loadingState && (state.exploreEventList?.isEmpty ?? false)) {
          return const Center(child: CustomLottieLoader());
        }
        if (state.errorMessage.isNotEmpty) {
          return Center(child: Text(state.errorMessage));
        }
        final exploreEventList = state.exploreEventList;
        if (exploreEventList == null || exploreEventList.isEmpty) {
          return Center(child: Text(StringConstant.noDataAvailable));
        }

        return Padding(
          padding:
              EdgeInsets.only(top: 10.h, left: 13.h, right: 13.h, bottom: 10.h),
          child: SingleChildScrollView(
            controller: scrollController,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: exploreEventList.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = exploreEventList[index];
                  final imageUrl = (item.images?.banner != null &&
                          item.images!.banner!.isNotEmpty)
                      ? item.images!.banner!.first.image
                      : StringConstant.defaultImage;
                  return CustomTile(
                    boxOnTap: () {
                      isGuest == true ? showGuestLoginDialog(context) :
   
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ExploreEventDetails(id: item.id.toString())));
                    },
                    favoriteOnTap: () {
                     isGuest == true ? showGuestLoginDialog(context) :
    context.read<ExploreEventCubit>().changeLikeStatus(
                          item.id.toString(), item.liked! ? 'false' : 'true');
                    },
                    saveOnTap: () {
                    isGuest == true ? showGuestLoginDialog(context) :
     context.read<ExploreEventCubit>().changeSavedStatus(
                          item.id.toString(), item.saved! ? 'false' : 'true');
                    },
                    imageUrl: imageUrl ?? StringConstant.defaultImage,
                    location: "${formatDate(item.dates?[0].startDate.toString() ??'')} to ${formatDate(item.dates?[0].endDate.toString() ??'')}, ${item.city??''}",
                    title: item.title ?? '',
                    likes: item.likedCount ?? 0,
                    bookmarks: item.savedCount ?? 0,
                    viewedCount: item.viewedCount ?? 0,
                    isLiked: item.liked ?? false,
                    isSaved: item.saved ?? false,
                  );
                }),
          ),
        );
      }
      return const Center(child: CustomLottieLoader());
    });
  }
}
