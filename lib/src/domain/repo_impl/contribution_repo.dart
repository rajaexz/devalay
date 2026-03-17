import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';

abstract class ContributeRepo {
  // Future<Either<Failure, CustomResponse>> fetchContributeEventData(
  //     {String? type,
  //     String? value,
  //     String? approvedVal,
  //     String? rejectVal,
  //     String? draftVal,
  //     int? page});
  // Future<Either<Failure, CustomResponse>> fetchContributePujaData(
  //     {String? value, int? page});
  // Future<Either<Failure, CustomResponse>> fetchContributeFestivalData(
  //     {String? value, int? page});
  Future<Either<Failure, CustomResponse>> fetchContributeTempleData(
      {String? type,
      String? value,
      String? approvedVal,
      String? rejectVal,
      String? draftVal,
      int? page,
      String? filterQuery,
      
      });
  Future<Either<Failure, CustomResponse>> fetchSingleContributeTempleData(
      String id,String? type,
      {String? value});
  // Future<Either<Failure, CustomResponse>> fetchSingleContributeEventData(
  //     String id,
  //     {String? value});
  // Future<Either<Failure, CustomResponse>> fetchSingleContributePujaData(
  //     String id,
  //     {String? value});
  Future<Either<Failure, CustomResponse>> fetchGodFormData();
  Future<Either<Failure, CustomResponse>> fetchGodTempleData();
  Future<Either<Failure, CustomResponse>> fetchAvatarFormData();
  Future<Either<Failure, CustomResponse>> submitTemple(
      String title, String website);
  Future<Either<Failure, CustomResponse>> submitEvent(
      String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> submitDev(
      String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> submitPuja(
      String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> submitFestival(
      String title, String subtitle);
  Future<Either<Failure, CustomResponse>> updateTempleInfo(String id, String title, String website, int a, String titles, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> updateAcceptBanner(String type,
      String id, String approved);
  Future<Either<Failure, CustomResponse>> updateAcceptDevs(
      String templeId, String id, String approved);
  Future<Either<Failure, CustomResponse>> deleteImage(String type,
      String templeId) ;
  Future<Either<Failure, CustomResponse>> deleteItem(String type, String id);
  Future<Either<Failure, CustomResponse>> updateEventInfo(
      String id, String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> updateDevInfo(
      String id, String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> updatePujaInfo(
      String id, String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> updateFestivalInfo(
      String id, String title, String subtitle);
  Future<Either<Failure, CustomResponse>> updateFestivalAbout(
      String id, String about, String history);
  Future<Either<Failure, CustomResponse>> updateCelebrate(
      String id, String celebrate, String dos, String donts);
  Future<Either<Failure, CustomResponse>>  updateTempleAddress(
      String id,
      String streetAddress,
      String city,
      String state,
      String country,
      String pincode,
      String landmark,
      String nearestAirport,
      String nearestRailway,
      String googleLink);
  Future<Either<Failure, CustomResponse>> getLocationFromGoogleApi(
  String input);
  Future<Either<Failure, CustomResponse>> updateTemplePhoto(
      String id, List<File> banner, List<File> gallery
      );
  Future<Either<Failure, CustomResponse>> updateEventAllPhoto(
      String id, List<File> banner, List<File> gallery
      );
  Future<Either<Failure, CustomResponse>> updatePujaAllPhoto(
      String id, List<File> banner, List<File> gallery
      );
  Future<Either<Failure, CustomResponse>> updateTempleBannerPhoto(
      String id, List<File> banner, String imageType);
  Future<Either<Failure, CustomResponse>> updateEventPhoto(
      String id, List<File> image, String imageType);
  Future<Either<Failure, CustomResponse>> updateDevPhoto(
      String id, List<File> image, String imageType);
  Future<Either<Failure, CustomResponse>> updatePujaPurpose(
      String pujaId,
      {required Map<String, dynamic> purposeOutput,
        required Map<String, dynamic> procedureOutput});
  Future<Either<Failure, CustomResponse>> updatePujaPhoto(
      String id, List<File> image, String imageType);
  Future<Either<Failure, CustomResponse>> updateFestivalPhoto(
      String id, List<File> image, String imageType);
  Future<Either<Failure, CustomResponse>> updateEventGod(
      String id, List<String> godIds);
  Future<Either<Failure, CustomResponse>> updatePujaGod(
      String id, List<String> godIds);
  Future<Either<Failure, CustomResponse>> updateFestivalGod(
      String id, List<String> godIds);
  Future<Either<Failure, CustomResponse>>  updateEventDate(
      String id, Map<String, String> dateTimeMap);
  Future<Either<Failure, CustomResponse>>  updateFestivalDate(
      String id, Map<String, String> dateTimeMap);
  Future<Either<Failure, CustomResponse>> updateEventAddress(
      String id,
      String value,
      String devalay,
      String streetAddress,
      String city,
      String state,
      String country,
      String landmark,
      String nearestAirport,
      String nearestRailway,
      String googleLink);
  Future<Either<Failure, CustomResponse>> updateDevAvatar(
      String id,
      String value,
      String avatarId,);
  Future<Either<Failure, CustomResponse>> updateEventAdditionalDetail(
      String id,
      String celebrate,
      String dos,
      String donts);
  Future<Either<Failure, CustomResponse>> updateTempleGod(
      String id, String devId);
  Future<Either<Failure, CustomResponse>> rewriteWithAIApi(
      String label, List<Map<String, String>> qaData);
  Future<Either<Failure, CustomResponse>> updateTempleHistory(
      String id,
      String answer1,
      String answer2,
      String answer3,
      String answer4,
      String answer5,
      String answer6);

      
  Future<Either<Failure, CustomResponse>> updateTempleStories(
      String id,
      String answer1,
      String answer2,
      String answer3,
      String answer4,
      String answer5);
  Future<Either<Failure, CustomResponse>> updateTempleEtymology(String id,
      String answer1, String answer2, String answer3, String answer4);
  Future<Either<Failure, CustomResponse>> updateTempleArchitecture(String id,
      String answer1, String answer2, String answer3, String answer4);
  Future<Either<Failure, CustomResponse>> updateTempleEssence(
      String id, String subtitle, String about);
  Future<Either<Failure, CustomResponse>> updateTempleGoverningBody(
      String id, String title, String subtitle, String description);
  Future<Either<Failure, CustomResponse>> updateGodPhoto(
      String id, File? banner, String devalayId);
  Future<Either<Failure, CustomResponse>> submitReview(
      String type,
      String id,
      String approved, {
        Map<String, dynamic>? rejectReasons,
      });

  Future<Either<Failure, CustomResponse>> updateDevAarti(id,
      {required Map<String, dynamic> aartiData});
  Future<Either<Failure, CustomResponse>> updateDonate(
      String name,
      String email,
      String mobileNumber,
      String message,
      String amount,
      String pan);
  Future<Either<Failure, CustomResponse>> updateDonatePayment(
      String donationId);
}
