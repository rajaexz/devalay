import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/explore/devotee/explore_devotee_widget.dart';
import 'package:devalay_app/src/presentation/feed/widget/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedDetailScreen extends StatefulWidget {
  const FeedDetailScreen({super.key, required this.id});
  final String id;

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  late FeedHomeCubit feedHomeCubit;
  String? userid;

  @override
  void initState() {
    super.initState();
    feedHomeCubit = context.read<FeedHomeCubit>();
    _loadData();
  }

  Future<void> _loadData() async {
    userid = await PrefManager.getUserDevalayId();
    await feedHomeCubit.fetchFeedSinglePostData(id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<FeedHomeCubit, FeedHomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey[50],
          appBar: _buildAppBar(isDark),
          body: SingleChildScrollView(child: _buildBody(state)),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? Colors.black : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 18.sp,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              feedHomeCubit.fetchFeedHomeData(upDateData: true);
            } else {
              AppRouter.go('/landing');
            }
          },
        ),
      ),
      title: Text(
        "${StringConstant.post} ${StringConstant.details} ",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(FeedHomeState state) {
    return RefreshIndicator(
      color: AppColor.appbarBgColor,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.white,
      onRefresh: () => feedHomeCubit.fetchFeedSinglePostData(id: widget.id),
      child: BlocBuilder<FeedHomeCubit, FeedHomeState>(
        builder: (context, state) {
          if (state is FeedHomeLoaded) {
            final feedDataSingle = state.singleFeed;

            if (state.errorMessage.isNotEmpty) {
              return _buildNoDataFound(state.errorMessage);
            }

            if (feedDataSingle == null) {
              return _buildLoadingView();
            }

            return _buildPostView(feedDataSingle);
          }
          return _buildLoadingView();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CustomLottieLoader(),
    );
  }

  Widget _buildPostView(FeedGetData feedData) {
    if (userid == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Post Card
          Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: PostCardCommon<FeedGetData>(
                     eyes:(data) => data.eyes.toString(),
                          getLikedUsers: (data) => data.likedUsers,
                clickedPostIndex: 0,
                feedData: feedData,
                getReport: (data) => data.report,
                userId: userid!,
                 location: (data)=>data.location,
                getUser: (data) => data,
                getId: (data) => data.id,
                getText: (data) => data,
                getCreatedAt: (data) => data.createdAt,
                getLiked: (data) => data.liked,
                getLikedCount: (data) => data.likedUsers?.length ?? 0,
                getSaved: (data) => data.saved,
                getCommentsCount: (data) => data.commentsCount ?? 0,
                getMedia: (data) => data.media,
                onDelete: (ctx, id) => ctx.read<FeedHomeCubit>().feedPostDelete(id),
                onSaveToggle: (ctx, id, isSaved) =>
                    ctx.read<FeedHomeCubit>().feedPostSaved(id.toString(), isSaved),
                             onLikeToggle: (ctx, id, isLiked) {
                  ctx.read<FeedHomeCubit>().feedPostLikeDeatail(id.toString(), isLiked);
                },
              ),
            ),
          ),

          // Action Buttons
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
               
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.view_agenda,
                    label: StringConstant.liked,
                    count: feedData.likedUsers?.length ?? 0,
                    color: Colors.red,
                    onTap: () => _showLikesModal(context, feedData),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsModal(FeedGetData feedData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Text(
                  "Comments (${feedData.commentsCount ?? 0})",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 5, // Replace with actual comments
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "Sample comment $index",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
void _showLikesModal(BuildContext context, FeedGetData feedData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
       
                      
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Liked by ${feedData.likedUsers?.length ?? 0} users",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: feedData.likedUsers?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: buildDevoteeCard(feedData.likedUsers![index], context),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
 Widget _buildNoDataFound(String errorMessage) {
    final displayMessage = errorMessage.isNotEmpty
        ? 'Something went wrong: $errorMessage'
        : StringConstant.noDataAvailable;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: NoMediaView(
            onRefresh: () async {
              try {
                await feedHomeCubit.fetchFeedSinglePostData(id: widget.id);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to refresh data'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                    ),
                  );
                }
              }
            },
            title: displayMessage,
            subtitle: 'You haven\'t shared anything yet.\nPull down to refresh.',
            icon: Icons.refresh,
          ),
        )
      ],
    );
  }
}