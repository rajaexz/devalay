import 'package:devalay_app/src/data/model/explore/explore_festival_model.dart';
import 'package:devalay_app/src/data/model/explore/filter/festival_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/single_festival_model.dart';

import '../../../data/model/feed/feed_home_model.dart';

abstract class ExploreFestivalState {}

class ExploreFestivalInitial extends ExploreFestivalState {}

class ExploreFestivalLoaded extends ExploreFestivalState {
  List<ExploreFestivalModel>? exploreFestivalList;
  List<FeedGetData>? feedData;
  SingleFestivalModel? singleFestival;
  FestivalFilterModel? festivalFilter;
  bool loadingState;
  bool hasError;
  String errorMessage;
  int currentPage;

  ExploreFestivalLoaded(
      {this.exploreFestivalList,
      this.singleFestival,
      this.festivalFilter,
      this.feedData,
      required this.loadingState,
      this.hasError = false,
      required this.currentPage,
      this.errorMessage = ''});
}
