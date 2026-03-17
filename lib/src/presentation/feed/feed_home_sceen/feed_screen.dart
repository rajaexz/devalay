import 'dart:async';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/feed/widget/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final FeedHomeCubit feedHomeCubit;
  final ScrollController _scrollController = ScrollController();

  String? userid;
  bool isFetchingMore = false;
  bool _isBackToTopVisible = false;
  Timer? _loadingTimeoutTimer;
  final bool _hasTimedOut = false;
  final Map<int, Timer?> _viewTimers = {};

  @override
  void initState() {
    super.initState();
    feedHomeCubit = context.read<FeedHomeCubit>();

    feedHomeCubit.fetchFeedHomeData();
    feedHomeCubit.fetchReportReasons();
    _loadUserId();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isFetchingMore) {
      isFetchingMore = true;
      await feedHomeCubit.fetchFeedHomeData(loadMoreData: true);
      isFetchingMore = false;
    }

    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _isBackToTopVisible) {
      setState(() {
        _isBackToTopVisible = shouldShow;
      });
    }
  }

  void _loadUserId() async {
    userid = await PrefManager.getUserDevalayId();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _loadingTimeoutTimer?.cancel();

    // Cancel all view timers
    for (var timer in _viewTimers.values) {
      timer?.cancel();
    }
    _viewTimers.clear();

    super.dispose();
  }

  // First, add this method to your class for showing the auth error popup
  void _showAuthErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Material(
          color: Colors.black.withOpacity(0.5), // Shadow overlay
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    StringConstant.authenticationRequired,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                   StringConstant.sessionExpired,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Handle close action if needed
                          },
                          child: Text(StringConstant.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to login screen or handle retry logic
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login', // Replace with your login route
                              (route) => false,
                            );
                          },
                          child: Text(StringConstant.login),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Helper method to check if error is authentication related
  bool _isAuthenticationError(String errorMessage) {
    return errorMessage
            .toLowerCase()
            .contains('authentication credentials were not provided') ||
        errorMessage.toLowerCase().contains('authentication') ||
        errorMessage.toLowerCase().contains('credentials') ||
        errorMessage.toLowerCase().contains('unauthorized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColor.appbarBgColor,
            onRefresh: () async {
              try {
                // _startLoadingTimeout();
                await feedHomeCubit.resetAndRefreshFeedData();
              } catch (e) {
                debugPrint('Refresh error: $e');
                if (mounted) {
                  // Check if it's an authentication error
                  if (_isAuthenticationError(e.toString())) {
                    // ignore: use_build_context_synchronously
                    _showAuthErrorPopup(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          StringConstant.failedToRefreshData,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColor.whiteColor,
                                  ),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: BlocListener<FeedHomeCubit, FeedHomeState>(
              listener: (context, state) {
                // Listen for authentication errors
                if (state is FeedHomeLoaded && state.errorMessage.isNotEmpty) {
                  if (_isAuthenticationError(state.errorMessage)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showAuthErrorPopup(context);
                    });
                  }
                }

                if (state is FeedHomeLoaded && state.isAuthError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showAuthErrorPopup(context);
                  });
                }
              },
              child: BlocBuilder<FeedHomeCubit, FeedHomeState>(
                builder: (context, state) {
                  if (state is FeedHomeLoaded) {
                    _loadingTimeoutTimer?.cancel();
                    final feedHomeCubit = context.watch<FeedHomeCubit>();
                    final feedDataList = state.feedList
                            ?.map((post) {
                              post.media = post.media
                                  ?.where((m) => !feedHomeCubit.blockedMediaIds
                                      .contains(m.id))
                                  .toList();
                              return post;
                            })
                            .where((post) =>
                                !feedHomeCubit.blockedPostIds
                                    .contains(post.id) &&
                                (post.media?.isNotEmpty ?? true))
                            .toList() ??
                        [];

                    if (state.errorMessage.isNotEmpty) {
                      // Don't show buildNoDataFound for auth errors since popup will handle it
                      if (_isAuthenticationError(state.errorMessage)) {
                        return const Center(child: CustomLottieLoader());
                      }
                      return buildNoDataFound(errorMessage: state.errorMessage);
                    }

                    if (feedDataList.isEmpty) {
                      if (_hasTimedOut) {
                        return buildNoDataFound(
                            errorMessage: StringConstant.requestTimedOut);
                      }
                      return const LoadingPostList(itemCount: 5);
                    }

                    return _buildFeedList(feedDataList, state.loadingState);

                         }

                  // Handle error state specifically for authentication
                  if (state is FeedHomeLoaded && state.isAuthError) {
                    const Center(child: CustomLottieLoader());
                  }

                  return const Center(child: CustomLottieLoader());
                },
              ),
            ),
          ),
          if (_isBackToTopVisible)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 20),
                child: GestureDetector(
                  onTap: _scrollToTop,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColor.orangeColor
                          : AppColor.appbarBgColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black38
                              : Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColor.whiteColor
                          : AppColor.lightGrayColor,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedList(List<FeedGetData> feedDataList, bool loadingMore) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < feedDataList.length) {
                final feedData = feedDataList[index];
                return _buildPostCard(feedData, index);
              } else if (loadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CustomLottieLoader()),
                );
              }
              return null;
            },
            childCount: feedDataList.length + (loadingMore ? 1 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(FeedGetData feedData, int index) {
    return VisibilityDetector(
      key: Key('post_${feedData.id}'),
      onVisibilityChanged: (visibilityInfo) {
   
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: PostCardCommon<FeedGetData>(
          clickedPostIndex: index,
          eyes: (data) => data.eyes.toString(),
          feedData: feedData,
          getReport: (data) => data.report,
          userId: userid,
          location: (data) => data.location,
          getUser: (data) => data,
          getId: (data) => data.id,
          getText: (data) => data,
          getCreatedAt: (data) => data.createdAt,
          getLiked: (data) => data.liked,
          getLikedCount: (data) => data.likedCount,
          getSaved: (data) => data.saved,
          getCommentsCount: (data) => data.commentsCount,
          getMedia: (data) => data.media,
          getLikedUsers: (data) => data.likedUsers,
          onDelete: (ctx, id) => ctx.read<FeedHomeCubit>().feedPostDelete(id),
          onSaveToggle: (ctx, id, isSaved) =>
              ctx.read<FeedHomeCubit>().feedPostSaved(id.toString(), isSaved),
          onLikeToggle: (ctx, id, isLiked) =>
              ctx.read<FeedHomeCubit>().feedPostLike(id, isLiked),
        ),
      ),
    );
  }

  Widget buildNoDataFound({String? errorMessage}) {
    final displayMessage = errorMessage != null && errorMessage.isNotEmpty
        ? '${StringConstant.somethingWentWrong}: $errorMessage'
        : StringConstant.noDataAvailable;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        NoMediaView(
          onRefresh: () async {
            try {
              await feedHomeCubit.fetchFeedHomeData();
            } catch (e) {
              debugPrint('NoData refresh error: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to refresh data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColor.whiteColor,
                          ),
                    ),
                  ),
                );
              }
            }
          },
          title: displayMessage,
          subtitle: "${StringConstant.youhavenotSharedAnythingYet}\n${StringConstant.pullDownToRefresh}",
          icon: Icons.refresh,
        )
      ],
    );
  }
}
