import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart';
import 'dart:convert';

import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FeedHomeRepo)
class FeedHomeRepositories extends FeedHomeRepo {
  @override
  Future<Either<Failure, CustomResponse>> fetchFeedHomeDataData(int page,
      {String? type}) async {
    String url = "${AppConstant.feedHomeGet}/?limit=7&page=$page";

    try {
      final CustomResponse customResponse =
          await ApiCalling().callApi(apiTypes: ApiTypes.get, url: url);

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

@override
  Future<Either<Failure, CustomResponse>> incrementPostView(int postId) async {
    try {
      final response = await ApiCalling().callApi(
       apiTypes: ApiTypes.get, url:  '/posts/increment-view/$postId/', // Adjust endpoint as needed
        data: {}, // Empty data for POST request
      );
      
      return right(response);
    } catch (e) {
   Logger.logError(e);
      return left(Failure.getDioException(e));
       }
  }


  @override
  Future<Either<Failure, CustomResponse>> fetchReportReasons() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: AppConstant.feedReportGet);

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> blockPost(
      int postId, userid, String myId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Post/$postId/", // Update with your actual endpoint
        data: { "block": true},
        referer: "https://devalay.org/apis/Post/$postId",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> blockUser(
      int postId, userid, String myId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/User/$myId/", // Update with your actual endpoint
        data: {"action": "add", "block": userid},
        referer: "https://devalay.org/apis/User/$myId",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> blockMedia(int mediaId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url:
            "${AppConstant.baseUrl}/block-media/", // Update with your actual endpoint
        data: {"media_id": mediaId, "action": "block"},
        referer: "${AppConstant.baseUrl}/block-media/",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> unblockPost(int postId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url:
            "${AppConstant.baseUrl}/block-post/", // Update with your actual endpoint
        data: {"post_id": postId, "action": "unblock"},
        referer: "${AppConstant.baseUrl}/block-post/",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> unblockMedia(int mediaId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url:
            "${AppConstant.baseUrl}/block-media/", // Update with your actual endpoint
        data: {"media_id": mediaId, "action": "unblock"},
        referer: "${AppConstant.baseUrl}/block-media/",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchReportPost(
      String postId, int reasonId) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('post', postId));
      formData.fields.add(MapEntry('message', reasonId.toString()));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: AppConstant.feedReportGet,
          referer: "https://devalay.org/apis/report/",
          data: formData);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedSinglePostData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: "${AppConstant.feedHomeGet}/$id/");

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedPostLikeData(
      String id, String isLike) async {
    final bool likedStatus = isLike.toLowerCase() == 'true';

    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedCreatePost}$id/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedCreatePost}$id/",
          data: {'liked': likedStatus});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

// Delete Post
  @override
  Future<Either<Failure, CustomResponse>> feedPostDeteleData(String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.delete,
        url: "${AppConstant.feedCreatePost}$id/",
        referer: "${AppConstant.baseUrl}${AppConstant.feedCreatePost}$id/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
@override
Future<Either<Failure, CustomResponse>> fetchFeedCreateData(
    title,
    List<XFile> mediaFiles,
    List<Map<String, dynamic>> people,
    String location,
    List<Map<String, dynamic>> temples) async {
  try {
    FormData formData = FormData();

    String creatingTowArrayMarge(
        List<Map<String, dynamic>> people, List<Map<String, dynamic>> temples) {
      try {
        List<Map<String, dynamic>> mergedList = [];

        // Add User objects if people list is not empty
        if (people.isNotEmpty) {
          for (Map<String, dynamic> person in people) {
            final id = person['id'];
            if (id == null) continue;
            mergedList.add({
              "content_type": "User",
              "object_id": id.toString(),
              "name": person['name'] ?? person['title'] ?? ''
            });
          }
        }

        // Add Temple objects if temples list is not empty
        if (temples.isNotEmpty) {
          for (Map<String, dynamic> temple in temples) {
            final id = temple['id'];
            if (id == null) continue;
            mergedList.add({
              "content_type": "Devalay",
              "object_id": id.toString(),
              "name": temple['title'] ?? temple['name'] ?? ''
            });
          }
        }

        return jsonEncode(mergedList);
      } catch (e) {
        return "[]"; // Return empty array as fallback
      }
    }

    String mergedData = creatingTowArrayMarge(people, temples);
    if (mergedData != "[]") {
      formData.fields.add(MapEntry('tags', mergedData));
    }

    // API allows location max 100 characters
    final String locationTrimmed = location.length > 100
        ? location.substring(0, 100)
        : location;
    if (locationTrimmed.isNotEmpty) {
      formData.fields.add(MapEntry('location', locationTrimmed));
    }

    formData.fields.add(MapEntry(
      'text',
      title,
    ));

    // Log media files being uploaded
    print('=== MEDIA FILES UPLOAD LOG ===');
    print('Total files: ${mediaFiles.length}');
    
    for (int i = 0; i < mediaFiles.length; i++) {
      XFile mediaFile = mediaFiles[i];
      String fileName = mediaFile.path.split('/').last;
      String? mimeType = lookupMimeType(mediaFile.path) ?? 'application/octet-stream';
      
      // Detailed logging for each file
      print('\n--- File ${i + 1} ---');
      print('File name: $fileName');
      print('File path: ${mediaFile.path}');
      print('MIME type: $mimeType');
      
      // Determine and log media type
      if (mimeType.startsWith('video/')) {
        print('Media type: VIDEO');
        print('Video format: ${mimeType.split('/').last}');
      } else if (mimeType.startsWith('image/')) {
        print('Media type: IMAGE');
        print('Image format: ${mimeType.split('/').last}');
      } else {
        print('Media type: OTHER');
      }
      
      // Get file size if available
      final fileSize = await mediaFile.length();
      print('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            mediaFile.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        ),
      );
    }
    
    print('=== END MEDIA FILES LOG ===\n');

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.post,
      url: AppConstant.feedCreatePost,
      data: formData,
      referer: "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}",
      optionalHeader: {},
    );

    return right(customResponse);
  } on DioException catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}
  @override
  Future<Either<Failure, CustomResponse>> feedUpdatePost(
      int id, List<XFile>? file, title) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('text', title));
      for (XFile mediaFile in file!) {
        String fileName = mediaFile.path.split('/').last;
        String? mimeType =
            lookupMimeType(mediaFile.path) ?? 'application/octet-stream';

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              mediaFile.path,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.feedCreatePost}$id/", // Ensure correct API URL
        data: formData,
        referer: "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}",
        optionalHeader: {
          // Dio sets this automatically, so it's not needed:
          // 'Content-Type': 'multipart/form-data',
        },
      );

      return right(customResponse);
    } on DioException catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  // Notification Type People , Temple ,Event
  @override
  Future<Either<Failure, CustomResponse>> getNotificationType(
      {required int page, required int limit, required String? type}) async {
    try {
           type == "all" ? " ": type;

           Logger.log("-------------------$type");
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        referer:'https://devalay.org/',
        
        url:
            "${AppConstant.notificationPost}?limit=$limit&page=$page${ type != "all" ? "&type=$type" : ''}",
      );

      return right(customResponse);
    } on DioException catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> notificationReadAndUnReadPost() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        // New API: /Notification/?mark_read=true
        url: "${AppConstant.notificationPost}?mark_read=true",
        referer: "${AppConstant.baseUrl}${AppConstant.notificationPost}?mark_read=true",
      );

      print("📬 Mark all as read API response: ${customResponse.response?.statusCode}");
      return right(customResponse);
    } on DioException catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> markSingleNotificationAsRead(int notificationId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        // New API: /Notification/?mark_read=true&id=<notificationId>
        url: "${AppConstant.notificationPost}?mark_read=true&id=$notificationId",
        referer: "${AppConstant.baseUrl}${AppConstant.notificationPost}?mark_read=true&id=$notificationId",
      );

      print("📬 Mark notification $notificationId as read: ${customResponse.response?.statusCode}");
      return right(customResponse);
    } on DioException catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedPostFollowing(
      int postId, int userId, bool isFollowing) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedFollowingPost}$userId/",
          referer:
              "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}$userId/",
          data: {
            "following": postId,
            "action": isFollowing ? "add" : "remove"
          });

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedPostHideSuggestion(
      int myId, int userId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedFollowingPost}$userId/",
          referer:
              "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}$userId/",
          data: {"block_list": myId, "action": "block"});

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedPostFollowingRequest(
      int postId, int userId, bool isFollowing) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedFollowingPost}$userId/",
          referer:
              "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}$userId/",
          data: {
            "following_requests": postId,
            "action": isFollowing ? "add" : "remove"
          });

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> getLocationFromGoogleApi(
      String input) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: "${AppConstant.googleSerch}?input=$input",
        referer: "${AppConstant.googleSerch}?$input",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> getLocationFromApi(
      String input) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: "/places-v2/?input=$input",
        referer: "${AppConstant.googleSerch}?$input",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedCommentLike(
      int id, bool isFollowing) async {
    var myId = id.toString();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedCommentDetele}$myId/",
          referer:
              "${AppConstant.baseUrl}${AppConstant.feedCommentDetele}$myId/",
          data: {'liked': isFollowing});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedDeletedPostImage(
      int id, List deletedImageId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.feedCreatePost}$id/", // Ensure correct API URL
        data: {"remove_media_ids": deletedImageId},
        referer: "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}",
      );

      return right(customResponse);
    } on DioException catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> feedPostSavedData(
      String id, String isSave) async {
    final bool saveStatus = isSave.toLowerCase() == 'true';
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedCreatePost}$id/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedCreatePost}$id/",
          data: {'saved': saveStatus});

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  Future<Either<Failure, CustomResponse>> feedPostReportData(
      String id, String isSave) async {
    final bool saveStatus = isSave.toLowerCase() == 'true';
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedCreatePost}$id/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedCreatePost}$id/",
          data: {'report': saveStatus});

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

