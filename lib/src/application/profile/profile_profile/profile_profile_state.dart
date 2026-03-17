import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  List<FeedGetData>? feedList;
  FeedGetData? singleFeed;
  bool loadingState;
  bool hasError;
  final bool? liked;
  String errorMessage;

  ProfileLoaded(
      {this.feedList,
      this.singleFeed,
      this.liked,
      required this.loadingState,
      this.hasError = false,
      this.errorMessage = ''});
}
