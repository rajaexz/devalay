import 'dart:math';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/explore/explore_dev/explore_dev_state.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/explore/explore_dev_model.dart';
import 'package:devalay_app/src/data/model/explore/single_gods_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExploreDevCubit extends Cubit<ExploreDevState> {
  ExploreDevCubit()
      : exploreRepo = getIt<ExploreRepo>(),
        super(ExploreDevInitial());

  ExploreRepo exploreRepo;

  int page = 1;
  bool hasMoreData = true;
  String currentFilterQuery = '';

  List<ExploreDevModel> allDate = [];
  int selectedFilter = 0;
  final List<String> filterTypes = ['Sort by', 'Order by'];
  final List<String> sortBy = ['Likes', 'Added date', 'Alphabetically'];
  final List orderBy = [
    {
      'title': 'Decending',
      'icon':
          'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/decending.svg'
    },
    {
      'title': 'Ascending',
      'icon':
          'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/ascending.svg'
    }
  ];

  final searchLocationController = TextEditingController();
  final searchDevController = TextEditingController();
  bool isLocationSelected = false;
  bool isDevSelected = false;
  String? selectedSortByIndex = 'Likes';
  String? selectedOrderByIndex = 'Decending';
  Map<String, dynamic> selectedLocationFilterMap = {};
  Map<String, dynamic> selectedDevFilterMap = {};
  String buildFilterQuery() {
    final List<String> queryParams = [];

    if (selectedSortByIndex != null) {
      String sortBy = selectedSortByIndex!.toLowerCase();

      if (sortBy == 'added date') sortBy = 'recent';

      if (sortBy == 'alphabetically') sortBy = 'alphabetically';

      queryParams.add('sort_by=$sortBy');
    }

    if (selectedOrderByIndex != null) {
      String orderBy = selectedOrderByIndex == 'Ascending' ? 'asce' : 'desc';
      queryParams.add('&order_by=$orderBy');
    }

    return queryParams.isEmpty ? '' : queryParams.join('');
  }

  Future<void> fetchExploreDevData(
      {bool loadMoreData = false,
      bool upDateData = false,
      String filterQuery = ""}) async {
    try {
      if (!hasMoreData && loadMoreData) return;

      upDateData ? null : setScreenState(isLoading: true, data: allDate);
      if (loadMoreData) {
        page++;
      } else {
        page = 1;
        allDate.clear();
      }

      final result = await exploreRepo.setTemplesFilter(
          '${AppConstant.exploreSingleDev}/?$filterQuery&page=$page&limit=10');

      result.fold((failure) {
        hasMoreData = false;
        setScreenState(isLoading: false, data: allDate);
        if (failure.toString() == "Not Found") {
          hasMoreData = false;
        }
        Logger.log("this is ${failure.toString()}");
      }, (data) {
        final devData = (data.response?.data as List)
            .map((x) => ExploreDevModel.fromJson(x))
            .toList();
        allDate.addAll(devData);
        hasMoreData = devData.isNotEmpty;
        setScreenState(isLoading: false, data: allDate);
      });

      if (upDateData) {
        result.fold((failure) {
          setScreenState(isLoading: false, data: allDate);
        }, (customResponse) {
          final updatedPost =
              ExploreDevModel.fromJson(customResponse.response!.data[0]);

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
      setScreenState(isLoading: false, data: allDate);
    }
  }

  Future<void> applyFilters(String filterQuery) async {
    currentFilterQuery = filterQuery;

    page = 1;
    allDate.clear();
    hasMoreData = true;

    await fetchExploreDevData(filterQuery: filterQuery);
  }

  Future<void> fetchSingleExploreGodData(String id) async {
    setScreenState(isLoading: true);

    final result = await exploreRepo.fetchSingleDevData(id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (data) {
      final devData = SingleGodModel.fromJson(data.response?.data);
      setScreenState(isLoading: false, singleGod: devData, data: allDate);
    });
  }

  Future<void> changeViewStatus(
      String id,
      ) async
  {
    try {
      final result = await exploreRepo.changeViewStatus(id, 'true', 'Dev');
      result.fold(
            (failure) {
          print("Server sync failed: ${failure.toString()}");
        },
            (success) {
          print("Server sync successful");
        },
      );
    } catch (e) {
      print("Server sync error: ${e.toString()}");
    }
  }

  Future<void> changeLikeStatus(String? id, String? status) async {
    if (id == null || status == null) return;

    final String itemId = id.toString();
    final bool newLikedState = status.toLowerCase() == 'true';

    try {
      // Get current state
      if (state is! ExploreDevLoaded) return;
      final currentState = state as ExploreDevLoaded;

      // Update UI optimistically (immediately without API call)
      List<ExploreDevModel> updatedList = [];

      for (var item in (currentState.exploreDevList ?? [])) {
        if (item.id.toString() == itemId) {
          // Create updated item with new like status
          var updatedItem = ExploreDevModel(
            id: item.id,
            title: item.title,
            images: item.images,
            subtitle: item.subtitle,
            liked: newLikedState,
            saved: item.saved, // Keep existing saved status
            likedCount: newLikedState
                ? (item.likedCount ?? 0) + 1
                : max((item.likedCount ?? 0) - 1, 0),
            savedCount: item.savedCount, // Keep existing saved count
            // Add other properties as needed
          );
          updatedList.add(updatedItem);
        } else {
          updatedList.add(item);
        }
      }

      // Update the local data
      allDate = updatedList;

      // Emit new state immediately with updated UI
      emit(ExploreDevLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreDevList: updatedList,
        singleGod: currentState.singleGod,
        hasError: currentState.hasError,
        currentPage: currentState.currentPage,
        feedData: currentState.feedData,
      ));

      // Call API in background (optional - only if you need to sync with server)
      _syncLikeStatusWithServer(itemId, status, updatedList, currentState);

    } catch (e) {
      print("Error in changeLikeStatus: ${e.toString()}");
    }
  }

// Optional: Background sync with server (without affecting UI)
  Future<void> _syncLikeStatusWithServer(
      String itemId,
      String status,
      List<ExploreDevModel> currentList,
      ExploreDevLoaded currentState
      ) async
  {
    try {
      final result = await exploreRepo.changeLikeStatus(itemId, status, 'Dev');

      result.fold(
            (failure) {
          // Optionally revert changes if server sync fails
          print("Server sync failed: ${failure.toString()}");
          // You can choose to revert the UI changes here if needed
        },
            (success) {
          // Server sync successful - no UI update needed as we already updated optimistically
          print("Server sync successful");

        },
      );
    } catch (e) {
      print("Server sync error: ${e.toString()}");
    }
  }

  Future<void> changeSavedStatus(String? id, String? status) async {
    if (id == null || status == null) return;

    final String itemId = id.toString();
    final bool newSavedState = status.toLowerCase() == 'true';

    try {
      if (state is! ExploreDevLoaded) return;
      final currentState = state as ExploreDevLoaded;

      List<ExploreDevModel> updatedList = [];

      for (var item in (currentState.exploreDevList ?? [])) {
        if (item.id.toString() == itemId) {
          var updatedItem = ExploreDevModel(
            id: item.id,
            title: item.title,
            images: item.images,
            subtitle: item.subtitle,
            liked: item.liked, // Keep existing liked status
            saved: newSavedState,
            likedCount: item.likedCount, // Keep existing liked count
            savedCount: newSavedState
                ? (item.savedCount ?? 0) + 1
                : max((item.savedCount ?? 0) - 1, 0),
          );
          updatedList.add(updatedItem);
        } else {
          updatedList.add(item);
        }
      }

      // Update the local data
      allDate = updatedList;

      // Emit new state immediately with updated UI
      emit(ExploreDevLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreDevList: updatedList,
        singleGod: currentState.singleGod,
        hasError: currentState.hasError,
        currentPage: currentState.currentPage,
        feedData: currentState.feedData,
      ));

      _syncSavedStatusWithServer(itemId, status, updatedList, currentState);

    } catch (e) {
      print("Error in changeSavedStatus: ${e.toString()}");
    }
  }

  Future<void> _syncSavedStatusWithServer(
      String itemId,
      String status,
      List<ExploreDevModel> currentList,
      ExploreDevLoaded currentState
      ) async {
    try {
      final result = await exploreRepo.changeSavedStatus(itemId, status, 'Dev');

      result.fold(
            (failure) {
          print("Server sync failed: ${failure.toString()}");
        },
            (success) {
          print("Server sync successful");
        },
      );
    } catch (e) {
      print("Server sync error: ${e.toString()}");
    }
  }

  Future<void> changeSingleLikeStatus(String? id, String? status) async {
    final result = await exploreRepo.changeLikeStatus(id!, status!, 'Dev');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Dev liked successfully");
        final rawData = success.response?.data["data"];
        final updatedItem = SingleGodModel.fromJson(rawData);
        List<ExploreDevModel> updatedList = allDate.map((post) {
          if (post.id.toString() == id) {
            return ExploreDevModel.fromJson(rawData);
          }
          return post;
        }).toList();
        setScreenState(
          isLoading: false,
          data: updatedList,
          singleGod: updatedItem,
        );
      },
    );
  }

  Future<void> changeSingleSavedStatus(String? id, String? status) async {
    final result = await exploreRepo.changeSavedStatus(id!, status!, 'Dev');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Dev liked successfully");
        final rawData = success.response?.data["data"];
        final updatedItem = SingleGodModel.fromJson(rawData);
        List<ExploreDevModel> updatedList = allDate.map((post) {
          if (post.id.toString() == id) {
            return ExploreDevModel.fromJson(rawData);
          }
          return post;
        }).toList();
        setScreenState(
          isLoading: false,
          data: updatedList,
          singleGod: updatedItem,
        );
      },
    );
  }

  void setScreenState(
      {List<ExploreDevModel>? data,
      SingleGodModel? singleGod,
      required bool isLoading,
      String? message,
      bool hasError = false}) {
    emit(ExploreDevLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        exploreDevList: data,
        singleGod: singleGod,
        hasError: hasError,
        currentPage: page));
  }
}
