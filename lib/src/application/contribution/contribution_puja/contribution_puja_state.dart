import 'package:devalay_app/src/data/model/contribution/contribution_puja_model.dart';

import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';

abstract class ContributePujaState {}

class ContributePujaInitial extends ContributePujaState {}

class ContributePujaLoaded extends ContributePujaState {
  List<ContributionPujaModel>? pujaList;
  ContributionPujaModel? singlePuja;
  AcceptBannerModel? acceptBannerModel;
  CommonModel? commonModel;
  String? pujaId;
  bool loadingState;
  String errorMessage;
  bool hasError;
  bool isPermissionDenied;

  ContributePujaLoaded(
      {this.pujaList,
      this.singlePuja,
      this.commonModel,
      this.acceptBannerModel,
      this.pujaId,
      required this.loadingState,
      this.errorMessage = '',
      this.hasError = false,
      this.isPermissionDenied = false});
}


class ContributePujaError extends ContributePujaState {
  final String message;
  final bool isPermissionDenied;

  ContributePujaError({
    required this.message,
    this.isPermissionDenied = false,
  });
}
