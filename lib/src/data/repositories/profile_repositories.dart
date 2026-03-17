import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/setting/notification_settings_model.dart';
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/api/app_constant.dart';

int flag = 0;

@LazySingleton(as: ProfileRepo)
class ProfileRepositories extends ProfileRepo {
 
 
@override
Future<Either<Failure, CustomResponse>> fetchNotificationSettings() async {
  try {
    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.get,
      url: "/notification-settings/",
    );
    print('API Response Data: ${customResponse.response?.data}');
    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}
  @override
  Future<Either<Failure, CustomResponse>> updateNotificationSettings(
      NotificationSettingsModel settings) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        referer: "${AppConstant.baseUrl}/notification-settings/",
        url: "/notification-settings/",
        data: settings.toJson(),
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
 
 
 
  @override
  Future<Either<Failure, CustomResponse>> fetchProfileInfoData(
      String devalayId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: "${AppConstant.feedUser}/$devalayId/");

      // Safely access response data with null checks
      final responseData = customResponse.response?.data;
      
      if (responseData != null && responseData is List && responseData.isNotEmpty) {
        final userData = responseData[0];
        
        if (userData != null && userData is Map) {
          // Safely set user preferences
          PrefManager.setUserName(userData["name"]?.toString() ?? '');
          
          final isGuest = userData["is_guest"];
PrefManager.setIsGuest(isGuest is bool ? isGuest : false);
          
          PrefManager.setUserProfileImageUrl(userData["dp"]?.toString() ?? '');

      if (flag == 0) {
            PrefManager.setUserProfileImage(userData["dp"]?.toString() ?? '');
        flag = 1;
          }
        }
      }
      
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }




  @override
  Future<Either<Failure, CustomResponse>> deleteAccount(String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        data: {'flag': 1},
        url: "${AppConstant.feedUserDelete}?user=$id",
        referer: "${AppConstant.baseUrl}${AppConstant.feedUserDelete}?user=$id",
      );
      
      return right(customResponse); 
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> likeTemple(int id, bool isLiked) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.exploreSingleDevalay}/$id/",
        data: {'liked': isLiked},
        referer:
            '${AppConstant.baseUrl}/${AppConstant.exploreSingleDevalay}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> likeEvent(int id, bool isLiked) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.exploreSingleEvent}/$id/",
        data: {'liked': isLiked},
        referer:
            '${AppConstant.baseUrl}/${AppConstant.exploreSingleEvent}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> likeDev(int id, bool isLiked) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.exploreSingleDev}/$id/",
        data: {'liked': isLiked},
        referer:
            '${AppConstant.baseUrl}/${AppConstant.exploreSingleDev}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> likeFestival(int id, bool isLiked) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.exploreSingleFestival}/$id/",
        data: {'liked': isLiked},
        referer:
            '${AppConstant.baseUrl}/${AppConstant.exploreSingleFestival}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> saveTemple(
      int id, bool isSaved) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "${AppConstant.exploreSingleDevalay}/$id/",
        data: {'saved': isSaved},
        referer:
            '${AppConstant.baseUrl}/${AppConstant.exploreSingleDevalay}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileLikedTempleData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url:
            "${AppConstant.exploreSingleDevalay}/?liked=true&limit=10&page=$page",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileLikedPostData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: "${AppConstant.feedCommentPost}?liked=true&limit=10&page=$page",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileLikedEventsData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleEvent}/?liked=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileLikedPujaData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSinglePuja}/?liked=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileLikedFestivalData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleFestival}/?liked=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileLikedDevsData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleDev}/?liked=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileSavedTempleData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleDevalay}/?saved=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileSavedPostData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: '${AppConstant.feedCreatePost}?saved=true&limit=10&page=$page');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileSavedEventsData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleEvent}/?saved=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileSavedDevData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleDev}/?saved=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileSavedFestivalData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSingleFestival}/?saved=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileSavedPujaData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreSinglePuja}/?saved=true&limit=10&page=$page");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
  @override
  Future<Either<Failure, CustomResponse>> saveEvent(int id, bool isSaved) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.exploreSingleEvent}/$id/",
          data: {'saved': isSaved},
          referer:
              '${AppConstant.baseUrl}/${AppConstant.exploreSingleEvent}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e); 
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> saveDev(int id, bool isSaved) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.exploreSingleDev}/$id/",
          data: {'saved': isSaved},
          referer:
              '${AppConstant.baseUrl}/${AppConstant.exploreSingleDev}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> saveFestival(int id, bool isSaved) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.exploreSingleFestival}/$id/",
          data: {'saved': isSaved},
          referer:
              '${AppConstant.baseUrl}/${AppConstant.exploreSingleDev}/$id/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

 @override
