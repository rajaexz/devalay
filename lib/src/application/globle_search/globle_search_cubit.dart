import 'dart:async';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_state.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GobelSearchCubit extends Cubit<GlobleState> {
  final ExploreRepo exploreRepo;

  GobelSearchCubit()
      : exploreRepo = getIt<ExploreRepo>(),
        super(GlobleInitial());
  List<Result> globleSearch = [];

  // Filter Variables

  final TextEditingController searchController = TextEditingController();
  Timer? debounce;
  final FocusNode focusNode = FocusNode();

  bool showResults = false;
  final searchLocationController = TextEditingController();
  final searchDevController = TextEditingController();
  bool isLocationSelected = false;
  bool isDevSelected = false;
  String? selectedLocationIndex;
  String? selectedDevIndex;
  String? selectedSortByIndex = 'Likes';
  String? selectedOrderByIndex = 'Decending';
  ///=================================
 int selectedFilter = 0;

// [StringConstant.location, StringConstant.dev, StringConstant.sortBy, StringConstant.orderBy]
  final List<String> filterTypes = [ StringConstant.sortBy];
  final List<String> sortBy = [ StringConstant.likeTab,  StringConstant.addedDate,  StringConstant.alphabetically];


  Future<void> fetchGlobleSearcUserhData({
    required String makeSearch,
    required String textType,
  }) async {
    try {
      setScreenState(
        data: [],
        isLoading: true,
        hasError: false,
      );

      final result = await exploreRepo.fetchGlobleSearchData(makeSearch, textType);

      result.fold(
        (failure) {
          // Use improved error handling
          String errorMessage = _getErrorMessage(failure);
          NetworkErrorHandler.handleError(failure);
          
          setScreenState(
            data: [],
            isLoading: false,
            hasError: true,
            message: errorMessage,
          );
        },
        (customResponse) async {
          if (customResponse.hasError) {
            NetworkErrorHandler.handleApiError(customResponse.response?.data);
            setScreenState(
              data: [],
              isLoading: false,
              hasError: true,
              message: customResponse.error,
            );
            return;
          }

          final responseData = customResponse.response?.data;

          if (responseData is Map &&
              responseData.containsKey("results") &&
              responseData["results"] == "No Results Found") {
            setScreenState(
              data: [],
              isLoading: false,
              hasError: false,
            );
            return;
          }

          if (responseData is Map && responseData.containsKey('results')) {
            final searches = responseData["results"] as List;

            final parsedData = searches
                .map((e) => Result.fromJson(e as Map<String, dynamic>))
                .toList();

            globleSearch.clear();
            globleSearch.addAll(parsedData);

            setScreenState(
              data: globleSearch,
              isLoading: false,
              hasError: false,
            );
          } else {
            setScreenState(
              data: [],
              isLoading: false,
              hasError: true,
              message: "Unexpected response format.",
            );
          }
        },
      );
    } catch (e, stackTrace) {
      print("Global search fetch failed: $e\n$stackTrace");
      NetworkErrorHandler.handleError(e);

      setScreenState(
        data: [],
        isLoading: false,
        hasError: true,
        message: "Something went wrong. Please try again.",
      );
    }
  }
 String currentFilterQuery = '';

int page = 1;
  bool hasMoreData = true;
  bool isFetching = false;
  String? lastRequestKey;

  List allDate = [];
///=================================


  Future<void> applyFilters(String filterQuery, String textType) async {
    currentFilterQuery = filterQuery;

    page = 1;
    globleSearch.clear();
    hasMoreData = true;

    await fetchGlobleSearchData(makeSearch:'', textType: textType, filterQuery: filterQuery, loadMoreData: false);
  }

  Future<void> fetchGlobleSearchData({
    required String makeSearch,
    required String textType,
    String filterQuery = '',
    bool loadMoreData = false,
  }) async {
    try {
    
      isFetching = true;
      if (!loadMoreData) {
        setScreenState(
          data: globleSearch,
          isLoading: true,
          hasError: false,
        );
      }

      final result = await exploreRepo.fetchGlobleSearchData(makeSearch, textType, filterQuery, page);

      result.fold(
        (failure) {
          // Use improved error handling
          String errorMessage = _getErrorMessage(failure);
          NetworkErrorHandler.handleError(failure);
          
          // If loading more data failed, decrement page to retry
          if (loadMoreData && page > 1) {
            page--;
          }
          
          setScreenState(
            data: globleSearch,
            isLoading: false,
            hasError: true,
            message: errorMessage,
          );
        },
        (customResponse) async {
          if (customResponse.hasError) {
            NetworkErrorHandler.handleApiError(customResponse.response?.data);
            
            // If loading more data failed, decrement page to retry
            if (loadMoreData && page > 1) {
              page--;
            }
            
            setScreenState(
              data: globleSearch,
              isLoading: false,
              hasError: true,
              message: customResponse.error,
            );
            return;
          }

          final responseData = customResponse.response?.data;

          if (responseData is Map &&
              responseData.containsKey("results") &&
              responseData["results"] == "No Results Found") {
            if (!loadMoreData) {
              globleSearch.clear();
            }
            hasMoreData = false;
            setScreenState(
              data: globleSearch,
              isLoading: false,
              hasError: false,
            );
            return;
          }

          if (responseData is Map && responseData.containsKey('results')) {
            // Parse pagination info
            final globleSearchModel = GlobleSearch.fromJson(
              Map<String, dynamic>.from(responseData),
            );
            
            final searches = responseData["results"] as List;

            final parsedData = searches
                .map((e) => Result.fromJson(e as Map<String, dynamic>))
                .toList();

            // Update hasMoreData based on API response and actual data
            hasMoreData = (globleSearchModel.hasNext ?? false) && parsedData.isNotEmpty;
            
            // If loading more and got empty results, no more data
            if (loadMoreData && parsedData.isEmpty) {
              hasMoreData = false;
            }

            if (loadMoreData) {
              // Append data when loading more
              globleSearch.addAll(parsedData);
            } else {
              // Clear and set new data for initial load
              globleSearch.clear();
              globleSearch.addAll(parsedData);
            }

            setScreenState(
              data: globleSearch,
              isLoading: false,
              hasError: false,
            );
          } else {
            setScreenState(
              data: globleSearch,
              isLoading: false,
              hasError: true,
              message: "Unexpected response format.",
            );
          }
        },
      );
    } catch (e, stackTrace) {
      print("Global search fetch failed: $e\n$stackTrace");
      NetworkErrorHandler.handleError(e);

      // If loading more data failed, decrement page to retry
      if (loadMoreData && page > 1) {
        page--;
      }

      setScreenState(
        data: globleSearch,
        isLoading: false,
        hasError: true,
        message: "Something went wrong. Please try again.",
      );
    } finally {
      isFetching = false;
    }
  }

  String _getErrorMessage(dynamic failure) {
    if (failure == null) return "Something went wrong.";
    
    String failureString = failure.toString();
    
    if (failureString.contains('No Internet')) {
      return "Please check your internet connection and try again.";
    }
    
    if (failureString.contains('timeout') || failureString.contains('Timeout')) {
      return "Request timed out. Please try again.";
    }
    
    if (failureString.contains('server') || failureString.contains('500')) {
      return "Server error. Please try again later.";
    }
    
    if (failureString.contains('401') || failureString.contains('unauthorized')) {
      return "Session expired. Please login again.";
    }
    
    return "Something went wrong. Please try again.";
  }

  void setScreenState({
    List<Result>? data,
    required bool isLoading,
    String? message,
    bool hasError = false,
  }) {
    // Prevent emitting new states after the cubit has been closed
    if (isClosed) return;

    emit(GlobleLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      data: data,
      hasError: hasError,
    ));
  }

  // Add retry functionality
  void retrySearch(String textType) {
    if (searchController.text.isNotEmpty) {
      fetchGlobleSearchData(
        makeSearch: searchController.text,
        textType:  textType,
      );
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    globleSearch.clear();
    setScreenState(
      data: [],
      isLoading: false,
      hasError: false,
    );
  }

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    focusNode.dispose();
    return super.close();
  }
}
