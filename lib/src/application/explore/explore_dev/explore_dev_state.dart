import 'package:devalay_app/src/data/model/explore/explore_dev_model.dart';
import 'package:devalay_app/src/data/model/explore/single_gods_model.dart';

import '../../../data/model/feed/feed_home_model.dart';

abstract class ExploreDevState {}

class ExploreDevInitial extends ExploreDevState {}

class ExploreDevLoaded extends ExploreDevState {
  List<ExploreDevModel>? exploreDevList;
  List<FeedGetData>? feedData;
  FeedGetData? singleFeed;
  SingleGodModel? singleGod;
  bool loadingState;
  bool hasError;
  String errorMessage;
  int currentPage;

  ExploreDevLoaded(
      {this.exploreDevList,
      this.feedData,
      this.singleFeed,
      this.singleGod,
      required this.loadingState,
      this.hasError = false,
      required this.currentPage,
      this.errorMessage = ''});
}
