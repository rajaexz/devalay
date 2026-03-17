import 'dart:math';
import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_state.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/explore/explore_devalay_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_devotees_model.dart';
import 'package:devalay_app/src/data/model/explore/filter/temple_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/single_devalay_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/router/router.dart';
import '../../../domain/repo_impl/feed_repo.dart';

class ExploreDevalayCubit extends Cubit<ExploreDevalayState> {
  ExploreDevalayCubit()
      : exploreRepo = getIt<ExploreRepo>(),
        feedHomeRepo = getIt<FeedHomeRepo>(),
        super(ExploreDevalayInitial());
  final TextEditingController scerchProfileController = TextEditingController();
  ExploreRepo exploreRepo;
  final FeedHomeRepo feedHomeRepo;
  int page = 1;
  bool hasMoreData = true;
  List<ExploreDevalayModel> allDate = [];
  List<FeedGetData> allFeedData = [];
  List<ExploreUser> allDevotees = [];
  bool _isMentionDataInitialized = false;
  String? _currentMentionId;
  String? _currentContentType;
  int mentionPage = 1;
  bool mentionHasMoreData = true;
  String currentFilterQuery = '';
  int selectedFilter = 0;
  String searchQuery = '';
  String? selectedLocationIndex;
  String? selectedDevIndex;
  String? selectedSortByIndex = "likes";
  String? selectedOrderByIndex = StringConstant.decending;
  Map<String, dynamic> selectedLocationFilterMap = {};
  Map<String, dynamic> selectedDevFilterMap = {};
  final List<String> queryParams = [];
  String filterQuery = '';
  final FocusNode focusNode = FocusNode();

