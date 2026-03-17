import 'dart:math';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/explore/explore_festival/explore_festival_state.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/explore/explore_festival_model.dart';
import 'package:devalay_app/src/data/model/explore/filter/festival_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/single_festival_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/model/feed/feed_home_model.dart';

class ExploreFestivalCubit extends Cubit<ExploreFestivalState> {
  ExploreFestivalCubit()
      : exploreRepo = getIt<ExploreRepo>(),
        super(ExploreFestivalInitial());

  ExploreRepo exploreRepo;

  int page = 1;
  bool hasMoreData = true;

  List<ExploreFestivalModel> allDate = [];

  //==================================

  int selectedFilter = 0;
  final List<String> filterTypes = ['Date', 'Sort by', 'Order by'];
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
  final FocusNode focusNode = FocusNode();
  final searchLocationController = TextEditingController();
  final dateController = TextEditingController();
  bool isLocationSelected = false;
  bool isDevSelected = false;
  String? selectedLocationIndex;

  String? selectedSortByIndex = 'Likes';
  String? selectedOrderByIndex = 'Descending';
  Map<String, dynamic> selectedLocationFilterMap = {};

  bool _isMentionDataInitialized = false;
  String? _currentMentionId;
  String? _currentContentType;
  List<FeedGetData> allFeedData = [];
  int mentionPage = 1;
  bool mentionHasMoreData = true;

  final CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;

