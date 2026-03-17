import 'package:devalay_app/src/data/model/explore/explore_puja_model.dart';
import 'package:devalay_app/src/data/model/explore/single_puja_model.dart';

abstract class ExplorePujaState {}

class ExplorePujaInitial extends ExplorePujaState {}

class ExplorePujaLoaded extends ExplorePujaState {
  List<ExplorePujaModel>? explorePujaList;
  SinglePujaModel? singlePuja;
  bool loadingState;
  bool hasError;
  String errorMessage;
  int currentPage;

  ExplorePujaLoaded(
      {this.explorePujaList,
      this.singlePuja,
      required this.loadingState,
      this.hasError = false,
      required this.currentPage,
      this.errorMessage = ''});
}
