import '../../../data/model/setting/help_support_model.dart';

abstract class SettingState {}

class SettingInitial extends SettingState {}

class SettingLoaded extends SettingState {
  List<HelpSupportModel>? helpSupportModel;
  bool loadingState;
  String errorMessage;

  SettingLoaded(
      {this.helpSupportModel,
        required this.loadingState,
        this.errorMessage = ''
      });
}