Future<Either<Failure, CustomResponse>> fetchDetailData({
  String? location,
  String? country,
  String? dropdownValue,
  String? phone,
  String? email,
  String? firstName,
  String? dob,
  String? bio,
  bool? isServiceProvider
}) async {
  final devalayId = await PrefManager.getUserDevalayId();

  try {
    // Prepare data with proper null handling - don't send empty strings
    final Map<String, dynamic> requestData = {};
    
    // Only add non-null and non-empty values to the request
    if (firstName != null && firstName.isNotEmpty) {
      requestData['first_name'] = firstName;
    }
    
    // Always send last_name as empty string if your API requires it
    requestData['last_name'] = "";
    
    if (bio != null && bio.isNotEmpty) {
      requestData['biography'] = bio;
      // Remove duplicate 'bio' field - use 'biography' as per API expectation
    }
    
    if (location != null && location.isNotEmpty) {
      requestData['city'] = location;
    }
    
    if (dob != null && dob.isNotEmpty) {
      requestData['dob'] = dob;
    }
    
    if (country != null && country.isNotEmpty) {
      requestData['country'] = country;
    }
    
    if (dropdownValue != null && dropdownValue.isNotEmpty) {
      requestData['gender'] = dropdownValue;
    }
    
    if (phone != null && phone.isNotEmpty) {
      requestData['phone'] = phone;
    }
    
    if (email != null && email.isNotEmpty) {
      requestData['email'] = email;
    }
        if (isServiceProvider != null && isServiceProvider) {
      requestData['is_pandit'] = isServiceProvider;
    }

    // Log the request data for debugging
    Logger.log("API Request Data: $requestData");

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.patch,
      url: "${AppConstant.feedUser}/$devalayId/",
      referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$devalayId/",
      data: requestData,
    );
    
    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError("Error in fetchDetailData: $e");
    return left(Failure.getDioException(e));
  }
}
  @override
  Future<Either<Failure, CustomResponse>> updateProfileImage(File? file) async {
    final devalayId = await PrefManager.getUserDevalayId();
    FormData formData = FormData();
    if (file != null) {
      formData.files
          .add(MapEntry('dp', await MultipartFile.fromFile(file.path)));
    }
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$devalayId/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$devalayId/",
          data: formData);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateBackgroundImage(
      File? file) async {
    final devalayId = await PrefManager.getUserDevalayId();
    FormData formData = FormData();
    if (file != null) {
      formData.files.add(MapEntry(
          'background_image', await MultipartFile.fromFile(file.path)));
    }
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$devalayId/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$devalayId/",
          data: formData);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateRequestStatus(
      String status, String id) async {
    final devalayId = await PrefManager.getUserDevalayId();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$devalayId/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/1/",
          data: {'action': "remove", 'block': id});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateRequestDeleteStatus(
      String status, String id) async {
    final devalayId = await PrefManager.getUserDevalayId();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$id/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$id/",
          data: {'action': status, 'following_requests': devalayId});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateSendRequestDeleteStatus(
      String status, String id) async {
    final devalayId = await PrefManager.getUserDevalayId();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$devalayId/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$devalayId/",
          data: {'action': status, 'following_requests': id});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateRequestSendStatus(
      String status, String id) async {
    final devalayId = await PrefManager.getUserDevalayId();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$id/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$id/",
          data: {'action': status, 'following': devalayId});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateFollowingStatus(
      String status, String id) async {
    final devalayId = await PrefManager.getUserDevalayId();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedUser}/$devalayId/",
          referer: "${AppConstant.baseUrl}${AppConstant.feedUser}/$devalayId/",
          data: {'action': status, 'following': id});
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchProfileData(
      int page, String devalayId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.feedCreatePost}?user=$devalayId&limit=10&page=$page");

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchMediaInfoData(
      String postId) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/Post/$postId/");
      Logger.log("profile----${customResponse.response!.data}");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
}
