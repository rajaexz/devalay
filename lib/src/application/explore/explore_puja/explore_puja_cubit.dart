import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/explore/explore_puja/explore_puja_state.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/explore/explore_puja_model.dart';
import 'package:devalay_app/src/data/model/explore/single_puja_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExplorePujaCubit extends Cubit<ExplorePujaState> {
  ExplorePujaCubit()
      : exploreRepo = getIt<ExploreRepo>(),
        super(ExplorePujaInitial());

  ExploreRepo exploreRepo;

  int page = 1;
  bool hasMoreData = true;

  List<ExplorePujaModel> allDate = [];

  Future<void> fetchExplorePujaData({
    bool loadMoreData = false,
    bool upDateData = false,
  }) async {
    try {
      if (!hasMoreData && loadMoreData) return;

      upDateData ? null : setScreenState(isLoading: true, data: allDate);

      if (loadMoreData) {
        page++;
      } else {
        page = 1;
        allDate.clear();
      }

      final result = await exploreRepo.fetchExplorePujaData(page);

      result.fold((failure) {
        hasMoreData = false;
        setScreenState(isLoading: false, data: allDate);
        if (failure.toString() == "Not Found") {
          hasMoreData = false;
        }
        Logger.log("this is ${failure.toString()}");
      }, (data) {
        final responseData = data.response?.data;
        if (responseData is Map &&
            responseData.containsKey("detail") &&
            responseData["detail"] == "Invalid page.") {
          hasMoreData = false;
          setScreenState(isLoading: false, data: allDate);
          return;
        }
        final pujaData = (data.response?.data as List)
            .map((x) => ExplorePujaModel.fromJson(x))
            .toList();
        allDate.addAll(pujaData);
        hasMoreData = pujaData.isNotEmpty;
        setScreenState(isLoading: false, data: allDate);
      });
      if (upDateData) {
        result.fold((failure) {
          setScreenState(isLoading: false, data: allDate);
        }, (customResponse) {
          final updatedPost =
              ExplorePujaModel.fromJson(customResponse.response!.data[0]);

          final updatedList = allDate.map((post) {
            if (post.id == updatedPost.id) {
              return updatedPost;
            }
            return post;
          }).toList();

          setScreenState(
            isLoading: false,
            data: updatedList,
          );
        });
      }
    } catch (e) {
      Logger.logError('fetchExploreFestivalData exception');
      setScreenState(isLoading: false, data: allDate);
    }
  }

  Future<void> fetchSinglePujaData(String id, {bool isUpdate = false}) async {
    if (!isUpdate) {
      setScreenState(isLoading: true);
    }

    final result = await exploreRepo.fetchSingleExplorePujaData(id);

    if (isUpdate) {
      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (data) {
        final rawData = data.response?.data;
        final updatedItem = SinglePujaModel.fromJson(rawData);
        List<ExplorePujaModel> updatedList = allDate.map((post) {
          if (post.id.toString() == id) {
            return ExplorePujaModel.fromJson(rawData);
          }
          return post;
        }).toList();
        setScreenState(
          isLoading: false,
          data: updatedList,
          singlePuja: updatedItem,
        );
      });
    } else {
      result.fold(
        (failure) {
          setScreenState(isLoading: false, message: failure.toString());
        },
        (customResponse) {
          final pujaData =
              SinglePujaModel.fromJson(customResponse.response?.data);
          setScreenState(isLoading: false, singlePuja: pujaData, data: allDate);
        },
      );
    }
  }

  Future<void> changeLikeStatus(String? id, String? status) async {
    final result = await exploreRepo.changeLikeStatus(id!, status!, 'Puja');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Temple liked successfully");
        final updatedPost =
            ExplorePujaModel.fromJson(success.response!.data["data"]);
        final updatedList = allDate.map((post) {
          if (post.id.toString() == id) {
            return updatedPost;
          }
          return post;
        }).toList();
        setScreenState(isLoading: false, data: updatedList);
        fetchExplorePujaData(upDateData: true);
      },
    );
  }

  Future<void> changeSingleLikeStatus(String? id, String? status) async {
    final result = await exploreRepo.changeLikeStatus(id!, status!, 'Puja');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Temple liked successfully");

        final rawData = success.response?.data;

        if (rawData is Map<String, dynamic> && rawData['data'] != null) {
          final updatedItem = SinglePujaModel.fromJson(rawData['data']);
          List<ExplorePujaModel> updatedList = allDate.map((post) {
            if (post.id.toString() == id) {
              return ExplorePujaModel.fromJson(rawData['data']);
            }
            return post;
          }).toList();

          setScreenState(
            isLoading: false,
            data: updatedList,
            singlePuja: updatedItem,
          );
        } else {
          setScreenState(isLoading: false, message: "Invalid response format");
        }
      },
    );
  }

  Future<void> changeSingleSavedStatus(String? id, String? status) async {
    final result = await exploreRepo.changeSavedStatus(id!, status!, 'Puja');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Puja saved successfully");

        fetchSinglePujaData(id, isUpdate: true);
      },
    );
  }

  void setScreenState(
      {List<ExplorePujaModel>? data,
      SinglePujaModel? singlePuja,
      required bool isLoading,
      String? message,
      bool hasError = false}) {
    emit(ExplorePujaLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        explorePujaList: data,
        singlePuja: singlePuja,
        hasError: hasError,
        currentPage: page));
  }
}
