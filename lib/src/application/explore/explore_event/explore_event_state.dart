import 'package:devalay_app/src/data/model/explore/explore_event_model.dart';
import 'package:devalay_app/src/data/model/explore/filter/event_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/single_event_model.dart';

import '../../../data/model/feed/feed_home_model.dart';

abstract class ExploreEventState {}

class ExploreEventInitial extends ExploreEventState {}

class ExploreEventLoaded extends ExploreEventState {
  List<ExploreEventModel>? exploreEventList;
  List<FeedGetData>? feedData;
  FeedGetData? singleFeed;
  SingleEventModel? singleEvent;
  EventFilterModel? eventFilter;
  bool loadingState;
  String errorMessage;
  bool hasError;

  ExploreEventLoaded(
      {this.exploreEventList,
      this.feedData,
      this.singleFeed,
      this.singleEvent,
      this.eventFilter,
      required this.loadingState,
      this.hasError = false,
      this.errorMessage = ''});
}
