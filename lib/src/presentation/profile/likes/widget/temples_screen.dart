import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_state.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/profile/saved/widget/temple_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import '../../../core/constants/strings.dart';

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
    context.read<ProfileLikedTempleCubit>().fetchProfileLikedTempleData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      context.read<ProfileLikedTempleCubit>().fetchProfileLikedTempleData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileLikedTempleCubit, ProfileLikedTempleState>(
      builder: (context, state) {
        if (state is ProfileLikedTempleLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }
          if (state.likeTemplesModel?.isEmpty ?? true) {
            return Center(child: Text(StringConstant.noDataAvailable));
          }

          final templeItems = state.likeTemplesModel;
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: (templeItems?.length ?? 0) + (state.loadingState ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == templeItems!.length) {
                return const Center(child: CustomLottieLoader());
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: CustomTile(
                  imageUrl: templeItems[index].images?.banner?[0].image ?? StringConstant.defaultImage,
                  location: templeItems[index].location ?? StringConstant.noLocation,
                  title: templeItems[index].title ?? StringConstant.noName,
                  dateRange: HelperClass.timeAgo(templeItems[index].createdAt ?? ''),
                  likes: templeItems[index].likedCount ?? 0,
                  bookmarks: templeItems[index].savedCount ?? 0,
                  isLiked: templeItems[index].liked ?? false,
                  isSaved: templeItems[index].saved ?? false,
                  likeOnTap: () {
                    context.read<ProfileLikedTempleCubit>().likeTemple(templeItems[index].id ?? 0, templeItems[index].liked == true ? false : true);
                  },
                  shareOnTap: () {
                    
                  },
                  saveOnTap: () {
                    context.read<ProfileLikedTempleCubit>().saveTemple(templeItems[index].id ?? 0, templeItems[index].saved == true ? false : true);
                  },
                ),
              );
            },
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }
}
