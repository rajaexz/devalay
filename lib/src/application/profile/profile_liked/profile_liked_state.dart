import '../../../data/model/contribution/contribution_devalay_model.dart';
import '../../../data/model/explore/explore_event_model.dart';
import '../../../data/model/feed/feed_home_model.dart';

abstract class ProfileLikedTempleState {}

class ProfileLikedTempleInitial extends ProfileLikedTempleState {}

class ProfileLikedTempleLoaded extends ProfileLikedTempleState {
  List<ContributionDevalayModel>? likeTemplesModel;
  List<FeedGetData>? feedList;
  List<ExploreEventModel>? likeEventModel;
  bool loadingState;
  bool hasError;
  String errorMessage;
  int currentPage;

  ProfileLikedTempleLoaded(
      {this.likeTemplesModel,
      this.feedList,
      this.likeEventModel,
      required this.loadingState,
      this.errorMessage = '',
      this.hasError = false,
      required this.currentPage});
}
