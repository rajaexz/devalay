import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../application/profile/profile_saved/profile_saved_cubit.dart';
import '../../../../application/profile/profile_saved/profile_saved_state.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/helper/loader.dart';
import 'package:devalay_app/src/presentation/profile/saved/widget/temple_widget.dart';

import '../../../core/helper/sharing_service.dart';
import '../../../explore_search/dev/explore_dev_details.dart';

class DevsScreen extends StatefulWidget {
  const DevsScreen({super.key});

  @override
  State<DevsScreen> createState() => _DevsScreenState();
}

class _DevsScreenState extends State<DevsScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileSavedCubit>().fetchProfileSavedDevsData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ProfileSavedCubit>()
          .fetchProfileSavedDevsData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileSavedCubit, ProfileSavedState>(
        builder: (context, state) {
      if (state is ProfileSavedLoaded) {
        if (state.loadingState) {
          return const Center(
            child: CustomLottieLoader(),
          );
        }
        if (state.errorMessage.isNotEmpty) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        if (state.saveDevModel?.isEmpty ?? true) {
          return Center(child: Text(StringConstant.noDataAvailable));
        }
        final eventsItems = state.saveDevModel;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: ListView(controller: scrollController, children: [
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eventsItems?.length,
                itemBuilder: (context, index) {
                  final item = eventsItems![index];
                  final hasImage = item.images?.banner != null &&
                      item.images!.banner!.isNotEmpty;
                  final imageUrl =
                      hasImage ? item.images!.banner![0].image : null;
                  return CustomTile(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExploreDevDetails(
                                  id: item.id.toString())));
                    },
                    imageUrl: imageUrl ?? '',
                    title: item.title ?? StringConstant.noTitle,
                    dateRange: HelperClass.timeAgo(item.createdAt ?? ''),
                    likes: item.likedCount ?? 0,
                    bookmarks: item.savedCount ?? 0,
                    isLiked: item.liked ?? false,
                    isSaved: item.saved ?? false,
                    shareOnTap: () {
                      SharingService.shareContent(
                          contentType: 'Dev',
                          id: item.id
                              .toString(),
                        );
                    },
                    likeOnTap: () {
                      // final currentlyLiked = item.liked ?? false;
                      context
                          .read<ProfileSavedCubit>()
                          .toggleDevLike(item.id ?? 0);
                    },
                    saveOnTap: () {
                      final currentlySaved = item.saved ?? false;
                      context
                          .read<ProfileSavedCubit>()
                          .saveDev(item.id ?? 0, !currentlySaved);
                    },
                    location: StringConstant.noLocation,
                  );
                }),
            if (state.loadingState) const Center(child: CustomLottieLoader())
          ]),
        );
      }
      return const Center(
        child: CustomLottieLoader(),
      );
    });
  }
}
