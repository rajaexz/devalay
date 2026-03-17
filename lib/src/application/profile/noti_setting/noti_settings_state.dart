import 'package:devalay_app/src/data/model/setting/notification_settings_model.dart' show NotificationSettingsModel;

abstract class NotificationSettingsState {}

class NotificationSettingsInitial extends NotificationSettingsState {}

class NotificationSettingsLoading extends NotificationSettingsState {}

class NotificationSettingsSuccess extends NotificationSettingsState {
  final String message;
  NotificationSettingsSuccess({required this.message});
}

class NotificationSettingsError extends NotificationSettingsState {
  final String error;
  NotificationSettingsError({required this.error});
}

class NotificationSettingsFetched extends NotificationSettingsState {
  final NotificationSettingsModel settings;
  NotificationSettingsFetched({required this.settings});
}