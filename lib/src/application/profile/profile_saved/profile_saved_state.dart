import 'package:devalay_app/src/data/model/contribution/contribution_festival_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_dev_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_puja_model.dart';

import '../../../data/model/contribution/contribution_devalay_model.dart';
import '../../../data/model/explore/explore_event_model.dart';
import '../../../data/model/feed/feed_home_model.dart';

abstract class ProfileSavedState {}

class ProfileSavedInitial extends ProfileSavedState {}

class ProfileSavedLoaded extends ProfileSavedState {
  List<ContributionDevalayModel>? savedTempleModel;
  List<ExploreEventModel>? saveEventModel;
  List<ExplorePujaModel>? savePujaModel;
  List<ExploreDevModel>? saveDevModel;
  List<ContributionFestivalModel>? saveFestivalModel;
  List<FeedGetData>? feedList;
  bool loadingState;
  bool hasError;
  String errorMessage;
  int currentPage;

  ProfileSavedLoaded(
      {this.savedTempleModel,
      this.saveEventModel,
      required this.loadingState,
      this.feedList,
      this.savePujaModel,
      this.saveDevModel,
      this.saveFestivalModel,
      this.errorMessage = '',
      this.hasError = false,
      required this.currentPage});
}