  Future<void>  fetchExploreFestivalData({
    bool loadMoreData = false,
    bool upDateData = false,
    String filterQuery = '',
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

      final result = filterQuery.isEmpty
          ? await exploreRepo.fetchExploreFestivalData(page)
          : await exploreRepo.setTemplesFilter(
              '${AppConstant.exploreSingleFestival}/?$filterQuery&page=$page');

      result.fold((failure) {
        hasMoreData = false;
        setScreenState(isLoading: false, data: allDate);
        if (failure.toString() == "Not Found") {
          hasMoreData = false;
        }
      }, (data) {
        if (data.response?.data == null) {
          Logger.log("Null response data received");
          setScreenState(isLoading: false, data: allDate);
          return;
        }

        if (data.response!.data is Map &&
            data.response!.data.containsKey("detail") &&
            data.response!.data["detail"] == "Invalid page.") {
          hasMoreData = false;
          setScreenState(isLoading: false, data: allDate);
          return;
        }

        final festivalData = (data.response?.data as List)
            .map((x) => ExploreFestivalModel.fromJson(x))
            .toList();
        allDate.addAll(festivalData);
        hasMoreData = festivalData.isNotEmpty;
        setScreenState(isLoading: false, data: allDate);
      });

      if (upDateData) {
        result.fold((failure) {
          setScreenState(isLoading: false, data: allDate);
        }, (customResponse) {
          final updatedPost =
              ExploreFestivalModel.fromJson(customResponse.response!.data[0]);

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

  String currentFilterQuery = '';

  Future<void> applyFilters(String filterQuery) async {
    currentFilterQuery = filterQuery;

    page = 1;
    allDate.clear();
    hasMoreData = true;

    await fetchExploreFestivalData(filterQuery: filterQuery);
  }

  void init({String? id, String? contentType}) {
    initMentionData(id: id, contentType: contentType);
  }

  void initMentionData({String? id, String? contentType}) {
    if (_isMentionDataInitialized &&
        _currentMentionId == id &&
        _currentContentType == contentType) {
      return;
    }

    _isMentionDataInitialized = true;
    _currentMentionId = id;
    _currentContentType = contentType;

    mentionPage = 1;
    mentionHasMoreData = true;
    allFeedData.clear();

    fetchMentionExplore(id: id, contentType: contentType);
  }

  void refreshMentionData({String? id, String? contentType}) {
    _isMentionDataInitialized = false;
    _currentMentionId = null;
    _currentContentType = null;

    allFeedData.clear();
    mentionHasMoreData = true;
    mentionPage = 1;

    initMentionData(id: id, contentType: contentType);
  }

  Future<void> fetchMentionExplore({
    String? id,
    String? contentType,
    bool loadMoreData = false,
  }) async
  {
    if (!mentionHasMoreData && loadMoreData) return;

    if (state is ExploreFestivalLoaded) {
      final currentState = state as ExploreFestivalLoaded;
      if (currentState.singleFestival != null) {
        setScreenStatePreservingSingleData(
            currentState: currentState,
            isLoading: allFeedData.isEmpty,
            feedData: allFeedData);
      } else {
        setScreenState(isLoading: true, data: allDate);
      }
    } else {
      setScreenState(isLoading: true, data: allDate);
    }

    if (loadMoreData) {
      mentionPage++;
    } else {
      mentionPage = 1;
      allFeedData.clear();
    }

    final result = await exploreRepo.fetchMentionExplore(
      contentType: contentType,
      page: mentionPage,
      id: id,
    );

    result.fold((failure) {
      if (state is ExploreFestivalLoaded) {
        final currentState = state as ExploreFestivalLoaded;
        setScreenStatePreservingSingleData(
            currentState: currentState,
            isLoading: false,
            feedData: allFeedData,
            message: failure.toString());
      } else {
        setScreenState(
            isLoading: false,
            feedData: allFeedData,
            message: failure.toString());
      }
    }, (customResponse) {
      if (!mentionHasMoreData && loadMoreData) return;

      final responseData = customResponse.response?.data;

      if (responseData is Map &&
          responseData.containsKey("detail") &&
          responseData["detail"] == "Invalid page.") {
        mentionHasMoreData = false;
        if (state is ExploreFestivalLoaded) {
          final currentState = state as ExploreFestivalLoaded;
          setScreenStatePreservingSingleData(
              currentState: currentState,
              isLoading: false,
              feedData: allFeedData);
        } else {
          setScreenState(isLoading: false, feedData: allFeedData);
        }
        return;
      }

      if (responseData is List) {
        final data = FeedGetData.fromList(responseData);

        if (!loadMoreData) {
          allFeedData.clear();
        }

        allFeedData.addAll(data);
        mentionHasMoreData = data.isNotEmpty;

        if (state is ExploreFestivalLoaded) {
          final currentState = state as ExploreFestivalLoaded;
          setScreenStatePreservingSingleData(
              currentState: currentState,
              isLoading: false,
              feedData: allFeedData);
        } else {
          setScreenState(isLoading: false, feedData: allFeedData);
        }
      } else {
        Logger.log("Unexpected response format: $responseData");
        if (state is ExploreFestivalLoaded) {
          final currentState = state as ExploreFestivalLoaded;
          setScreenStatePreservingSingleData(
              currentState: currentState,
              isLoading: false,
              feedData: allFeedData,
              message: "Invalid response format");
        } else {
          setScreenState(isLoading: false, message: "Invalid response format");
        }
      }
    });
  }

  void setScreenStatePreservingSingleData({
    required ExploreFestivalLoaded currentState,
    required bool isLoading,
    List<FeedGetData>? feedData,
    String? message,
  }) {
    emit(ExploreFestivalLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      feedData: feedData,
      exploreFestivalList: currentState.exploreFestivalList,
      singleFestival: currentState.singleFestival,
      festivalFilter: currentState.festivalFilter,
      hasError: message != null,
      currentPage: currentState.currentPage,
    ));
  }

  feedPostDelete(id) {}

  feedPostSaved(id, save) {}

  feedPostLike2(id, isLiked, ctx) {}

  Future<void> fetchSingleFestivalData( String id) async {
    setScreenState(isLoading: true);
    final result = await exploreRepo.fetchSingleFestivalData(id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = SingleFestivalModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, singleFestival: data, data: allDate);
    });

  }

  void resetMentionData() {
    _isMentionDataInitialized = false;
    _currentMentionId = null;
    _currentContentType = null;
    allFeedData.clear();
    mentionHasMoreData = true;
    mentionPage = 1;
  }

  Future<void> fetchFestivalFilterData() async {
    setScreenState(isLoading: true);

    final result = await exploreRepo.fetchFestivalFilterData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (data) {
      final filterData = FestivalFilterModel.fromJson(data.response?.data);
      setScreenState(isLoading: false, festivalFilter: filterData);
    });
  }

  Future<void> changeViewStatus(
      String id,
      ) async
  {
    try {
      final result = await exploreRepo.changeViewStatus(id, 'true', 'Festival');
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
      if (state is! ExploreFestivalLoaded) return;
      final currentState = state as ExploreFestivalLoaded;

      // Update UI optimistically (immediately without API call)
      List<ExploreFestivalModel> updatedList = [];

      for (var item in (currentState.exploreFestivalList ?? [])) {
        if (item.id.toString() == itemId) {
          // Create updated item with new like status
          var updatedItem = ExploreFestivalModel(
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
      emit(ExploreFestivalLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreFestivalList: updatedList,
        singleFestival: currentState.singleFestival,
        // templeFilterModel: currentState.templeFilterModel,
        festivalFilter: currentState.festivalFilter,
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

  Future<void> _syncLikeStatusWithServer(
      String itemId,
      String status,
      List<ExploreFestivalModel> currentList,
      ExploreFestivalLoaded currentState
      ) async {
    try {
      final result = await exploreRepo.changeLikeStatus(itemId, status, 'Festival');

      result.fold(
            (failure) {
          // Optionally revert changes if server sync fails
          print("Server sync failed: ${failure.toString()}");
          // You can choose to revert the UI changes here if needed
        },
            (success) {
          // Server sync successful - no UI update needed as we already updated optimistically
          print("Server sync successful");

          // Optionally update with server response if you want to ensure data consistency
          // final rawData = success.response?.data;
          // if (rawData is Map<String, dynamic> && rawData['data'] != null) {
          //   // Update with server data if needed
          // }
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
      if (state is! ExploreFestivalLoaded) return;
      final currentState = state as ExploreFestivalLoaded;

      List<ExploreFestivalModel> updatedList = [];

      for (var item in (currentState.exploreFestivalList ?? [])) {
        if (item.id.toString() == itemId) {
          var updatedItem = ExploreFestivalModel(
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
      emit(ExploreFestivalLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreFestivalList: updatedList,
        // exploreDevotees: currentState.exploreDevotees,
        singleFestival: currentState.singleFestival,
        // templeFilterModel: currentState.templeFilterModel,
        festivalFilter: currentState.festivalFilter,
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
      List<ExploreFestivalModel> currentList,
      ExploreFestivalLoaded currentState
      ) async {
    try {
      final result = await exploreRepo.changeSavedStatus(itemId, status, 'Festival');

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
    final result = await exploreRepo.changeLikeStatus(id!, status!, 'Festival');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Festival liked successfully");

        final rawData = success.response?.data["data"];
        final updatedItem = SingleFestivalModel.fromJson(rawData);
        List<ExploreFestivalModel> updatedList = allDate.map((post) {
          if (post.id.toString() == id) {
            return ExploreFestivalModel.fromJson(rawData);
          }
          return post;
        }).toList();
        setScreenState(
          isLoading: false,
          data: updatedList,
          singleFestival: updatedItem,
        );
      },
    );
  }

  Future<void> changeSingleSavedStatus(String? id, String? status) async {
    final result = await exploreRepo.changeSavedStatus(id!, status!, 'Festival');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Festival liked successfully");

        final rawData = success.response?.data["data"];
        final updatedItem = SingleFestivalModel.fromJson(rawData);
        List<ExploreFestivalModel> updatedList = allDate.map((post) {
          if (post.id.toString() == id) {
            return ExploreFestivalModel.fromJson(rawData);
          }
          return post;
        }).toList();
        setScreenState(
          isLoading: false,
          data: updatedList,
          singleFestival: updatedItem,
        );
      },
    );
  }

  void setScreenState(
      {List<ExploreFestivalModel>? data,
        List<FeedGetData>? feedData,
      SingleFestivalModel? singleFestival,
      FestivalFilterModel? festivalFilter,
      required bool isLoading,
      String? message,
      bool hasError = false}) {
    emit(ExploreFestivalLoaded(
        loadingState: isLoading,
        feedData: feedData,
        errorMessage: message ?? '',
        exploreFestivalList: data,
        singleFestival: singleFestival,
        festivalFilter: festivalFilter,
        hasError: hasError,
        currentPage: page));
  }
}
