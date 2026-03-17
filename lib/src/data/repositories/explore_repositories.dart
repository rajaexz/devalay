import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ExploreRepo)
class ExploreRepositories extends ExploreRepo {

  
  @override
  Future<Either<Failure, CustomResponse>> fetchExploreTempleData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreDevalay}&page=$page&limit=10&sort_by=likes&order_by=desc");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> setTemplesFilter(
      String allFilterSearch) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: allFilterSearch);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchExploreDevoteesData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: "/search/?limit=10&page=$page&showOnly=${AppConstant.devalayPeople}");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> postSearch(String makeSearch) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.feedFollowingPost}?limit=10&page=1&search=$makeSearch");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchGlobleSearchData(
      String text, String searchType, [String filterQuery = '', int page = 1]) async {
    try {
   
        String showOnly = searchType == "Temple" ? "Devalay" : searchType;
      String url = "${AppConstant.globleSearch}?limit=10${text != "" ? "&query=$text" : ""}${showOnly != "" ? "&showOnly=$showOnly" : ""}&page_number=$page";
      
      // Add filterQuery to URL if it's not empty
      if (filterQuery.isNotEmpty) {
        url += filterQuery;
      }
      
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: url);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> postFollowing(
      followingUserId, userId, isFollowing) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: "${AppConstant.feedFollowingPost}$userId/",
          referer:
              "${AppConstant.baseUrl}${AppConstant.feedFollowingPost}$userId/",
          data: {
            "following_requests": followingUserId,
            "action": isFollowing ? "add" : "remove"
          });

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchSingleTempleData(
      String id) async
  {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: '${AppConstant.exploreSingleDevalay}/$id/',
          referer: '${AppConstant.exploreSingleDevalay}/$id/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  

  @override
  Future<Either<Failure, CustomResponse>> changeViewStatus(
      String id, String status, String type) async {
    final bool likedStatus = status.toLowerCase() == 'true';
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: '/$type/$id/',
          data: {'viewed': likedStatus},
          referer: '${AppConstant.baseUrl}/$type/$id/');

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }


//function for changing like status
  @override
  Future<Either<Failure, CustomResponse>> changeLikeStatus(
      String id, String status, String type) async {
    final bool likedStatus = status.toLowerCase() == 'true';
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: '/$type/$id/',
          data: {'liked': likedStatus},
          referer: '${AppConstant.baseUrl}/$type/$id/');

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  //function for changing saved status
  @override
  Future<Either<Failure, CustomResponse>> changeSavedStatus(
      String id, String status, String type) async {
    final bool savedStatus = status.toLowerCase() == 'true';
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: '/$type/$id/',
          data: {'saved': savedStatus},
          referer: '${AppConstant.baseUrl}/$type/$id/');

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchTempleFilterData() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: AppConstant.exploreTempleFilter);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchExploreFestivalData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreFestival}/?page=$page&limit=10");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchSingleFestivalData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: '${AppConstant.exploreSingleFestival}/$id/',
          referer: '${AppConstant.exploreSingleFestival}/$id/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchFestivalFilterData() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: AppConstant.exploreFestivalFilter);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchExploreDevData(int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreDev}&page=$page&limit=10&sort_by=likes&order_by=desc");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchSingleDevData(String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: '${AppConstant.exploreSingleDev}/$id/',
          referer: '${AppConstant.exploreSingleDev}/$id/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchExploreEventData(
      int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.exploreEvent}&page=$page&limit=10&sort_by=likes&order_by=desc");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchSingleEventData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: '${AppConstant.exploreSingleEvent}/$id/',
          referer: '${AppConstant.exploreSingleEvent}/$id/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchEventFilterData() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: AppConstant.exploreEventFilter);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchExplorePujaData(int page) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
              "${AppConstant.explorePuja}&page=$page&limit=10&sort_by=likes&order_by=desc");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchSingleExplorePujaData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get, url: '${AppConstant.exploreSinglePuja}/$id/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchMentionExplore({String? contentType,int? page, String? id}) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url:
          "${AppConstant.mentionPost}?content_type=$contentType&object_id=$id");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

}
