import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';

abstract class ExploreRepo {

  //Globle search
  Future<Either<Failure, CustomResponse>> fetchExploreTempleData(int page);
  Future<Either<Failure, CustomResponse>> setTemplesFilter(String allFilterSearch);   
  
  Future<Either<Failure, CustomResponse>> postFollowing( followingUserId, userId, isFollowing);
  Future<Either<Failure, CustomResponse>> fetchGlobleSearchData(String text, String searchType, [String filterQuery = '', int page = 1]);
  Future<Either<Failure, CustomResponse>> postSearch(String makeSearch);  
  Future<Either<Failure, CustomResponse>> fetchExploreDevoteesData(int page);
  Future<Either<Failure, CustomResponse>> fetchSingleTempleData(String id);
  Future<Either<Failure, CustomResponse>> changeViewStatus(
      String id, String status, String type);
  Future<Either<Failure, CustomResponse>> fetchTempleFilterData();
  Future<Either<Failure, CustomResponse>> changeLikeStatus(
      String id, String status, String type);
  Future<Either<Failure, CustomResponse>> changeSavedStatus(
      String id, String status, String type);
  Future<Either<Failure, CustomResponse>> fetchExploreFestivalData(int page);
  Future<Either<Failure, CustomResponse>> fetchFestivalFilterData();
  Future<Either<Failure, CustomResponse>> fetchSingleFestivalData(String id);
  Future<Either<Failure, CustomResponse>> fetchExploreDevData(int page);
  Future<Either<Failure, CustomResponse>> fetchSingleDevData(String id);
  Future<Either<Failure, CustomResponse>> fetchExploreEventData(int page);
  Future<Either<Failure, CustomResponse>> fetchSingleEventData(String id);
  Future<Either<Failure, CustomResponse>> fetchEventFilterData();
  Future<Either<Failure, CustomResponse>> fetchExplorePujaData(int page);
  Future<Either<Failure, CustomResponse>> fetchSingleExplorePujaData(String id);
  Future<Either<Failure, CustomResponse>> fetchMentionExplore({String? contentType,int? page, String? id});
}
