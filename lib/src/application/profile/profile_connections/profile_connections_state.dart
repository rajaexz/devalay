import '../../../data/model/profile/following_request_model.dart';
import '../../../data/model/profile/profile_info_model.dart';

abstract class ProfileConnectionsState {}

class ProfileConnectionsInitial extends ProfileConnectionsState {}

class ProfileConnectionsLoaded extends ProfileConnectionsState {
  ProfileInfoModel? profileInfoModel;
  FollowingRequestModel? followingRequestModel;
  bool loadingState;
  bool hasError;
  String errorMessage;

  ProfileConnectionsLoaded(
      {this.profileInfoModel,
        this.followingRequestModel,
      required this.loadingState,
      this.errorMessage = '',
      this.hasError = false});
}
