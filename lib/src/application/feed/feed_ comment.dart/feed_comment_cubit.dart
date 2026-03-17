import 'package:dartz/dartz.dart';
import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/feed/feed_%20comment.dart/feed_comment_state.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/feed/feed_comment_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_comment_reply_model.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class FeedCommentCubit extends Cubit<FeedCommentState> {
  FeedCommentCubit()
      : feedCommentRepo = getIt<FeedHomeRepo>(),
        super(FeedCommentInitial());

  TextEditingController postCommentController = TextEditingController();

  bool viewReply = false;

  final FeedHomeRepo feedCommentRepo;
  bool isPostLoad = false;

  int charCount = 0;
  List<XFile> selectedMedia = [];
  final FocusNode focusNode = FocusNode();

  List<FeedComment> comments = [];
  List<FeedCommentReply> commentsReplies = [];

  List<FeedCommentReply> replyToReplies = [];
  int? replyingToRepliesId;
  String? replyingToReplies;
  Map<int, bool> replyingViewReplies = {};

  void toggleViewReplyToReplies({int? commentId, bool? isTrue}) async {
    replyingViewReplies[commentId!] =
        !(replyingViewReplies[commentId] ?? false);

    if (replyingViewReplies[commentId] == true) {
      await feedReplyToRepliesCommentData(id: commentId.toString());
    }

    setScreenState(
        isLoading: false,
        replyData: commentsReplies,
        replyToReplies: replyToReplies,
        data: comments);
  }

  String? replyingTo;
  int? replyingToCommentId;
  int? replyingType2 = 0;
  int? commentId;
  Map<int, bool> viewReplies = {};

  void toggleViewReply(int commentId) async {
    viewReplies[commentId] = !(viewReplies[commentId] ?? false);
    if (viewReplies[commentId] == true) {
      await fetchFeedCommentReplyData(id: commentId.toString());
    }
    setScreenState(
        isLoading: false, replyData: commentsReplies, data: comments);
  }

 Future<void> feedCommentLike({
  required int followingUserId,
  required bool isFollowing,
}) async {
  final result = await feedCommentRepo.feedCommentLike(followingUserId, isFollowing);

  result.fold(
    (failure) {
      Logger.log("Follow failed: ${failure.toString()}");
      setScreenState(
        isLoading: false,
        message: failure.toString(),
        hasError: true,
      );
    },
    (customResponse) async {
      final updatedPost = FeedComment.fromJson(customResponse.response!.data);

      final updatedList = comments.map((post) {
        if (post.id == updatedPost.id) {
          return updatedPost;
        }
        return post;
      }).toList();

      comments = updatedList; 
      setScreenState(
        isLoading: false,
        data: updatedList,
        replyData: commentsReplies,
        replyToReplies: replyToReplies,
      );
    },
  );
}

  Future<void> deleteComment(int replyId, String postId) async {
    setScreenState(
        isLoading: false, replyData: commentsReplies, data: comments);

    Either<Failure, CustomResponse> result;

    result =
        await feedCommentRepo.fetchFeedCommentDeleteReply(replyId.toString());

    result.fold(
      (failure) {
        setScreenState(
            isLoading: false, replyData: commentsReplies, data: comments);
      },
      (success) async {
        focusNode.unfocus();
        fetchFeedCommentData(id: postId);
      },
    );
  }

  Future<void> deleteReplyToReplies(int replyId, int commentId) async {
    Either<Failure, CustomResponse> result;
    result = await feedCommentRepo
        .fetchFeedCommentReplydeleteReplyToReplies(replyId.toString());
    result.fold(
      (failure) {
        setScreenState(
            isLoading: false, replyData: commentsReplies, data: comments);
      },
      (success) async {
        focusNode.unfocus();
        replyToReplies.removeWhere((reply) => reply.id == replyId);
        setScreenState(
            isLoading: false, replyToReplies: commentsReplies, data: comments);
      },
    );
  }

  Future<void> deleteReply(int replyId, int commentId) async {
    Either<Failure, CustomResponse> result;
    result = await feedCommentRepo
        .fetchFeedCommentReplydeleteReply(replyId.toString());
    result.fold(
      (failure) {
        setScreenState(
            isLoading: false, replyData: commentsReplies, data: comments);
      },
      (success) async {
        focusNode.unfocus();
        commentsReplies.removeWhere((reply) => reply.id == replyId);
        setScreenState(
            isLoading: false, replyData: commentsReplies, data: comments);
      },
    );
  }

  startReplying(
    commentId,
    user,
    replyingType,
  ) {

    replyingTo = user;
    replyingToCommentId = commentId;
    replyingType2 = replyingType;

    setScreenState(
        isLoading: false, replyData: commentsReplies, data: comments);

    focusNode.requestFocus();
  }

  Future<void> postComment({String? id, List<XFile>? file}) async {
    if (postCommentController.text.trim().isEmpty) return;

    isPostLoad = true;

    Either<Failure, CustomResponse> result;

    if (replyingToCommentId == null) {
      result = await feedCommentRepo.fetchFeedCommentPost(
        id: id ?? "",
        file: file ?? [],
        
        title: postCommentController.text,
      );
      result.fold(
        (failure) {
          Logger.log("Error: ${failure.toString()}");
        },
        (customResponse) async {
          Logger.log("Success: ${customResponse.toString()}");
          postCommentController.clear();
          selectedMedia.clear();
          focusNode.unfocus();

          await fetchFeedCommentData(id: id.toString());
          isPostLoad = false;
          replyingTo = null;
          replyingToCommentId = null;
        },
      );

      return;
    } else if (replyingType2 == 1) {
      result = await feedCommentRepo.fetchFeedCommentReplyPost(
        id: replyingToCommentId.toString(),
        postId: id.toString(),
        title: postCommentController.text,
      );
      result.fold(
        (failure) {
          Logger.log("Error: ${failure.toString()}");
        },
        (customResponse) async {
          Logger.log("Success: ${customResponse.toString()}");
          postCommentController.clear();
          selectedMedia.clear();
          focusNode.unfocus();

          await fetchFeedCommentData(id: id.toString());
          await fetchFeedCommentReplyData(id: replyingToCommentId.toString());

          isPostLoad = false;
          replyingTo = null;
          replyingToCommentId = null;
          replyingType2 = null;
        },
      );
      return;
    } else if (replyingType2 == 2) {
      result = await feedCommentRepo.fetchFeedReplyToRepliesPost(
        id: replyingToCommentId.toString(),
        postId: id.toString(),
        title: postCommentController.text,
        
      );
      result.fold(
        (failure) {
          Logger.log("Error: ${failure.toString()}");
        },
        (customResponse) async {
          Logger.log("Success: ${customResponse.toString()}");
          postCommentController.clear();
          selectedMedia.clear();
          focusNode.unfocus();
          await fetchFeedCommentData(id: id.toString(), updated: true);

          await feedReplyToRepliesCommentData(
              id: replyingToCommentId.toString());

          toggleViewReplyToReplies(
              commentId: replyingToCommentId!, isTrue: true);

          isPostLoad = false;
          replyingTo = null;
          replyingToCommentId = null;
          replyingType2 = null;

          return;
        },
      );
    }
  }

  Future<void> fetchFeedCommentData(
      {required String id, bool updated = false}) async {
    setScreenState(isLoading: true, data: comments);
    
    final result = await feedCommentRepo.fetchFeedCommentData(id);

    result.fold((failure) {
      Logger.log("Error fetching comments: ${failure.toString()}");
      setScreenState(
        isLoading: false, 
        data: comments,
        hasError: true,
        message: failure.toString(),
      );
      if (failure.toString() == "Not Found") {
        Logger.log("Not Found fetching comments: ${comments.length}");
      }
    }, (customResponse) {
      try {
        final responseData = customResponse.response?.data;
        
        // Check if response data is a list
        if (responseData is List) {
          final data = FeedComment.fromList(responseData);
          comments = [];
          comments.addAll(data);
          Logger.log("Data fetching comments: ${comments.length}");
          setScreenState(isLoading: false, data: comments, hasError: false);
        } else if (responseData is Map) {
          // If response is a map, check if it has a 'comments' or 'results' key
          if (responseData.containsKey('comments') && responseData['comments'] is List) {
            final data = FeedComment.fromList(responseData['comments'] as List);
            comments = [];
            comments.addAll(data);
            Logger.log("Data fetching comments from map: ${comments.length}");
            setScreenState(isLoading: false, data: comments, hasError: false);
          } else {
            Logger.log("Unexpected response format: $responseData");
            setScreenState(
              isLoading: false,
              data: comments,
              hasError: true,
              message: 'Invalid response format',
            );
          }
        } else {
          Logger.log("Unexpected response type: ${responseData.runtimeType}");
          setScreenState(
            isLoading: false,
            data: comments,
            hasError: true,
            message: 'Invalid response format',
          );
        }
      } catch (e) {
        Logger.log("Error parsing comments: ${e.toString()}");
        setScreenState(
          isLoading: false,
          data: comments,
          hasError: true,
          message: 'Error parsing comment data: ${e.toString()}',
        );
      }
    });

    if (updated) {
      setScreenState(
          isLoading: false,
          data: comments,
          replyData: commentsReplies,
          replyToReplies: replyToReplies);
    }
  }

  Future<void> fetchFeedCommentReplyData({id ,postId}) async {
    final result = await feedCommentRepo.fetchFeedCommentReplyData(id,);

    result.fold((failure) {
      setScreenState(
          isLoading: false, replyData: commentsReplies, hasError: true);
    }, (customResponse) {
      final data = FeedCommentReply.fromList(customResponse.response!.data);
      commentsReplies = [];
      commentsReplies = data;

      setScreenState(
          isLoading: false, replyData: commentsReplies, data: comments);
    });
  }

  Future<void> feedReplyToRepliesCommentData({id}) async {
    final result = await feedCommentRepo.replyToRepliesCommentData(id);

    result.fold((failure) {
      setScreenState(
          isLoading: false, replyToReplies: replyToReplies, hasError: true);
    }, (customResponse) {
      final data = FeedCommentReply.fromList(customResponse.response!.data);
      replyToReplies = [];
      replyToReplies = data;
      setScreenState(
          isLoading: false,
          replyData: commentsReplies,
          data: comments,
          replyToReplies: replyToReplies);
    });
  }

  void setScreenState({
    List<FeedComment>? data,
    required bool isLoading,
    List<FeedCommentReply>? replyData,
    List<FeedCommentReply>? replyToReplies,
    String? message,
    bool hasError = false,
  }) {
    emit(FeedCommentLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      hasError: hasError,
      feedCommentList: data,
      feedReplyttoRepliesList: replyToReplies,
      feedCommentReplyList: replyData,
    ));
  }
}
