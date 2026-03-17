
import 'package:devalay_app/src/data/model/explore/filter/temple_filter_model.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart' show Result;


abstract class TempleSearchState{}

class TempleSearchInitial extends TempleSearchState {}

class TempleSearchLoaded extends TempleSearchState {

  List<Result>? data;
  bool loadingState;
  bool hasError;
    TempleFilterModel? templeFilterModel;
  String errorMessage;

TempleSearchLoaded(
      {
        required this.data,
        required this.templeFilterModel,
      required this.loadingState,
      this.hasError = false,
      this.errorMessage = ''});
}