  final TextEditingController searchLocationController =
      TextEditingController();
  final TextEditingController searchDevController = TextEditingController();
  final List<String> filterTypes = [
    StringConstant.location,
    StringConstant.dev,
    StringConstant.sortBy,
    StringConstant.orderBy
  ];
  final List<String> sortBy = [
    "Likes",
    StringConstant.addedDate,
    StringConstant.alphabetically
  ];
  final List<Map<String, dynamic>> orderBy = [
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

  void resetMentionData() {
    _isMentionDataInitialized = false;
    _currentMentionId = null;
    _currentContentType = null;
    allFeedData.clear();
    mentionHasMoreData = true;
    mentionPage = 1;
  }

  void clearFilters() {
    selectedLocationIndex = null;
    selectedDevIndex = null;
    selectedSortByIndex = 'Likes';
    selectedOrderByIndex = 'Descending';
    selectedLocationFilterMap = {};
    selectedDevFilterMap = {};
    searchLocationController.clear();
    searchDevController.clear();

    setScreenState(isLoading: false, data: allDate);
  }

  void updateSearchQuery(String value) {
    searchQuery = value;
    setScreenState(isLoading: false, data: allDate);
  }

  Future<void> fetchMentionExplore({
    String? id,
    String? contentType,
    bool loadMoreData = false,
  }) async {
    if (!mentionHasMoreData && loadMoreData) return;

    if (state is ExploreDevalayLoaded) {
      final currentState = state as ExploreDevalayLoaded;
      if (currentState.singleDevalay != null) {
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
      if (state is ExploreDevalayLoaded) {
        final currentState = state as ExploreDevalayLoaded;
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
        if (state is ExploreDevalayLoaded) {
          final currentState = state as ExploreDevalayLoaded;
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

        if (state is ExploreDevalayLoaded) {
          final currentState = state as ExploreDevalayLoaded;
          setScreenStatePreservingSingleData(
              currentState: currentState,
              isLoading: false,
              feedData: allFeedData);
        } else {
          setScreenState(isLoading: false, feedData: allFeedData);
        }
      } else {
        Logger.log("Unexpected response format: $responseData");
        if (state is ExploreDevalayLoaded) {
          final currentState = state as ExploreDevalayLoaded;
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
    required ExploreDevalayLoaded currentState,
    required bool isLoading,
    List<FeedGetData>? feedData,
    String? message,
  }) {
    emit(ExploreDevalayLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      feedData: feedData,
      exploreDevalayList: currentState.exploreDevalayList,
      exploreDevotees: currentState.exploreDevotees,
      singleDevalay: currentState.singleDevalay,
      templeFilterModel: currentState.templeFilterModel,
      selectedFilter: currentState.selectedFilter,
      hasError: message != null,
      currentPage: currentState.currentPage,
    ));
  }

  feedPostDelete(id) {}

  Future<void> feedPostSaved(String postId, bool isSave) async {
    try {
      final currentState = state;
      FeedGetData? singleFeedData;

      if (currentState is ExploreDevalayLoaded &&
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

      if (currentState is ExploreDevalayLoaded) {
        emit(ExploreDevalayLoaded(
            loadingState: false,
            errorMessage: currentState.errorMessage,
            hasError: currentState.hasError,
            feedData: updatedList,
            singleFeed: singleFeedData,
            singleDevalay: currentState.singleDevalay, // Added this line
            exploreDevalayList: currentState.exploreDevalayList, // Added this line
            exploreDevotees: currentState.exploreDevotees, // Added this line
            templeFilterModel: currentState.templeFilterModel, // Added this line
            selectedFilter: currentState.selectedFilter, // Added this line
            currentPage: currentState.currentPage
        ));
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

          if (currentState is ExploreDevalayLoaded) {
            emit(ExploreDevalayLoaded(
                loadingState: false,
                errorMessage: "Failed to update save status",
                hasError: true,
                feedData: revertList,
                singleFeed: revertSingleFeed,
                singleDevalay: currentState.singleDevalay, // Added this line
                exploreDevalayList: currentState.exploreDevalayList, // Added this line
                exploreDevotees: currentState.exploreDevotees, // Added this line
                templeFilterModel: currentState.templeFilterModel, // Added this line
                selectedFilter: currentState.selectedFilter, // Added this line
                currentPage: currentState.currentPage
            ));
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

          if (currentState is ExploreDevalayLoaded) {
            emit(ExploreDevalayLoaded(
                loadingState: false,
                errorMessage: '',
                hasError: false,
                feedData: serverUpdatedList,
                singleFeed: updatedSingleFeed,
                singleDevalay: currentState.singleDevalay, // Added this line
                exploreDevalayList: currentState.exploreDevalayList, // Added this line
                exploreDevotees: currentState.exploreDevotees, // Added this line
                templeFilterModel: currentState.templeFilterModel, // Added this line
                selectedFilter: currentState.selectedFilter, // Added this line
                currentPage: currentState.currentPage
            ));
          }
        },
      );
    } catch (e) {
      Logger.log("Save operation failed: ${e.toString()}");
      final currentState = state;
      if (currentState is ExploreDevalayLoaded) {
        emit(ExploreDevalayLoaded(
            loadingState: false,
            errorMessage: "An error occurred",
            hasError: true,
            feedData: currentState.feedData,
            singleFeed: currentState.singleFeed,
            singleDevalay: currentState.singleDevalay, // Added this line
            exploreDevalayList: currentState.exploreDevalayList, // Added this line
            exploreDevotees: currentState.exploreDevotees, // Added this line
            templeFilterModel: currentState.templeFilterModel, // Added this line
            selectedFilter: currentState.selectedFilter, // Added this line
            currentPage: currentState.currentPage
        ));
      }
    }
  }

  Future<void> feedPostLike2(
      String postId, bool isLike, BuildContext context) async {
    try {
      final currentState = state;
      FeedGetData? singleFeedData;

      if (currentState is ExploreDevalayLoaded &&
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

      if (currentState is ExploreDevalayLoaded) {
        emit(ExploreDevalayLoaded(
            loadingState: false,
            errorMessage: currentState.errorMessage,
            hasError: currentState.hasError,
            feedData: updatedList,
            singleFeed: singleFeedData,
            singleDevalay: currentState.singleDevalay, // Added this line
            exploreDevalayList: currentState.exploreDevalayList, // Added this line
            exploreDevotees: currentState.exploreDevotees, // Added this line
            templeFilterModel: currentState.templeFilterModel, // Added this line
            selectedFilter: currentState.selectedFilter, // Added this line
            currentPage: currentState.currentPage // Added this line
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

        if (currentState is ExploreDevalayLoaded) {
          emit(ExploreDevalayLoaded(
              loadingState: false,
              errorMessage: "Failed to update like status",
              hasError: true,
              feedData: revertList,
              singleFeed: revertSingleFeed,
              singleDevalay: currentState.singleDevalay, // Added this line
              exploreDevalayList: currentState.exploreDevalayList, // Added this line
              exploreDevotees: currentState.exploreDevotees, // Added this line
              templeFilterModel: currentState.templeFilterModel, // Added this line
              selectedFilter: currentState.selectedFilter, // Added this line
              currentPage: currentState.currentPage // Added this line
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

        if (currentState is ExploreDevalayLoaded) {
          emit(ExploreDevalayLoaded(
              loadingState: false,
              errorMessage: '',
              hasError: false,
              feedData: serverUpdatedList,
              singleFeed: updatedSingleFeed,
              singleDevalay: currentState.singleDevalay, // Added this line
              exploreDevalayList: currentState.exploreDevalayList, // Added this line
              exploreDevotees: currentState.exploreDevotees, // Added this line
              templeFilterModel: currentState.templeFilterModel, // Added this line
              selectedFilter: currentState.selectedFilter, // Added this line
              currentPage: currentState.currentPage // Added this line
          ));
        }
      });
    } catch (e) {
      Logger.log("Like operation failed: ${e.toString()}");

      final currentState = state;
      if (currentState is ExploreDevalayLoaded) {
        emit(ExploreDevalayLoaded(
            loadingState: false,
            errorMessage: "An error occurred",
            hasError: true,
            feedData: currentState.feedData,
            singleFeed: currentState.singleFeed,
            singleDevalay: currentState.singleDevalay, 
            exploreDevalayList: currentState.exploreDevalayList, 
            exploreDevotees: currentState.exploreDevotees, 
            templeFilterModel: currentState.templeFilterModel,
            selectedFilter: currentState.selectedFilter, 
            currentPage: currentState.currentPage
        ));
      }
    }
  }
String buildFilterQuery() {
  queryParams.clear();

  // Location filter
  if (selectedLocationFilterMap.isNotEmpty) {
    final city = selectedLocationFilterMap['city'];
    final state = selectedLocationFilterMap['state'];
    final country = selectedLocationFilterMap['country'];

    // Add debug print to check values
    debugPrint('Selected Location Map: $selectedLocationFilterMap');
    debugPrint('City: $city, State: $state, Country: $country');

    if (city != null && city.toString().isNotEmpty) {
      queryParams.add('&city=${Uri.encodeComponent(city.toString())}');
    }
    if (state != null && state.toString().isNotEmpty) {
      queryParams.add('&state=${Uri.encodeComponent(state.toString())}');
    }
    if (country != null && country.toString().isNotEmpty) {
      queryParams.add('&country=${Uri.encodeComponent(country.toString())}');
    }
  }

  // Dev filter
  if (selectedDevFilterMap.isNotEmpty) {
    final devId = selectedDevFilterMap['dev'];
    debugPrint('Selected Dev Map: $selectedDevFilterMap');
    debugPrint('Dev ID: $devId');
    
    if (devId != null && devId.toString().isNotEmpty) {
      queryParams.add('&dev=${Uri.encodeComponent(devId.toString())}');
    }
  }

  // Sort By filter
  if (selectedSortByIndex != null && selectedSortByIndex!.isNotEmpty) {
    String sortBy = selectedSortByIndex!.toLowerCase();
    if (sortBy == 'added date') sortBy = 'recent';
    if (sortBy == 'alphabetically') sortBy = 'alphabetically';
    queryParams.add('&sort_by=$sortBy');
  }

  // Order By filter
  if (selectedOrderByIndex != null && selectedOrderByIndex!.isNotEmpty) {
    String order = selectedOrderByIndex == 'Ascending' ? 'asce' : 'desc';
    queryParams.add('&order_by=$order');
  }

  final result = queryParams.isEmpty ? '' : queryParams.join('');
  debugPrint('Final Filter Query: $result');
  return result;
}



  Future<void> applyFilters(String filterQuery) async {
    currentFilterQuery = filterQuery;
    allDate.clear();
    hasMoreData = true;
    await fetchExploreDevalayData();
  }

  Future<void> fetchExploreDevalayData({
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

      final result = await exploreRepo.setTemplesFilter(
          '${AppConstant.exploreSingleDevalay}/?page=$page&limit=10$currentFilterQuery');

      result.fold((failure) {
        hasMoreData = false;
        setScreenState(isLoading: false, data: allDate);
        return;
      }, (customResponse) {
        if (customResponse.response!.data is Map &&
            customResponse.response!.data.containsKey("detail") &&
            customResponse.response!.data["detail"] == "Invalid page.") {
          hasMoreData = false;
          setScreenState(isLoading: false, data: allDate);
          return;
        }
        final data = (customResponse.response?.data as List)
            .map((x) => ExploreDevalayModel.fromJson(x))
            .toList();
        allDate.addAll(data);
        hasMoreData = data.isNotEmpty;
        setScreenState(isLoading: false, data: allDate);
      });

      if (upDateData) {
        result.fold((failure) {
          setScreenState(isLoading: false, data: allDate);
        }, (customResponse) {
          final updatedPost =
              ExploreDevalayModel.fromJson(customResponse.response!.data[0]);
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

  Future<void> postFollowing({
    required int followingUserId,
    required int userId,
    required bool isFollowing,
  }) async {
    final result =
        await exploreRepo.postFollowing(followingUserId, userId, isFollowing);
    result.fold(
      (failure) {
        Logger.log("Follow failed: ${failure.toString()}");
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          hasError: true,
        );
      },
      (customResponse) async {
        final updatedPost =
            ExploreDevalayModel.fromJson(customResponse.response!.data);
        final updatedList = allDate.map((post) {
          if (post.id == updatedPost.id) {
            return updatedPost;
          }
          return post;
        }).toList();
        allDate = updatedList;
        fetchGetAllExploreDevoteesData(isUpdate: true);
      },
    );
  }

  Future<void> postSearch({required String makeSearch}) async {
    emit(ExploreDevalayLoaded(
      exploreDevotees: [],
      loadingState: true,
      hasError: false,
      currentPage: 1,
    ));
    final result = await exploreRepo.postSearch(makeSearch);

    result.fold(
      (failure) {
        emit(ExploreDevalayLoaded(
          exploreDevotees: [],
          loadingState: false,
          hasError: true,
          errorMessage: failure.toString(),
          currentPage: 1,
        ));
      },
      (customResponse) async {
        final responseData = customResponse.response!.data as List<dynamic>;
        final devotees =
            responseData.map((e) => ExploreUser.fromJson(e)).toList();

        emit(ExploreDevalayLoaded(
          exploreDevotees: devotees,
          loadingState: false,
          hasError: false,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> fetchGetAllExploreDevoteesData({
    bool loadMoreData = false,
    bool isUpdate = false,
  }) async {
    if (!hasMoreData && loadMoreData) return;
    if (!isUpdate) {
      if (!loadMoreData) {
        page = 1;
        allDevotees.clear();
      } else {
        page++;
      }
      setScreenState(isLoading: true, exploreDevotees: allDevotees);
    }
    final result = await exploreRepo.fetchExploreDevoteesData(page);
    result.fold(
      (failure) {
        if (!isUpdate) {
          hasMoreData = false;
          setScreenState(
            isLoading: false,
            exploreDevotees: allDevotees,
            message: failure.toString(),
            hasError: true,
          );
        } else {
          setScreenState(
            isLoading: false,
            exploreDevotees: allDevotees,
            message: failure.toString(),
            hasError: true,
          );
        }
        Logger.log("this is ${failure.toString()}");
      },
      (customResponse) {
        final responseData = customResponse.response!.data;
        if (!isUpdate) {
          // Handle both List and Map response formats
          List<dynamic> userList;
          if (responseData is List) {
            userList = responseData;
          } else if (responseData is Map) {
            // Try common keys for list data
            if (responseData.containsKey('results')) {
              userList = responseData['results'] as List<dynamic>? ?? [];
            } else if (responseData.containsKey('data')) {
              userList = responseData['data'] as List<dynamic>? ?? [];
            } else if (responseData.containsKey('users')) {
              userList = responseData['users'] as List<dynamic>? ?? [];
            } else {
              // If it's a single user object, wrap it in a list
              userList = [responseData];
            }
          } else {
            Logger.log("Unexpected response format: ${responseData.runtimeType}");
            userList = [];
          }
          
          final data = ExploreUser.fromList(userList);
          allDevotees.addAll(data);
          hasMoreData = data.isNotEmpty;
          setScreenState(isLoading: false, exploreDevotees: allDevotees);
        } else {
          // Handle update case - responseData might be a Map or List
          ExploreUser updatedUser;
          if (responseData is List && responseData.isNotEmpty) {
            updatedUser = ExploreUser.fromJson(responseData[0] as Map<String, dynamic>);
          } else if (responseData is Map) {
            updatedUser = ExploreUser.fromJson(responseData as Map<String, dynamic>);
          } else {
            Logger.log("Unexpected response format for update: ${responseData.runtimeType}");
            setScreenState(isLoading: false, exploreDevotees: allDevotees);
            return;
          }
          
          final updatedList = allDevotees.map((user) {
            return user.id == updatedUser.id ? updatedUser : user;
          }).toList();
          allDevotees
            ..clear()
            ..addAll(updatedList);
          setScreenState(isLoading: false, exploreDevotees: allDevotees);
        }
      },
    );
  }

  Future<void> fetchSingleDevalayData(String devalayId) async {
    setScreenState(isLoading: true);
    final result = await exploreRepo.fetchSingleTempleData(devalayId);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = SingleDevalyModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, singleDevalay: data, data: allDate);
    });
  }

  Future<void> fetchTempleFilterData() async {
    setScreenState(isLoading: true);
    final result = await exploreRepo.fetchTempleFilterData();
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (data) {
      final filterData = TempleFilterModel.fromJson(data.response?.data);
      setScreenState(isLoading: false, templeFilterModel: filterData);
    });
  }

  Future<void> changeLikeStatus(String? id, String? status) async {
    if (id == null || status == null) return;
    final String itemId = id.toString();
    final bool newLikedState = status.toLowerCase() == 'true';

    try {
      if (state is! ExploreDevalayLoaded) return;
      final currentState = state as ExploreDevalayLoaded;
      List<ExploreDevalayModel> updatedList = [];
      for (var item in (currentState.exploreDevalayList ?? [])) {
        if (item.id.toString() == itemId) {
          var updatedItem = ExploreDevalayModel(
            id: item.id,
            title: item.title,
            images: item.images,
            city: item.city,
            liked: newLikedState,
            saved: item.saved,
            viewedCount: item.viewedCount,
            likedCount: newLikedState
                ? (item.likedCount ?? 0) + 1
                : max((item.likedCount ?? 0) - 1, 0),
            savedCount: item.savedCount,
          );
          updatedList.add(updatedItem);
        } else {
          updatedList.add(item);
        }
      }
      allDate = updatedList;
      emit(ExploreDevalayLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreDevalayList: updatedList,
        exploreDevotees: currentState.exploreDevotees,
        singleDevalay: currentState.singleDevalay,
        templeFilterModel: currentState.templeFilterModel,
        selectedFilter: currentState.selectedFilter,
        hasError: currentState.hasError,
        currentPage: currentState.currentPage,
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
      List<ExploreDevalayModel> currentList,
      ExploreDevalayLoaded currentState
      ) async
  {
    try {
      final result = await exploreRepo.changeLikeStatus(itemId, status, 'Devalay');
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

  Future<void> changeViewStatus(
      String id,
      ) async
  {
    try {
      final result = await exploreRepo.changeViewStatus(id, 'true', 'Devalay');
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
    if (state is ExploreDevalayLoaded) {
      final currentState = state as ExploreDevalayLoaded;
      final currentDevalay = currentState.singleDevalay!;
      final isLiking = status == 'true';

      // Create updated single devalay model
      final updatedSingleDevalay = SingleDevalyModel(
        id: currentDevalay.id,
        title: currentDevalay.title,
        address: currentDevalay.address,
        images: currentDevalay.images,
        liked: isLiking,
        saved: currentDevalay.saved,
        viewedCount: currentDevalay.viewedCount,
        likedCount: isLiking
            ? (currentDevalay.likedCount ?? 0) + 1
            : (currentDevalay.likedCount ?? 0) - 1,
        savedCount: currentDevalay.savedCount,
        description: currentDevalay.description,
        legend: currentDevalay.legend,
        etymology: currentDevalay.etymology,
        templeHistory: currentDevalay.templeHistory,
        architecture: currentDevalay.architecture,
        // Add other properties from SingleDevalyModel
        subtitle: currentDevalay.subtitle,
        city: currentDevalay.city,
        state: currentDevalay.state,
        country: currentDevalay.country,
        nearestAirport: currentDevalay.nearestAirport,
        nearestRailway: currentDevalay.nearestRailway,
        landmark: currentDevalay.landmark,
        googleMapLink: currentDevalay.googleMapLink,
        metatags: currentDevalay.metatags,
        website: currentDevalay.website,
        approved: currentDevalay.approved,
        rejected: currentDevalay.rejected,
        rejectReasons: currentDevalay.rejectReasons,
        draft: currentDevalay.draft,
        createdAt: currentDevalay.createdAt,
        updatedAt: currentDevalay.updatedAt,
        governedBy: currentDevalay.governedBy,
        addedBy: currentDevalay.addedBy,
        approvedBy: currentDevalay.approvedBy,
        rejectedBy: currentDevalay.rejectedBy,
        devs: currentDevalay.devs,
      );

      // Update the list optimistically
      List<ExploreDevalayModel> updatedList = allDate.map((post) {
        if (post.id.toString() == id) {
          return ExploreDevalayModel(
            id: post.id,
            title: post.title,
            subtitle: post.subtitle,
            address: post.address,
            images: post.images,
            liked: isLiking,
            saved: post.saved,
            likedCount: isLiking
                ? (post.likedCount ?? 0) + 1
                : (post.likedCount ?? 0) - 1,
            savedCount: post.savedCount,
            viewedCount: post.viewedCount,
            city: post.city,
            description: post.description,
            legend: post.legend,
            etymology: post.etymology,
            templeHistory: post.templeHistory,
            architecture: post.architecture,
            governedBy: post.governedBy, // Fix: Use the entire GovernedBy object, not description
          );
        }
        return post;
      }).toList();

      // Update UI immediately
      setScreenState(
        isLoading: false,
        data: updatedList,
        singleDevalay: updatedSingleDevalay,
      );
    }

    // Hit API in background without using response for UI update
    final result = await exploreRepo.changeLikeStatus(id!, status!, 'Devalay');

    result.fold(
          (failure) {
        // Show error message but don't change UI state
        Fluttertoast.showToast(msg: "Failed to update like status");
        // Optionally revert the optimistic update here if needed
      },
          (success) {
        Fluttertoast.showToast(msg: "Temple liked successfully");

      },
    );
  }

  Future<void> changeSingleSavedStatus(String? id, String? status) async {
    // Optimistically update UI first
    if (state is ExploreDevalayLoaded) {
      final currentState = state as ExploreDevalayLoaded;
      final currentDevalay = currentState.singleDevalay!;
      final isSaving = status == 'true';

      // Create updated single devalay model
      final updatedSingleDevalay = SingleDevalyModel(
        id: currentDevalay.id,
        title: currentDevalay.title,
        address: currentDevalay.address,
        images: currentDevalay.images,
        liked: currentDevalay.liked,
        saved: isSaving,
        likedCount: currentDevalay.likedCount,
        viewedCount: currentDevalay.viewedCount,
        savedCount: isSaving
            ? (currentDevalay.savedCount ?? 0) + 1
            : (currentDevalay.savedCount ?? 0) - 1,
        description: currentDevalay.description,
        legend: currentDevalay.legend,
        etymology: currentDevalay.etymology,
        templeHistory: currentDevalay.templeHistory,
        architecture: currentDevalay.architecture,
        // Add other properties as needed
        subtitle: currentDevalay.subtitle,
        city: currentDevalay.city,
        state: currentDevalay.state,
        country: currentDevalay.country,
        nearestAirport: currentDevalay.nearestAirport,
        nearestRailway: currentDevalay.nearestRailway,
        landmark: currentDevalay.landmark,
        googleMapLink: currentDevalay.googleMapLink,
        metatags: currentDevalay.metatags,
        website: currentDevalay.website,
        approved: currentDevalay.approved,
        rejected: currentDevalay.rejected,
        rejectReasons: currentDevalay.rejectReasons,
        draft: currentDevalay.draft,
        createdAt: currentDevalay.createdAt,
        updatedAt: currentDevalay.updatedAt,
        governedBy: currentDevalay.governedBy,
        addedBy: currentDevalay.addedBy,
        approvedBy: currentDevalay.approvedBy,
        rejectedBy: currentDevalay.rejectedBy,
        devs: currentDevalay.devs,
      );

      // Update the list optimistically
      List<ExploreDevalayModel> updatedList = allDate.map((post) {
        if (post.id.toString() == id) {
          return ExploreDevalayModel(
            id: post.id,
            title: post.title,
              subtitle: post.subtitle,
            address: post.address,
            images: post.images,
            liked: post.liked,
            saved: isSaving,
            likedCount: post.likedCount,
            savedCount: isSaving
                ? (post.savedCount ?? 0) + 1
                : (post.savedCount ?? 0) - 1,
              description: post.description,
              legend: post.legend,
              etymology: post.etymology,
              templeHistory: post.templeHistory,
              architecture: post.architecture,
            viewedCount: post.viewedCount,
            city: post.city,
            governedBy: post.governedBy, //
            // Add other properties as needed
          );
        }
        return post;
      }).toList();

      // Update UI immediately
      setScreenState(
        isLoading: false,
        data: updatedList,
        singleDevalay: updatedSingleDevalay,
      );
    }

    // Hit API in background without using response for UI update
    final result = await exploreRepo.changeSavedStatus(id!, status!, 'Devalay');

    result.fold(
          (failure) {
        // Show error message but don't change UI state
        Fluttertoast.showToast(msg: "Failed to update save status");
        // Optionally revert the optimistic update here if needed
      },
          (success) {
        Fluttertoast.showToast(msg: "Temple saved successfully");
        // API call successful, but we don't update UI from response
        // UI is already updated optimistically
      },
    );
  }

  Future<void> changeSavedStatus(String? id, String? status) async {
    if (id == null || status == null) return;
    final String itemId = id.toString();
    final bool newSavedState = status.toLowerCase() == 'true';
    try {
      if (state is! ExploreDevalayLoaded) return;
      final currentState = state as ExploreDevalayLoaded;
      List<ExploreDevalayModel> updatedList = [];
      for (var item in (currentState.exploreDevalayList ?? [])) {
        if (item.id.toString() == itemId) {
          var updatedItem = ExploreDevalayModel(
            id: item.id,
            title: item.title,
            images: item.images,
            city: item.city,
            liked: item.liked, // Keep existing liked status
            saved: newSavedState,
            likedCount: item.likedCount, // Keep existing liked count
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
      allDate = updatedList;
      emit(ExploreDevalayLoaded(
        loadingState: false,
        errorMessage: currentState.errorMessage,
        exploreDevalayList: updatedList,
        exploreDevotees: currentState.exploreDevotees,
        singleDevalay: currentState.singleDevalay,
        templeFilterModel: currentState.templeFilterModel,
        selectedFilter: currentState.selectedFilter,
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
      List<ExploreDevalayModel> currentList,
      ExploreDevalayLoaded currentState
      ) async {
    try {
      final result = await exploreRepo.changeSavedStatus(itemId, status, 'Devalay');
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

  void setScreenState(
      {List<ExploreDevalayModel>? data,
      SingleDevalyModel? singleDevalay,
      List<ExploreUser>? exploreDevotees,
      List<FeedGetData>? feedData,
      TempleFilterModel? templeFilterModel,
      required bool isLoading,
      String? message,
      int? selectedFilter,
      bool hasError = false}) {
    emit(ExploreDevalayLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        feedData: feedData,
        exploreDevalayList: data,
        exploreDevotees: exploreDevotees,
        singleDevalay: singleDevalay,
        templeFilterModel: templeFilterModel,
        selectedFilter: selectedFilter,
        hasError: hasError,
        currentPage: page));
  }
}
