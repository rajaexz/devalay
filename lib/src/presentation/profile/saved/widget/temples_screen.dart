import 'package:devalay_app/src/application/profile/profile_saved/profile_saved_cubit.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/profile/saved/widget/temple_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../application/profile/profile_saved/profile_saved_state.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/sharing_service.dart';

class TemplesScreen extends StatefulWidget {
  const TemplesScreen({super.key});

  @override
  State<TemplesScreen> createState() => _TemplesScreenState();
}

class _TemplesScreenState extends State<TemplesScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileSavedCubit>().fetchProfileSaveTempleData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ProfileSavedCubit>()
          .fetchProfileSaveTempleData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _onLike(int itemId) {
    context.read<ProfileSavedCubit>().toggleTempleLike(itemId);
  }

  void _onSave(int itemId) {
    context.read<ProfileSavedCubit>().toggleTempleSave(itemId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileSavedCubit, ProfileSavedState>(
      builder: (context, state) {
        if (state is ProfileSavedLoaded) {
          if (state.loadingState && (state.savedTempleModel?.isEmpty ?? true)) {
            return const Center(
              child: CustomLottieLoader(),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProfileSavedCubit>()
                          .fetchProfileSaveTempleData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.savedTempleModel?.isEmpty ?? true) {
            return Center(child: Text(StringConstant.noDataAvailable));
          }

          final templeItems = state.savedTempleModel!;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: ListView(
              controller: scrollController,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: templeItems.length,
                  itemBuilder: (context, index) {
                    final item = templeItems[index];
                    final itemId = item.id ?? 0;
                    final hasImage = item.images?.banner != null &&
                        item.images!.banner!.isNotEmpty;
                    final imageUrl =
                        hasImage ? item.images!.banner![0].image : null;

                    return CustomTile(
                      onTap: (){
                        AppRouter.push("/singleDevalay/${item.id.toString()}");
                      },
                      imageUrl: imageUrl ?? '',
                      title: item.title ?? StringConstant.noTitle,
                      dateRange: HelperClass.timeAgo(item.createdAt ?? ''),
                      likes: item.likedCount ?? 0,
                      bookmarks: item.savedCount ?? 0,
                      isLiked: item.liked ?? false,
                      isSaved: item.saved ?? false,
                      location: item.location ?? StringConstant.noLocation,
                      likeOnTap: () => _onLike(itemId),
                      saveOnTap: () => _onSave(itemId),
                      shareOnTap: () {
                        SharingService.shareContent(
                            contentType: 'Devalay',
                            id: item.id
                                .toString(),
                            );
                      },
                    );
                  },
                ),
                if (state.loadingState)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CustomLottieLoader()),
                  )
              ],
            ),
          );
        }

        return const Center(
          child: CustomLottieLoader(),
        );
      },
    );
  }
}
