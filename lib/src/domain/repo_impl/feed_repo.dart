import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:image_picker/image_picker.dart';

abstract class FeedHomeRepo {
  Future<Either<Failure, CustomResponse>> fetchFeedHomeDataData(int page,
      {String type});
  Future<Either<Failure, CustomResponse>> incrementPostView(int postId);
  Future<Either<Failure, CustomResponse>> fetchFeedSinglePostData(String id);

  Future<Either<Failure, CustomResponse>> getLocationFromGoogleApi(
      String input);
  Future<Either<Failure, CustomResponse>> getLocationFromApi(
      String input);
  Future<Either<Failure, CustomResponse>> fetchFeedCreateData(
      title,
      List<XFile> media,
      List<Map<String, dynamic>> people,
      String location,
      List<Map<String, dynamic>> temples);
  Future<Either<Failure, CustomResponse>> feedPostLikeData(
      String id, String isLike);
  Future<Either<Failure, CustomResponse>> feedPostFollowingRequest(
      int postId, int userId, bool isFollowing);
  Future<Either<Failure, CustomResponse>> feedPostHideSuggestion(
      int myId, int userId);
  Future<Either<Failure, CustomResponse>> fetchReportReasons();
  Future<Either<Failure, CustomResponse>> fetchReportPost(
      String postId, int reasonId);
  Future<Either<Failure, CustomResponse>> feedPostFollowing(
      int postId, int userId, bool isFollowing);
  Future<Either<Failure, CustomResponse>> feedCommentLike(
      int postId, bool isFollowing);

  Future<Either<Failure, CustomResponse>> feedPostSavedData(
      String id, String userId);
  Future<Either<Failure, CustomResponse>> feedPostDeteleData(String id);
  Future<Either<Failure, CustomResponse>> feedUpdatePost(
      int id, List<XFile>? file, title);

  Future<Either<Failure, CustomResponse>> getNotificationType(
      {required int page, required int limit, required String type});

  Future<Either<Failure, CustomResponse>> notificationReadAndUnReadPost();
  Future<Either<Failure, CustomResponse>> markSingleNotificationAsRead(int notificationId);
  Future<Either<Failure, CustomResponse>> feedDeletedPostImage(
      int id, List deletedImageId);
  Future<Either<Failure, CustomResponse>> fetchFeedCommentData(String id);
  Future<Either<Failure, CustomResponse>> fetchFeedCommentReplyData(String id);
  Future<Either<Failure, CustomResponse>> replyToRepliesCommentData(String id);
  Future<Either<Failure, CustomResponse>> fetchFeedCommentReplydeleteReply(
      String id);
  Future<Either<Failure, CustomResponse>>
      fetchFeedCommentReplydeleteReplyToReplies(String id);
  Future<Either<Failure, CustomResponse>> fetchFeedCommentDeleteReply(
      String id);
  Future<Either<Failure, CustomResponse>> fetchFeedCommentPost(
      {required String id, required List<XFile> file, required String title});
  Future<Either<Failure, CustomResponse>> fetchFeedCommentReplyPost(
      {required String id, required String title, required String postId});
  Future<Either<Failure, CustomResponse>> fetchFeedReplyToRepliesPost(
      {required String id, required String title, required String postId});
  Future<Either<Failure, CustomResponse>> blockPost(
      int postId, userid, String myId);
        Future<Either<Failure, CustomResponse>> blockUser(
      int postId, userid, String myId);
  Future<Either<Failure, CustomResponse>> blockMedia(int mediaId);
  Future<Either<Failure, CustomResponse>> unblockPost(int postId);
  Future<Either<Failure, CustomResponse>> unblockMedia(int mediaId);
}
