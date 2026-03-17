import 'dart:math';
import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/explore/explore_event/explore_event_state.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/explore/explore_event_model.dart';
import 'package:devalay_app/src/data/model/explore/filter/event_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/single_event_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/router/router.dart';
import '../../../data/model/feed/feed_home_model.dart';
import '../../../domain/repo_impl/feed_repo.dart';

class ExploreEventCubit extends Cubit<ExploreEventState> {
  ExploreEventCubit()
      : exploreRepo = getIt<ExploreRepo>(),
        feedHomeRepo = getIt<FeedHomeRepo>(),
        super(ExploreEventInitial());

  ExploreRepo exploreRepo;
  final FeedHomeRepo feedHomeRepo;
  List<ExploreEventModel> eventData = [];
  List<FeedGetData> allFeedData = [];
  bool _isMentionDataInitialized = false;
  FeedGetData? singleFeed;
  final bool _isInitializingMention = false;
  int page = 1;
  bool hasMoreData = true;

  int selectedFilter = 0;
  final List<String> filterTypes = [
    StringConstant.location,
    StringConstant.date,
    StringConstant.sortBy,
    StringConstant.orderBy
  ];
  final List<String> sortBy = [
    "Likes",
    StringConstant.addedDate,
    StringConstant.alphabetically
  ];
  final List orderBy = [
    {
      'title': StringConstant.decending,
      'icon':
          'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/decending.svg'
    },
    {
      'title': StringConstant.ascending,
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
  String? selectedDevIndex;
  String searchQuery = '';
  String? selectedSortByIndex = "Likes";
  String? selectedOrderByIndex = StringConstant.decending;
  Map<String, dynamic> selectedLocationFilterMap = {};
  Map<String, dynamic> selectedDevFilterMap = {};
  final CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;

  bool _isFetchingMentionData = false;
  int mentionPage = 1;
  bool mentionHasMoreData = true;
  bool _isMentionInitialized = false;
  String? _currentMentionId;
  String? _currentContentType;
  String currentFilterQuery = '';

  final Set<String> _initializingIds = <String>{};

  Future<void> fetchExploreEventData({
    bool loadMoreData = false,
    bool upDateData = false,
  }) async {
    try {
      if (!hasMoreData && loadMoreData) return;
      upDateData ? null : setScreenState(isLoading: true, data: eventData);
      if (loadMoreData) {
        page++;
      } else {
        page = 1;
        eventData.clear();
      }

      final result = await exploreRepo.setTemplesFilter(
          '${AppConstant.exploreSingleEvent}/?page=$page&limit=10$currentFilterQuery');

      result.fold((failure) {
        hasMoreData = false;
        setScreenState(isLoading: false, data: eventData);
        Logger.log("this is ${failure.toString()}");
        return;
      }, (customResponse) {
        if (customResponse.response!.data is Map &&
            customResponse.response!.data.containsKey("detail") &&
            customResponse.response!.data["detail"] == "Invalid page.") {
          hasMoreData = false;
          setScreenState(isLoading: false, data: eventData);
          return;
        }
        final data = (customResponse.response?.data as List)
            .map((x) => ExploreEventModel.fromJson(x))
            .toList();
        eventData.addAll(data);
        hasMoreData = data.isNotEmpty;
        setScreenState(isLoading: false, data: eventData);
      });

      if (upDateData) {
        result.fold((failure) {
          setScreenState(isLoading: false, data: eventData);
        }, (customResponse) {
          final updatedPost =
              ExploreEventModel.fromJson(customResponse.response!.data[0]);

          final updatedList = eventData.map((post) {
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
      setScreenState(isLoading: false, data: eventData);
    }
  }

  Future<void> applyFilters(String filterQuery) async {
    currentFilterQuery = filterQuery;

    page = 1;
    eventData.clear();
    hasMoreData = true;

    await fetchExploreEventData();
  }

  Future<void> fetchSingleEventData(String id) async {
    setScreenState(isLoading: true);
    final result = await exploreRepo.fetchSingleEventData(id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = SingleEventModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, singleEvent: data, data: eventData);
    });
  }

  Future<void> fetchEventFilterData() async {
    setScreenState(isLoading: true);
    final result = await exploreRepo.fetchEventFilterData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (data) {
      final filterData = EventFilterModel.fromJson(data.response?.data);
      setScreenState(isLoading: false, filterData: filterData);
    });
  }

  Future<void> changeViewStatus(
    String id,
  ) async {
    try {
      final result = await exploreRepo.changeViewStatus(id, 'true', 'Event');
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
      if (state is! ExploreEventLoaded) return;
      final currentState = state as ExploreEventLoaded;

      List<ExploreEventModel> updatedList = [];

      for (var item in (currentState.exploreEventList ?? [])) {
        if (item.id.toString() == itemId) {
          var updatedItem = ExploreEventModel(
            id: item.id,
            title: item.title,
            images: item.images,
            dates: item.dates,
            city: item.city,
            liked: newLikedState,
            viewedCount: item.viewedCount,
            saved: item.saved, // Keep existing saved status
            likedCount: newLikedState
                ? (item.likedCount ?? 0) + 1
                : max((item.likedCount ?? 0) - 1, 0),
            savedCount: item.savedCount, // Keep existing saved count
          );
          updatedList.add(updatedItem);
        } else {
          updatedList.add(item);
        }
      }

      eventData = updatedList;

      emit(ExploreEventLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreEventList: updatedList,
        singleEvent: currentState.singleEvent,
        eventFilter: currentState.eventFilter,
        feedData: currentState.feedData,
      ));

      _syncLikeStatusWithServer(itemId, status, updatedList, currentState);
    } catch (e) {
      print("Error in changeLikeStatus: ${e.toString()}");
    }
  }

  Future<void> _syncLikeStatusWithServer(
      String itemId,
      String status,
      List<ExploreEventModel> currentList,
      ExploreEventLoaded currentState) async {
    try {
      final result =
          await exploreRepo.changeLikeStatus(itemId, status, 'Event');

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

  Future<void> changeSavedStatus(String? id, String? status) async {
    if (id == null || status == null) return;

    final String itemId = id.toString();
    final bool newSavedState = status.toLowerCase() == 'true';

    try {
      if (state is! ExploreEventLoaded) return;
      final currentState = state as ExploreEventLoaded;

      List<ExploreEventModel> updatedList = [];

      for (var item in (currentState.exploreEventList ?? [])) {
        if (item.id.toString() == itemId) {
          var updatedItem = ExploreEventModel(
            id: item.id,
            title: item.title,
            images: item.images,
            dates: item.dates,
            city: item.city,
            liked: item.liked,
            saved: newSavedState,
            likedCount: item.likedCount,
            viewedCount: item.viewedCount,
            savedCount: newSavedState
                ? (item.savedCount ?? 0) + 1
                : max((item.savedCount ?? 0) - 1, 0),
          );
          updatedList.add(updatedItem);
        } else {
          updatedList.add(item);
        }
      }
      eventData = updatedList;
      emit(ExploreEventLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreEventList: updatedList,
        singleEvent: currentState.singleEvent,
        eventFilter: currentState.eventFilter,
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
      List<ExploreEventModel> currentList,
      ExploreEventLoaded currentState) async {
    try {
      final result =
          await exploreRepo.changeSavedStatus(itemId, status, 'Event');

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
    final result = await exploreRepo.changeLikeStatus(id!, status!, 'Event');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Event liked successfully");
        final rawData = success.response?.data;

        if (rawData is Map<String, dynamic> && rawData['data'] != null) {
          final updatedItem = SingleEventModel.fromJson(rawData['data']);
          List<ExploreEventModel> updatedList = eventData.map((post) {
            if (post.id.toString() == id) {
              return ExploreEventModel.fromJson(rawData['data']);
            }
            return post;
          }).toList();

          setScreenState(
            isLoading: false,
            data: updatedList,
            singleEvent: updatedItem,
          );
        } else {
          setScreenState(isLoading: false, message: "Invalid response format");
        }
      },
    );
  }

  Future<void> changeSingleSavedStatus(String? id, String? status) async {
    final result = await exploreRepo.changeSavedStatus(id!, status!, 'Event');
    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: "Event saved successfully");
        final rawData = success.response?.data;

        if (rawData is Map<String, dynamic> && rawData['data'] != null) {
          final updatedItem = SingleEventModel.fromJson(rawData['data']);
          List<ExploreEventModel> updatedList = eventData.map((post) {
            if (post.id.toString() == id) {
              return ExploreEventModel.fromJson(rawData['data']);
            }
            return post;
          }).toList();

          setScreenState(
            isLoading: false,
            data: updatedList,
            singleEvent: updatedItem,
          );
        } else {
          setScreenState(isLoading: false, message: "Invalid response format");
        }
      },
    );
  }

  Future<void> loadMoreMentionData() async {
    if (!mentionHasMoreData || _isFetchingMentionData) return;

    await fetchMentionExplore(
      id: _currentMentionId,
      contentType: _currentContentType,
      loadMoreData: true,
    );
  }

  void _resetMentionState() {
    _isMentionInitialized = false;
    _currentMentionId = null;
    _currentContentType = null;
    allFeedData.clear();
    mentionHasMoreData = true;
    mentionPage = 1;
    _isFetchingMentionData = false;
    _initializingIds.clear();
  }

  void resetMentionData() {
    _isMentionDataInitialized = false;
    _currentMentionId = null;
    _currentContentType = null;
    allFeedData.clear();
    mentionHasMoreData = true;
    mentionPage = 1;
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

  bool get isRefreshing => _isInitializingMention || _isFetchingMentionData;

  Future<void> fetchMentionExplore({
    String? id,
    String? contentType,
    bool loadMoreData = false,
  }) async {
    if (!mentionHasMoreData && loadMoreData) return;

    if (state is ExploreEventLoaded) {
      final currentState = state as ExploreEventLoaded;
      if (currentState.singleEvent != null) {
        setScreenStatePreservingSingleData(
            currentState: currentState,
            isLoading: allFeedData.isEmpty,
            feedData: allFeedData);
      } else {
        setScreenState(isLoading: true, data: eventData);
      }
    } else {
      setScreenState(isLoading: true, data: eventData);
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
      if (state is ExploreEventLoaded) {
        final currentState = state as ExploreEventLoaded;
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
        if (state is ExploreEventLoaded) {
          final currentState = state as ExploreEventLoaded;
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

        if (state is ExploreEventLoaded) {
          final currentState = state as ExploreEventLoaded;
          setScreenStatePreservingSingleData(
              currentState: currentState,
              isLoading: false,
              feedData: allFeedData);
        } else {
          setScreenState(isLoading: false, feedData: allFeedData);
        }
      } else {
        Logger.log("Unexpected response format: $responseData");
        if (state is ExploreEventLoaded) {
          final currentState = state as ExploreEventLoaded;
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

  Future<void> feedPostSaved(String postId, bool isSave) async {
    try {
      final currentState = state;
      FeedGetData? singleFeedData;

      if (currentState is ExploreEventLoaded &&
          currentState.singleFeed != null) {
        singleFeedData = currentState.singleFeed;
      }

      final List<FeedGetData> updatedList = List.from(allFeedData);
      final index =
          updatedList.indexWhere((post) => post.id.toString() == postId);

      if (index != -1) {
        final oldPost = updatedList[index];
        updatedList[index] = oldPost.copyWith(saved: isSave);
        allFeedData = updatedList;
      }

      if (singleFeedData != null && singleFeedData.id.toString() == postId) {
        singleFeedData = singleFeedData.copyWith(saved: isSave);
      }

      if (currentState is ExploreEventLoaded) {
        emit(ExploreEventLoaded(
            loadingState: false,
            errorMessage: currentState.errorMessage,
            feedData: updatedList,
            singleFeed: singleFeedData,
            exploreEventList: currentState.exploreEventList,
            singleEvent: currentState.singleEvent,
            eventFilter: currentState.eventFilter));
      }

      AppRouter.pop();

      final result =
          await feedHomeRepo.feedPostSavedData(postId, isSave.toString());

      result.fold(
        (failure) {
          Logger.log("Save failed: ${failure.toString()}");

          final List<FeedGetData> revertList = List.from(allFeedData);
          final revertIndex =
              revertList.indexWhere((post) => post.id.toString() == postId);

          FeedGetData? revertSingleFeed = singleFeedData;

          if (revertIndex != -1) {
            final oldPost = revertList[revertIndex];
            revertList[revertIndex] = oldPost.copyWith(saved: !isSave);
          }

          if (revertSingleFeed != null &&
              revertSingleFeed.id.toString() == postId) {
            revertSingleFeed = revertSingleFeed.copyWith(saved: !isSave);
          }

          allFeedData = revertList;

          if (currentState is ExploreEventLoaded) {
            emit(ExploreEventLoaded(
                loadingState: false,
                errorMessage: "Failed to update save status",
                feedData: revertList,
                singleFeed: revertSingleFeed,
                exploreEventList: currentState.exploreEventList,
                singleEvent: currentState.singleEvent,
                eventFilter: currentState.eventFilter));
          }
        },
        (customResponse) async {
          final updatedPost =
              FeedGetData.fromJson(customResponse.response!.data);
          final serverUpdatedList = allFeedData.map((post) {
            if (post.id.toString() == postId) {
              return updatedPost;
            }
            return post;
          }).toList();

          FeedGetData? updatedSingleFeed = singleFeedData;
          if (updatedSingleFeed != null &&
              updatedSingleFeed.id.toString() == postId) {
            updatedSingleFeed = updatedPost;
          }
          allFeedData = serverUpdatedList;

          if (currentState is ExploreEventLoaded) {
            emit(ExploreEventLoaded(
                loadingState: false,
                errorMessage: '',
                feedData: serverUpdatedList,
                singleFeed: updatedSingleFeed,
                exploreEventList: currentState.exploreEventList,
                singleEvent: currentState.singleEvent,
                eventFilter: currentState.eventFilter));
          }
        },
      );
    } catch (e) {
      Logger.log("Save operation failed: ${e.toString()}");
      final currentState = state;
      if (currentState is ExploreEventLoaded) {
        emit(ExploreEventLoaded(
            loadingState: false,
            errorMessage: "An error occurred",
            feedData: currentState.feedData,
            singleFeed: currentState.singleFeed,
            exploreEventList: currentState.exploreEventList,
            singleEvent: currentState.singleEvent,
            eventFilter: currentState.eventFilter));
      }
    }
  }

  Future<void> feedPostLike2(
      String postId, bool isLike, BuildContext context) async {
    try {
      final currentState = state;
      FeedGetData? singleFeedData;

      if (currentState is ExploreEventLoaded &&
          currentState.singleFeed != null) {
        singleFeedData = currentState.singleFeed;
      }

      final List<FeedGetData> updatedList = List.from(allFeedData);
      final index =
          updatedList.indexWhere((post) => post.id.toString() == postId);

      if (index != -1) {
        final oldPost = updatedList[index];
        final newLikeCount = isLike
            ? (oldPost.likedCount ?? 0) + 1
            : (oldPost.likedCount ?? 0) - 1;

        updatedList[index] = oldPost.copyWith(
          liked: isLike,
          likedCount: newLikeCount < 0 ? 0 : newLikeCount,
        );

        allFeedData = updatedList;
      }

      if (singleFeedData != null && singleFeedData.id.toString() == postId) {
        final newLikeCount = isLike
            ? (singleFeedData.likedCount ?? 0) + 1
            : (singleFeedData.likedCount ?? 0) - 1;

        singleFeedData = singleFeedData.copyWith(
          liked: isLike,
          likedCount: newLikeCount < 0 ? 0 : newLikeCount,
        );
      }

      if (currentState is ExploreEventLoaded) {
        emit(ExploreEventLoaded(
          loadingState: false,
          errorMessage: currentState.errorMessage,
          hasError: currentState.hasError,
          feedData: updatedList,
          singleFeed: singleFeedData,
          singleEvent: currentState.singleEvent,
          exploreEventList: currentState.exploreEventList,
          eventFilter: currentState.eventFilter,
        ));
      }

      final result =
          await feedHomeRepo.feedPostLikeData(postId, isLike.toString());

      result.fold((failure) {
        final List<FeedGetData> revertList = List.from(allFeedData);
        final revertIndex =
            revertList.indexWhere((post) => post.id.toString() == postId);

        FeedGetData? revertSingleFeed = singleFeedData;

        if (revertIndex != -1) {
          final currentPost = revertList[revertIndex];
          final originalLikeCount = isLike
              ? (currentPost.likedCount ?? 0) - 1
              : (currentPost.likedCount ?? 0) + 1;

          revertList[revertIndex] = currentPost.copyWith(
            liked: !isLike,
            likedCount: originalLikeCount < 0 ? 0 : originalLikeCount,
          );
        }

        if (revertSingleFeed != null &&
            revertSingleFeed.id.toString() == postId) {
          final originalLikeCount = isLike
              ? (revertSingleFeed.likedCount ?? 0) - 1
              : (revertSingleFeed.likedCount ?? 0) + 1;

          revertSingleFeed = revertSingleFeed.copyWith(
            liked: !isLike,
            likedCount: originalLikeCount < 0 ? 0 : originalLikeCount,
          );
        }

        allFeedData = revertList;

        if (currentState is ExploreEventLoaded) {
          emit(ExploreEventLoaded(
            loadingState: false,
            errorMessage: "Failed to update like status",
            hasError: true,
            feedData: revertList,
            singleFeed: revertSingleFeed,
            singleEvent: currentState.singleEvent,
            exploreEventList: currentState.exploreEventList,
            eventFilter: currentState.eventFilter,
          ));
        }
      }, (customResponse) async {
        final apiData = FeedGetData.fromJson(customResponse.response!.data);
        final List<FeedGetData> serverUpdatedList = List.from(allFeedData);
        final serverIndex = serverUpdatedList
            .indexWhere((post) => post.id.toString() == postId);

        FeedGetData? updatedSingleFeed = singleFeedData;

        if (serverIndex != -1) {
          final oldPost = serverUpdatedList[serverIndex];
          serverUpdatedList[serverIndex] = oldPost.copyWith(
              liked: apiData.liked,
              likedCount: apiData.likedCount,
              commentsCount: apiData.commentsCount);
        }

        if (updatedSingleFeed != null &&
            updatedSingleFeed.id.toString() == postId) {
          updatedSingleFeed = updatedSingleFeed.copyWith(
              liked: apiData.liked,
              likedCount: apiData.likedCount,
              commentsCount: apiData.commentsCount);
        }

        allFeedData = serverUpdatedList;

        if (currentState is ExploreEventLoaded) {
          emit(ExploreEventLoaded(
            loadingState: false,
            errorMessage: '',
            hasError: false,
            feedData: serverUpdatedList,
            singleFeed: updatedSingleFeed,
            singleEvent: currentState.singleEvent,
            exploreEventList: currentState.exploreEventList,
            eventFilter: currentState.eventFilter,
          ));
        }
      });
    } catch (e) {
      Logger.log("Like operation failed: ${e.toString()}");

      final currentState = state;
      if (currentState is ExploreEventLoaded) {
        emit(ExploreEventLoaded(
          loadingState: false,
          errorMessage: "An error occurred",
          hasError: true,
          feedData: currentState.feedData,
          singleFeed: currentState.singleFeed,
          singleEvent: currentState.singleEvent,
          exploreEventList: currentState.exploreEventList,
          eventFilter: currentState.eventFilter,
        ));
      }
    }
  }

  void feedPostDelete(postId) {
    try {
      final currentState = state;
      final List<FeedGetData> updatedList = List.from(allFeedData);
      updatedList.removeWhere((post) => post.id.toString() == postId);
      allFeedData = updatedList;

      if (currentState is ExploreEventLoaded) {
        emit(ExploreEventLoaded(
            loadingState: false,
            errorMessage: currentState.errorMessage,
            feedData: updatedList,
            singleFeed: currentState.singleFeed,
            exploreEventList: currentState.exploreEventList,
            singleEvent: currentState.singleEvent,
            eventFilter: currentState.eventFilter));
      }
    } catch (e) {
      Logger.log("Delete operation failed: ${e.toString()}");
    }
  }

  bool get isFetchingMentionData => _isFetchingMentionData;
  bool get isMentionInitialized => _isMentionInitialized;
  List<FeedGetData> get currentMentionData => List.unmodifiable(allFeedData);

  void setScreenStatePreservingSingleData({
    required ExploreEventLoaded currentState,
    required bool isLoading,
    List<FeedGetData>? feedData,
    String? message,
  }) {
    emit(ExploreEventLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      feedData: feedData,
      exploreEventList: currentState.exploreEventList,
      singleEvent: currentState.singleEvent,
      eventFilter: currentState.eventFilter,
      singleFeed: currentState.singleFeed,
    ));
  }

  void setScreenState({
    List<ExploreEventModel>? data,
    List<FeedGetData>? feedData,
    SingleEventModel? singleEvent,
    EventFilterModel? filterData,
    required bool isLoading,
    String? message,
  }) {
    final currentState = state;
    if (currentState is ExploreEventLoaded &&
        currentState.loadingState == isLoading &&
        currentState.errorMessage == (message ?? '') &&
        currentState.feedData == feedData &&
        currentState.exploreEventList == data &&
        currentState.singleEvent == singleEvent &&
        currentState.eventFilter == filterData) {
      return;
    }

    emit(ExploreEventLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      exploreEventList: data,
      feedData: feedData,
      singleEvent: singleEvent,
      eventFilter: filterData,
    ));
  }
}
