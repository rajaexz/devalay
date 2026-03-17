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
  String selectText = "";
  final TextEditingController searchController = TextEditingController();
  Timer? debounce;
  final FocusNode focusNode = FocusNode();
  List<String> searchHistory = [];
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
              message: "No data found $textType",
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

  List allDate = [];
///=================================


  Future<void> applyFilters(String filterQuery) async {
    currentFilterQuery = filterQuery;
    page = 1;
    allDate.clear();
    hasMoreData = true;
    await fetchGlobleSearchData(makeSearch:'', textType: '');
  }

  Future<void> fetchGlobleSearchData({
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
              message: "No data found $textType",
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
    emit(GlobleLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      data: data,
      hasError: hasError,
    ));
  }

  // Add retry functionality
  void retrySearch() {
    if (searchController.text.isNotEmpty) {
      fetchGlobleSearchData(
        makeSearch: searchController.text,
        textType: selectText,
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
