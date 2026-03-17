import 'dart:async';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/globle_search/temple/temple_search_state.dart';
import 'package:devalay_app/src/data/model/explore/filter/temple_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class TempleSearchICubit extends Cubit<TempleSearchState> {
  final ExploreRepo exploreRepo;

  TempleSearchICubit()
      : exploreRepo = getIt<ExploreRepo>(),
        super(TempleSearchInitial());
  bool hasMoreData = true;
  List allDate = [];
        int selectedFilter = 0;
        TempleFilterModel? templeFilterModel;
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


  final FocusNode focusNode = FocusNode();
  String currentFilterQuery = '';
  String searchQuery = '';
  String? selectedLocationIndex;
  String? selectedDevIndex;
  String? selectedSortByIndex = "likes";
  String? selectedOrderByIndex = StringConstant.decending;
  Map<String, dynamic> selectedLocationFilterMap = {};
  Map<String, dynamic> selectedDevFilterMap = {};
  final List<String> queryParams = [];
  String filterQuery = '';
  final searchLocationController = TextEditingController();
  final searchDevController = TextEditingController();
  bool isLocationSelected = false;
  bool isDevSelected = false;


  String buildFilterQuery() {
    queryParams.clear();

    if (selectedLocationIndex != null && selectedLocationFilterMap.isNotEmpty) {
      final city = selectedLocationFilterMap['city'];
      final state = selectedLocationFilterMap['state'];
      final country = selectedLocationFilterMap['country'];

      if (city != null) queryParams.add('&city=$city');
      if (state != null) queryParams.add('&state=$state');
      if (country != null) queryParams.add('&country=$country');
    }
    if (selectedDevIndex != null && selectedDevFilterMap.isNotEmpty) {
      final devId = selectedDevFilterMap['dev'];
      if (devId != null) queryParams.add('&dev=$devId');
    }

    if (selectedSortByIndex != null) {
      String sortBy = selectedSortByIndex!.toLowerCase();
      if (sortBy == 'added date') sortBy = 'recent';
      if (sortBy == 'alphabetically') sortBy = 'alphabetically';
      queryParams.add('&sort_by=$sortBy');
    }

    if (selectedOrderByIndex != null) {
      String order = selectedOrderByIndex == 'Ascending' ? 'asce' : 'desc';
      queryParams.add('&order_by=$order');
    }

    return queryParams.isEmpty ? '' : queryParams.join('');
  }


 
 
   Future<void> applyFilters(String filterQuery) async {
    currentFilterQuery = filterQuery;
    allDate.clear();
    hasMoreData = true;
    await fetchExploreDevalayData();
  }

  Future<void> fetchExploreDevalayData() async {
    setScreenState(isLoading: true);
    final result = await exploreRepo.fetchGlobleSearchData(currentFilterQuery, 'temple');
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (data) {
      // Use data.response?.data directly, since API returns a List at the root
      final dynamic resultsRaw = data.response?.data;
      List<Result> results = [];
      if (resultsRaw is List) {
        results = resultsRaw
            .whereType<Map>()
            .map((e) => Result.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (resultsRaw is Map) {
        results = [Result.fromJson(Map<String, dynamic>.from(resultsRaw))];
      } else {
        print('TempleSearchICubit: Unexpected results type: \\${resultsRaw.runtimeType}');
      }

      print('TempleSearchICubit: Results: ${results.length}');
      setScreenState(isLoading: false, data: results);
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
void setScreenState({
  List<Result>? data,
  required bool isLoading,
  String? message,
  bool hasError = false,
  TempleFilterModel? templeFilterModel,
}) {
  if (isClosed) return; // <-- Add this line
  emit(TempleSearchLoaded(
    loadingState: isLoading,
    templeFilterModel: templeFilterModel,
    errorMessage: message ?? '',
    data: data,
    hasError: hasError,
  ));
}
}
