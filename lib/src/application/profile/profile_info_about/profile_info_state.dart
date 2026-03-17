import '../../../data/model/profile/profile_info_model.dart';

abstract class ProfileInfoState {}

class ProfileInfoInitial extends ProfileInfoState {}

class ProfileInfoLoaded extends ProfileInfoState {
  ProfileInfoModel? profileInfoModel;
  bool loadingState;
  bool hasError;
  String errorMessage;

  ProfileInfoLoaded(
      {this.profileInfoModel,
      required this.loadingState,
      this.errorMessage = '',
      this.hasError = false});
}
