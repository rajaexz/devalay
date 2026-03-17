import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';

abstract class GlobleState {}

class GlobleInitial extends GlobleState {}

class GlobleLoaded extends GlobleState {

  List<Result>? data;
  bool loadingState;
  bool hasError;
  String errorMessage;

  GlobleLoaded(
      {
        required this.data,
      required this.loadingState,
      this.hasError = false,
      this.errorMessage = ''});
}



