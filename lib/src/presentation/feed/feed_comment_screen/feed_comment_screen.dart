import 'package:devalay_app/src/application/feed/feed_%20comment.dart/feed_comment_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_%20comment.dart/feed_comment_state.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/feed/widget/comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

// ignore: must_be_immutable
class FeedCommentScreen extends StatefulWidget {
  final String id;
  bool isAppbar;
  FeedCommentScreen({required this.id, super.key, this.isAppbar = true});

  @override
  State<FeedCommentScreen> createState() => _FeedCommentScreenState();
}

class _FeedCommentScreenState extends State<FeedCommentScreen> {
  final ScrollController _textFieldScrollController = ScrollController();
  late FeedCommentCubit feedCommentCubit;
  late FeedHomeCubit feedHomeCubit;
  String? userid;
  @override
  void initState() {
    super.initState();
    feedCommentCubit = FeedCommentCubit();
    feedHomeCubit = context.read<FeedHomeCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.isAppbar ? feedCommentCubit.focusNode.requestFocus() : null;
      feedCommentCubit.fetchFeedCommentData(id: widget.id);
      getUserData();
    });
  }

  getUserData() async {
    userid = await PrefManager.getUserDevalayId();
  }

  @override
  void dispose() {
    feedCommentCubit.focusNode.dispose();
    _textFieldScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => feedCommentCubit,
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) {
            feedHomeCubit.fetchFeedHomeData(upDateData: true);
          }
        },
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await feedCommentCubit.fetchFeedCommentData(id: widget.id);
            },
            child: SafeArea(
              child: BlocBuilder<FeedCommentCubit, FeedCommentState>(
                builder: (context, state) {
                  // Show loader for initial state
                  if (state is! FeedCommentLoaded) {
                    return const Center(child: CustomLottieLoader());
                  }
                  
                  // state is FeedCommentLoaded here
                  // Show loader while loading and no data exists
                    if (state.loadingState &&
                        (state.feedCommentList == null || state.feedCommentList!.isEmpty)) {
                      return const Center(child: CustomLottieLoader());
                    }
                    
                    // Show error message only if not loading and error exists
                    if (!state.loadingState && state.hasError && state.errorMessage.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.errorMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                feedCommentCubit.fetchFeedCommentData(id: widget.id);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final feedDataList = state.feedCommentList;

                    return Column(
                      children: [
                        Expanded(
                          child: feedDataList == null || feedDataList.isEmpty
                              ? Center(
                                  child: Text(
                                    StringConstant.pleaseEnterAnyComment,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16.0),
                                  itemCount: feedDataList.length,
                                  itemBuilder: (context, index) {
                                    final comment = feedDataList[index];
                                    return CommentWidget(
                                      comment: comment,
                                      postId: widget.id,
                                      currentUserId:
                                          int.parse(userid.toString()),
                                      onReply: feedCommentCubit.startReplying,
                                    );
                                  },
                                ),
                        ),

                        // Bottom input area
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColor.lightTextColor
                                    : AppColor.whiteColor,
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (feedCommentCubit.replyingTo != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColor.blackColor
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            "${StringConstant.replyingTo} ${feedCommentCubit.replyingTo}"),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            feedCommentCubit.replyingTo = null;
                                            feedCommentCubit
                                                .replyingToCommentId = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  // Comment input field
                                  Flexible(
                                    child: SizedBox(
                                      height: 50,
                                      child: Scrollbar(
                                        controller: _textFieldScrollController,
                                        thumbVisibility: true,
                                        child: TextField(
                                          focusNode: feedCommentCubit.focusNode,
                                          controller: feedCommentCubit
                                              .postCommentController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          expands: true,
                                          scrollController:
                                              _textFieldScrollController,
                                          scrollPhysics:
                                              const BouncingScrollPhysics(),
                                          decoration: InputDecoration(
                                            hintText:
                                                StringConstant.typeSomeThing,
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Gap(8.w),

                                  // Post Button
                                  CustomRoundedButton(
                                    backgroundColor: AppColor.appbarBgColor,
                                    onTap: () {
                                      feedCommentCubit.postComment(
                                          id: widget.id);
                                    },
                                    isLoading: feedCommentCubit.isPostLoad,
                                    text: '',
                                    icon: Icons.arrow_upward,
                                    borderRadius: 5.r,
                                    elevation: 0.2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