/////// ---------------------- Comment  Section Api Reposities -----------------------
  @override
  Future<Either<Failure, CustomResponse>> fetchFeedCommentData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: "${AppConstant.feedCommentGet}$id");

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedCommentReplyData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: "${AppConstant.feedCommentReplyPost}$id/");

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> replyToRepliesCommentData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: "${AppConstant.feedCommentReplyPost}$id/");

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedCommentReplydeleteReply(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.delete,
        url: "${AppConstant.feedCommentReplyPost}$id/",
        referer:
            "${AppConstant.baseUrl}${AppConstant.feedCommentReplyPost}$id/}",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>>
      fetchFeedCommentReplydeleteReplyToReplies(String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.delete,
        url: "${AppConstant.feedCommentReplyPost}$id/",
        referer: "${AppConstant.baseUrl}${AppConstant.feedCommentReplyPost}",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedCommentDeleteReply(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.delete,
        url: "${AppConstant.feedCommentDetele}$id/",
        referer: "${AppConstant.baseUrl}${AppConstant.feedCommentDetele}$id/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedCommentPost(
      {required String id,
      required List<XFile> file,
      required String title}) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('comment', title));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "${AppConstant.feedCommentGet}$id",
          referer: "${AppConstant.baseUrl}${AppConstant.feedCommentGet}$id",
          data: formData);

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedCommentReplyPost(
      {required String id,
      required String title,
      required String postId}) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('comment', title));
      print("============$postId");
      formData.fields.add(MapEntry('post', postId));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          referer: "${AppConstant.baseUrl}${AppConstant.feedCommentDetele}",
          url: "${AppConstant.feedCommentReplyPost}$id/reply/",
          data: formData);

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFeedReplyToRepliesPost(
      {required String id,
      required String title,
      required String postId}) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('comment', title));

      formData.fields.add(MapEntry('post', postId));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          referer: "${AppConstant.baseUrl}${AppConstant.feedCommentDetele}",
          url: "${AppConstant.feedCommentReplyPost}$id/reply/",
          data: formData);

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
}
