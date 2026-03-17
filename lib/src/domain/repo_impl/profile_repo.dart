import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/data/model/setting/notification_settings_model.dart';

abstract class ProfileRepo {


  Future<Either<Failure, CustomResponse>> fetchNotificationSettings();
  
  Future<Either<Failure, CustomResponse>> updateNotificationSettings(
    NotificationSettingsModel settings
  );



  Future<Either<Failure, CustomResponse>> fetchProfileInfoData(
      String devalayId);
      
  Future<Either<Failure, CustomResponse>> fetchProfileData(
      int page, String devalayId);
  Future<Either<Failure, CustomResponse>> saveTemple(int id, bool isSaved);
  Future<Either<Failure, CustomResponse>> likeTemple(int id, bool isLiked);
  Future<Either<Failure, CustomResponse>> likeEvent(int id, bool isLiked);
  Future<Either<Failure, CustomResponse>>   deleteAccount(String id);
  Future<Either<Failure, CustomResponse>> likeDev(int id, bool isLiked);
  Future<Either<Failure, CustomResponse>> likeFestival(int id, bool isLiked);
  Future<Either<Failure, CustomResponse>> saveEvent(int id, bool isSaved);
  Future<Either<Failure, CustomResponse>> saveDev(int id, bool isSaved);
  Future<Either<Failure, CustomResponse>> saveFestival(int id, bool isSaved);
  Future<Either<Failure, CustomResponse>> fetchProfileLikedTempleData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileLikedPostData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileLikedEventsData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileLikedPujaData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileLikedFestivalData(
      int page);
  Future<Either<Failure, CustomResponse>> fetchProfileLikedDevsData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileSavedTempleData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileSavedPostData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileSavedEventsData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileSavedDevData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileSavedFestivalData(int page);
  Future<Either<Failure, CustomResponse>> fetchProfileSavedPujaData(int page);

  Future<Either<Failure, CustomResponse>> fetchMediaInfoData(String postId);
  Future<Either<Failure, CustomResponse>> updateRequestStatus(
      String status, String id);
  Future<Either<Failure, CustomResponse>> updateRequestDeleteStatus(
      String status, String id);
  Future<Either<Failure, CustomResponse>> updateSendRequestDeleteStatus(
      String status, String id);
  Future<Either<Failure, CustomResponse>> updateRequestSendStatus(
      String status, String id);

  Future<Either<Failure, CustomResponse>> updateFollowingStatus(
      String status, String id);
  Future<Either<Failure, CustomResponse>> updateProfileImage(File file);
  Future<Either<Failure, CustomResponse>> updateBackgroundImage(File file);
  Future<Either<Failure, CustomResponse>> fetchDetailData({String location,
      String country, String dropdownValue, String phone, String email , String firstName , String dob, String? bio,bool isServiceProvider});
}
