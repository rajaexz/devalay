import 'package:devalay_app/src/data/model/contribution/god_form_model.dart';

import '../../../data/model/contribution/avatar_model.dart';
import '../../../data/model/contribution/temple_list_model.dart';

abstract class GodFormState {}

class GodFormInitial extends GodFormState {}

class GodFormLoaded extends GodFormState {
  List<GodFormModel>? godList;
  List<TempleListModel>? templeList;
  List<AvatarModel>? avatarList;
  bool loadingState;
  String errorMessage;

  GodFormLoaded(
      {this.godList,
      this.templeList,
      this.avatarList,
      required this.loadingState,
      this.errorMessage = ''});
}
