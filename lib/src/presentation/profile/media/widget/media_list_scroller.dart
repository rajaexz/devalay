import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/feed_appBar.dart';
import 'package:devalay_app/src/presentation/feed/widget/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import '../../../../core/router/router.dart';

class MediaListScroller extends StatefulWidget {
  const MediaListScroller({super.key, required this.id});
  final String id;

  @override
  State<MediaListScroller> createState() => _MediaListScrollerState();
}

class _MediaListScrollerState extends State<MediaListScroller> {
  String? userid;
 late final FeedHomeCubit feedHomeCubit;
  @override
  void initState() {
    feedHomeCubit= context.read<FeedHomeCubit>();
    super.initState();
    getUserData();
    loadData();
  }

  void loadData() {
    
    context.read<ProfileCubit>().fetchMediaInfoData(widget.id);
     feedHomeCubit.fetchReportReasons();
  }

  Future<void> getUserData() async {
    userid = await PrefManager.getUserDevalayId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: SimpleAppBar(
        centerTitle: false,
        brandName: StringConstant.post,
        onBackTap: () => AppRouter.pop(),
        ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final mediaList = state.singleFeed;
      
            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }
      
            if (mediaList == null) {
              return const Center(child: CustomLottieLoader());
            }
      
            return PostCardCommon<FeedGetData>(
              clickedPostIndex: 0,
              feedData: mediaList,
                      getLikedUsers: (data) => data.likedUsers,
              getReport: (data) => data.report,
                            eyes:(data) => data.eyes.toString(),
                  
              userId: userid,
              getUser: (data) => data,
              getId: (data) => data.id,
              getText: (data) => data,
               location: (data)=>data.location,
              getCreatedAt: (data) => data.createdAt,
              getLiked: (data) => data.liked,
              getLikedCount: (data) => data.likedCount,
              getSaved: (data) => data.saved,
              getCommentsCount: (data) => data.commentsCount,
              getMedia: (data) => data.media,
              onDelete: (ctx, id) async {
                await ctx.read<ProfileCubit>().feedPostDelete(id);
                
              },
              onSaveToggle: (ctx, id, isSaved) async {
                await ctx.read<ProfileCubit>().feedPostSaved(id.toString(), isSaved);
                
              },
            
                    
              onLikeToggle: (ctx, id, isLiked) async {
                await ctx.read<ProfileCubit>().feedPostLike2(id, isLiked,context);
                
              },
            );
          }
      
          return const Center(child: CustomLottieLoader());
        },
      ),
    );
  }
}