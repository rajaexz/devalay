import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/logger.dart';

@LazySingleton(as: ContributeRepo)
class ContributeRepositories extends ContributeRepo {
  @override
  Future<Either<Failure, CustomResponse>> fetchContributeTempleData(
      {String? type,
      String? value,
      String? approvedVal,
      String? rejectVal,
      String? draftVal,
      String? filterQuery = '',
      int? page}) async {
    try {
      String url = "/$type/?view=contribution&limit=10&page=$page$filterQuery";

      if (value != null) {
        url += "&verified=$value";
      }

      if (approvedVal != null) {
        url += "&approved=$approvedVal";
      }
      if (rejectVal != null) {
        url += "&rejected=$rejectVal";
      }
      if (draftVal != null) {
        url += "&draft=$draftVal";
      }
      final CustomResponse customResponse =
          await ApiCalling().callApi(apiTypes: ApiTypes.get, url: url);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchSingleContributeTempleData(
      String id, String? type,
      {String? value}) async {
    try {
      String url = "/$type/$id/?view=contribution";

      if (value != null) {
        url += "&verified=$value";
      }

      final CustomResponse customResponse =
          await ApiCalling().callApi(apiTypes: ApiTypes.get, url: url);

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchGodFormData() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/Dev/?view=form");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchAvatarFormData() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: "/Dev/?view=slider&pramukh=true");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchGodTempleData() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/Devalay/?view=slider");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitTemple(
      String title, String website) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('website', website));
      formData.fields.add(MapEntry('website', website));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Devalay/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitEvent(
      String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Event/",
          data: formData,
          referer: "https://devalay.org/apis/Event/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitDev(
      String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Dev/",
          data: formData,
          referer: "https://devalay.org/apis/Dev/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitPuja(
      String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Puja/",
          data: formData,
          referer: "https://devalay.org/apis/Puja/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitFestival(
      String title, String subtitle) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      // formData.fields.add(MapEntry('description', description));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Festival/",
          data: formData,
          referer: "https://devalay.org/apis/Festival/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleInfo(
      String id,
      String title,
      String website,
      int a,
      String titles,
      String subtitle,
      String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('website', website));
      formData.fields.add(MapEntry('governing_title', titles));
      formData.fields.add(MapEntry('governing_email', subtitle));
      formData.fields.add(MapEntry('governing_phone', description));
      formData.fields.add(const MapEntry('steps', "1"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Devalay/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      print("qwertygbioj----->$titles");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDonate(
      String name,
      String email,
      String mobileNumber,
      String message,
      String amount,
      String pan) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('name', name));
      formData.fields.add(MapEntry('email', email));
      formData.fields.add(MapEntry('mobile_number', mobileNumber));
      formData.fields.add(MapEntry('message', message));
      formData.fields.add(MapEntry('amount', amount));
      formData.fields.add(MapEntry('pan', pan));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/Donations/",
          data: formData,
          referer: "https://devalay.org/apis/Donations/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDonatePayment(
      String donationId) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('donation_id', donationId));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/payment/",
          data: formData,
          referer: "https://devalay.org/apis/payment/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateAcceptBanner(
      String type, String id, String approved) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('approved', approved));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/${type}ContentImages/$id/",
          data: formData,
          referer: "https://devalay.org/apis/${type}ContentImages/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateAcceptDevs(
      String templeId, String id, String approved) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('approved', approved));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/DevalayGod/$id/?&devalay=$templeId",
          data: formData,
          referer: "https://devalay.org/apis/DevalayGod/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> deleteImage(
      String type, String templeId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.delete,
          url: "/${type}ContentImages/$templeId/?",
          // data: formData,
          referer: "https://devalay.org/apis/${type}ContentImages/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> deleteItem(
      String type, String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.delete,
          url: "/$type/$id/?view=contribution",
          // data: formData,
          referer: "https://devalay.org/apis/$type/$id/?view=contribution");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  Future<Either<Failure, CustomResponse>> updateTempleDevsAccept(
      String id, String approved) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('approved', approved));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/DevalayContentImages/$id/",
          data: formData,
          referer: "https://devalay.org/apis/DevalayContentImages/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateEventInfo(
      String id, String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(const MapEntry('steps', "1"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Event/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Event/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDevInfo(
      String id, String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(const MapEntry('steps', "1"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Dev/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Dev/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePujaInfo(
      String id, String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Puja/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Puja/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateFestivalInfo(
      String id, String title, String subtitle) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Festival/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Festival/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateFestivalAbout(
      String id, String about, String history) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('description', about));
      formData.fields.add(MapEntry('history', history));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Festival/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Festival/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateCelebrate(
      String id, String celebrate, String dos, String donts) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('why_we_celebrate', celebrate));
      formData.fields.add(MapEntry('dos', dos));
      formData.fields.add(MapEntry('donts', donts));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Festival/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Festival/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleAddress(
      String id,
      String streetAddress,
      String city,
      String state,
      String country,
      String pincode,
      String landmark,
      String nearestAirport,
      String nearestRailway,
      String googleLink) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('address', streetAddress));
      formData.fields.add(MapEntry('city', city));
      formData.fields.add(MapEntry('state', state));
      formData.fields.add(MapEntry('country', country));
      formData.fields.add(MapEntry('pincode', pincode));
      formData.fields.add(MapEntry('landmark', landmark));
      formData.fields.add(MapEntry('nearest_airport', nearestAirport));
      formData.fields.add(MapEntry('nearest_railway', nearestRailway));
      formData.fields.add(MapEntry('google_map_link', googleLink));
      formData.fields.add(const MapEntry('steps', "3"));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Devalay/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
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
        url: "/places-v2/?input=$input",
        referer: "/places-v2/?$input",
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTemplePhoto(
      String id, List<File> banner, List<File> gallery) async {
    try {
      final formData = FormData();

      for (var i = 0; i < banner.length; i++) {
        formData.files.add(
          MapEntry(
            'banner_file',
            await MultipartFile.fromFile(
              banner[i].path,
              filename: banner[i].path.split('/').last,
            ),
          ),
        );
      }

      for (var i = 0; i < gallery.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery_file',
            await MultipartFile.fromFile(
              gallery[i].path,
              filename: gallery[i].path.split('/').last,
            ),
          ),
        );
      }

      formData.fields.add(const MapEntry('steps', "2"));

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Devalay/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Devalay/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateEventAllPhoto(
      String id, List<File> banner, List<File> gallery) async {
    try {
      final formData = FormData();

      for (var i = 0; i < banner.length; i++) {
        formData.files.add(
          MapEntry(
            'banner_file',
            await MultipartFile.fromFile(
              banner[i].path,
              filename: banner[i].path.split('/').last,
            ),
          ),
        );
      }

      for (var i = 0; i < gallery.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery_file',
            await MultipartFile.fromFile(
              gallery[i].path,
              filename: gallery[i].path.split('/').last,
            ),
          ),
        );
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Event/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Event/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePujaAllPhoto(
      String id, List<File> banner, List<File> gallery) async {
    try {
      final formData = FormData();

      for (var i = 0; i < banner.length; i++) {
        formData.files.add(
          MapEntry(
            'banner_file',
            await MultipartFile.fromFile(
              banner[i].path,
              filename: banner[i].path.split('/').last,
            ),
          ),
        );
      }

      for (var i = 0; i < gallery.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery_file',
            await MultipartFile.fromFile(
              gallery[i].path,
              filename: gallery[i].path.split('/').last,
            ),
          ),
        );
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Puja/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Puja/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleBannerPhoto(
      String id, List<File> banner, String imageType) async {
    try {
      final formData = FormData();

      for (var i = 0; i < banner.length; i++) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              banner[i].path,
              filename: banner[i].path.split('/').last,
            ),
          ),
        );
      }
      formData.fields.add(MapEntry('image_type', imageType));
      formData.fields.add(MapEntry('devalay', id));

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/DevalayContentImages/",
        data: formData,
        referer: "https://devalay.org/apis/DevalayContentImages/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateEventPhoto(
      String id, List<File> image, String imageType) async {
    try {
      final formData = FormData();

      for (var i = 0; i < image.length; i++) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image[i].path,
              filename: image[i].path.split('/').last,
            ),
          ),
        );
      }
      formData.fields.add(MapEntry('image_type', imageType));
      formData.fields.add(MapEntry('event', id));
      formData.fields.add(const MapEntry('steps', "2"));
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/EventContentImages/",
        data: formData,
        referer: "https://devalay.org/apis/EventContentImages/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDevPhoto(
      String id, List<File> image, String imageType) async {
    try {
      final formData = FormData();

      for (var i = 0; i < image.length; i++) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image[i].path,
              filename: image[i].path.split('/').last,
            ),
          ),
        );
      }
      formData.fields.add(MapEntry('image_type', imageType));
      formData.fields.add(MapEntry('dev', id));
      formData.fields.add(const MapEntry('steps', "2"));
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/DevContentImages/",
        data: formData,
        referer: "https://devalay.org/apis/DevContentImages/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePujaPurpose(String pujaId,
      {required Map<String, dynamic> purposeOutput,
      required Map<String, dynamic> procedureOutput}) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('purpose', jsonEncode(purposeOutput)));
      formData.fields.add(MapEntry('procedure', jsonEncode(procedureOutput)));
      formData.fields.add(const MapEntry('draft', 'false'));

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Puja/$pujaId/",
        data: formData,
        referer: "https://devalay.org/apis/Puja/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePujaPhoto(
      String id, List<File> image, String imageType) async {
    try {
      final formData = FormData();

      for (var i = 0; i < image.length; i++) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image[i].path,
              filename: image[i].path.split('/').last,
            ),
          ),
        );
      }
      formData.fields.add(MapEntry('image_type', imageType));
      formData.fields.add(MapEntry('puja', id));

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/PujaContentImages/",
        data: formData,
        referer: "https://devalay.org/apis/PujaContentImages/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateFestivalPhoto(
      String id, List<File> image, String imageType) async {
    try {
      final formData = FormData();

      for (var i = 0; i < image.length; i++) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image[i].path,
              filename: image[i].path.split('/').last,
            ),
          ),
        );
      }
      formData.fields.add(MapEntry('image_type', imageType));
      formData.fields.add(MapEntry('festival', id));

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/FestivalContentImages/",
        data: formData,
        referer: "https://devalay.org/apis/FestivalContentImages/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateEventGod(
      String id, List<String> godIds) async {
    try {
      final formData = FormData();

      for (var godId in godIds) {
        formData.fields.add(
            MapEntry('devs', godId)); // Or 'god[]' if your backend expects that
      }
      formData.fields.add(const MapEntry('steps', "4"));
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Event/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Event/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePujaGod(
      String id, List<String> godIds) async {
    try {
      final formData = FormData();
      print(godIds);
      for (var godId in godIds) {
        formData.fields.add(
            MapEntry('devs', godId)); // Or 'god[]' if your backend expects that
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Puja/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Puja/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateFestivalGod(
      String id, List<String> godIds) async {
    try {
      final formData = FormData();

      for (var godId in godIds) {
        formData.fields.add(
            MapEntry('devs', godId)); // Or 'god[]' if your backend expects that
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Festival/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Festival/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateEventDate(
      String id, Map<String, String> dateTimeMap) async {
    try {
      final formData = FormData();

      dateTimeMap.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });
      formData.fields.add(const MapEntry('steps', "5"));
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Event/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Event/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateFestivalDate(
      String id, Map<String, String> dateTimeMap) async {
    try {
      final formData = FormData();

      dateTimeMap.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/Festival/$id/",
        data: formData,
        referer: "https://devalay.org/apis/Festival/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
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
      String googleLink) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('devalay-checkbox', value));
      formData.fields.add(MapEntry('devalay', devalay));
      formData.fields.add(MapEntry('address', streetAddress));
      formData.fields.add(MapEntry('city', city));
      formData.fields.add(MapEntry('state', state));
      formData.fields.add(MapEntry('country', country));
      formData.fields.add(MapEntry('pincode', landmark));
      formData.fields.add(MapEntry('nearest_airport', nearestAirport));
      formData.fields.add(MapEntry('nearest_railway', nearestRailway));
      formData.fields.add(MapEntry('google_map_link', googleLink));
      formData.fields.add(const MapEntry('steps', "3"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Event/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Event/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDevAvatar(
      String id, String value, String avatarId) async {
    try {
      FormData formData = FormData();
      if (avatarId == '') {
        formData.fields.add(MapEntry('pramukh', value));
      }
      if (value == '') {
        formData.fields.add(MapEntry('avatar', avatarId));
      }
      formData.fields.add(const MapEntry('steps', "3"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Dev/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Dev/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateEventAdditionalDetail(
      String id, String celebrate, String dos, String donts) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('how_to_celebrate', celebrate));
      formData.fields.add(MapEntry('dos', dos));
      formData.fields.add(MapEntry('donts', donts));
      formData.fields.add(const MapEntry('steps', "6"));
      formData.fields.add(const MapEntry('draft', "false"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Event/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Event/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleGod(
      String id, String devId) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('devalay', id));
      formData.fields.add(MapEntry('dev', devId));
      formData.fields.add(const MapEntry('steps', "4"));
      final customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/DevalayGod/?devalay=$id", // check if this query param is needed
        data: formData,
        referer: "https://devalay.org/apis/DevalayGod/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError("Error in updateTempleGod: $e");
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> rewriteWithAIApi(
      String label, List<Map<String, String>> qaData) async {
    try {
      String qaDataJson = jsonEncode(qaData);

      FormData formData = FormData.fromMap(
          {"table_name": "Devalay", "label": label, "qa_data": qaDataJson});

      // Make API call
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/RewriteWithAI/",
        data: formData,
        referer: "https://devalay.org/apis/RewriteWithAI/",
      );

      Logger.log("Response: ${customResponse.response?.data}");

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleHistory(
      String id,
      String answer1,
      String answer2,
      String answer3,
      String answer4,
      String answer5,
      String answer6) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('temple_history_1', answer1));
      formData.fields.add(MapEntry('temple_history_2', answer2));
      formData.fields.add(MapEntry('temple_history_3', answer3));
      formData.fields.add(MapEntry('temple_history_4', answer4));
      formData.fields.add(MapEntry('temple_history_5', answer5));
      formData.fields.add(MapEntry('temple_history', answer6));
      formData.fields.add(const MapEntry('steps', "5"));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Devalay/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleStories(
      String id,
      String answer1,
      String answer2,
      String answer3,
      String answer4,
      String answer5) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('legend_1', answer1));
      formData.fields.add(MapEntry('legend_2', answer2));
      formData.fields.add(MapEntry('legend_3', answer3));
      formData.fields.add(MapEntry('legend_4', answer4));
      formData.fields.add(MapEntry('legend', answer5));
      formData.fields.add(const MapEntry('steps', "6"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Devalay/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleEtymology(String id,
      String answer1, String answer2, String answer3, String answer4) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('etymology_1', answer1));
      formData.fields.add(MapEntry('etymology_2', answer2));
      formData.fields.add(MapEntry('etymology_3', answer3));
      formData.fields.add(MapEntry('etymology', answer4));
      formData.fields.add(const MapEntry('steps', "7"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Devalay/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleArchitecture(String id,
      String answer1, String answer2, String answer3, String answer4) async {
    try {
      FormData formData = FormData();

      // formData.fields.add(MapEntry('architecture_1', answer1));
      // formData.fields.add(MapEntry('architecture_2', answer2));
      // formData.fields.add(MapEntry('architecture_3', answer3));
      formData.fields.add(MapEntry('architecture', answer4));
      formData.fields.add(const MapEntry('draft', "false"));
      formData.fields.add(const MapEntry('steps', "8"));
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Devalay/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleEssence(
      String id, String subtitle, String about) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', about));
      formData.fields.add(MapEntry('draft', false.toString()));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Devalay/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateTempleGoverningBody(
      String id, String title, String subtitle, String description) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('governing_body_id', id));
      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('subtitle', subtitle));
      formData.fields.add(MapEntry('description', description));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Contribute/Governing/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Devalay/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateGodPhoto(
      String id, File? banner, String devalayId) async {
    try {
      FormData formData = FormData();

      if (banner != null) {
        formData.files
            .add(MapEntry('image', await MultipartFile.fromFile(banner.path)));
      }
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/DevalayGod/$id/?devalay=$devalayId",
          data: formData,
          referer: "https://devalay.org/apis/DevalayGod/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitReview(
    String type,
    String id,
    String approved, {
    Map<String, dynamic>? rejectReasons,
  }) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('approved', approved));

      if (rejectReasons != null && rejectReasons.isNotEmpty) {
        formData.fields
            .add(MapEntry('reject_reasons', jsonEncode(rejectReasons)));
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.patch,
        url: "/$type/$id/",
        data: formData,
        referer: "https://devalay.org/apis/$type/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDevAarti(id,
      {required Map<String, dynamic> aartiData}) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('aarti', jsonEncode(aartiData)));
      formData.fields.add(const MapEntry('steps', "4"));
      formData.fields.add(const MapEntry('draft', 'false'));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "/Dev/$id/",
          data: formData,
          referer: "https://devalay.org/apis/Dev/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
}
