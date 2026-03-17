import '../../../data/model/contribution/contribution_dev_model.dart';

abstract class ContributeDevState {}

class ContributeDevInitial extends ContributeDevState {}

class ContributeDevLoaded extends ContributeDevState {
  String? devId;
  bool loadingState;
  String errorMessage;
  bool hasError;
  ContributionDevModel? singleData;
  List<ContributionDevModel>? model;

  ContributeDevLoaded(
      {this.devId,
      this.singleData,
      this.model,
      required this.loadingState,
      this.errorMessage = '',
      this.hasError = false});
}

class ContributeDevError extends ContributeDevState {
  final String message;
  final bool isPermissionDenied;
  ContributeDevError({
    required this.message,
    this.isPermissionDenied = false,
  });
}