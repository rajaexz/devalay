import 'package:devalay_app/src/data/model/contribution/contribution_festival_model.dart';

import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';

abstract class ContributeFestivalState {}

class ContributeFestivalInitial extends ContributeFestivalState {}

class ContributeFestivalLoaded extends ContributeFestivalState {
  List<ContributionFestivalModel>? festivalList;
  ContributionFestivalModel? singleFestival;
  AcceptBannerModel? acceptBannerModel;
  CommonModel? commonModel;
  String? festivalId;
  bool loadingState;
  String errorMessage;
  bool hasError;

  ContributeFestivalLoaded(
      {this.festivalList,
      this.singleFestival,
      this.commonModel,
      this.acceptBannerModel,
      this.festivalId,
      required this.loadingState,
      this.errorMessage = '',
      this.hasError = false});
}

class ContributeFestivalError extends ContributeFestivalState {
  final String message;
  final bool isPermissionDenied;

  ContributeFestivalError({
    required this.message,
    this.isPermissionDenied = false,
  });
}
