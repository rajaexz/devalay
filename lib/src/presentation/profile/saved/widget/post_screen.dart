
import 'package:devalay_app/src/application/profile/profile_saved/profile_saved_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
// import 'package:devalay_app/src/presentation/core/widget/image_detail_helper.dart';
import 'package:devalay_app/src/presentation/feed/widget/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import '../../../../application/profile/profile_saved/profile_saved_cubit.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final scrollController = ScrollController();
    String userId  = '';
  @override
  void initState() {
    super.initState();
    getUser();
    context.read<ProfileSavedCubit>().fetchProfileSavedPostData();
    scrollController.addListener(scrollListener);
  }

  getUser()async{
   userId =  (await PrefManager.getUserDevalayId()) ?? '';
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      context.read<ProfileSavedCubit>().fetchProfileSavedPostData(loadMoreData: true);
    }
  }

  Future<void> handleLikeToggle(BuildContext context, String postId, bool isLiked) async {
    await context.read<FeedHomeCubit>().feedPostLike(postId, isLiked);
    if (mounted) {
      context.read<ProfileSavedCubit>().fetchProfileSavedPostData();
    }
  }

  Future<void> handleSaveToggle(BuildContext context, String postId, bool isSaved) async {
    context.read<ProfileSavedCubit>().savePost(postId, isSaved);
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    await context.read<FeedHomeCubit>().feedPostDelete(id);
    if (mounted) {
      context.read<ProfileSavedCubit>().fetchProfileSavedPostData();
    }
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
          if (state.feedList?.isEmpty ?? true) {
            return Center(child: Text(StringConstant.noDataAvailable));
          }
          final templeItems = state.feedList;
          return ListView.builder(
            controller: scrollController,
            itemCount: templeItems?.length ?? 0,
            itemBuilder: (context, index) {
              final post = templeItems?[index];
              if (post == null) return const SizedBox();
              
              return PostCardCommon<FeedGetData>(
                feedData: post,
                     eyes:(data) => data.eyes.toString(),
                userId:   userId == post.user?.id  ?  post.user?.id.toString() :userId,
                getUser: (data) => data,
                 location: (data)=>data.location,
                getId: (data) => data.id ?? 0,
                getText: (data) => data,
                getCreatedAt: (data) => data.createdAt,
                getLiked: (data) => data.liked ?? false,
                getLikedCount: (data) => data.likedCount ?? 0,
                getSaved: (data) => data.saved ?? false,
                getReport: (data) => data.report ?? false,
                getCommentsCount: (data) => data.commentsCount ?? 0,
                getMedia: (data) => data.media ?? [],
                getLikedUsers: (data) => data.likedUsers ?? [],
                onLikeToggle: (context, postId, isLiked) {
                  handleLikeToggle(context, postId, isLiked);
                },
                onDelete: (context, id) {
                  handleDelete(context, id);
                },
                onSaveToggle: (context, id, isSaved) {
                  handleSaveToggle(context, id.toString(), isSaved);
                },
               
              );
            },
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
