import 'package:devalay_app/src/data/model/explore/explore_devalay_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_devotees_model.dart';
import 'package:devalay_app/src/data/model/explore/filter/temple_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/single_devalay_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';


abstract class ExploreDevalayState {}

class ExploreDevalayInitial extends ExploreDevalayState {}

class ExploreDevalayLoaded extends ExploreDevalayState {
  List<ExploreDevalayModel>? exploreDevalayList;
  List<FeedGetData>? feedData;
  FeedGetData? singleFeed;
  SingleDevalyModel? singleDevalay;
  TempleFilterModel? templeFilterModel;
  bool loadingState;
  int? selectedFilter;
  List<ExploreUser>? exploreDevotees;
  bool hasError;
  String errorMessage;
  int? currentPage;

  ExploreDevalayLoaded(
      {this.exploreDevalayList,
        this.singleDevalay,
        this.templeFilterModel,
        this.selectedFilter,
        this.feedData,
        this.singleFeed,
        required this.loadingState,
        this.hasError = false,
        this.exploreDevotees,
        this.currentPage,
        this.errorMessage = ''});
}