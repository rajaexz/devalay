import 'package:devalay_app/injection.dart' show getIt;
import 'package:devalay_app/src/application/profile/noti_setting/noti_settings_state.dart';
import 'package:devalay_app/src/data/model/setting/notification_settings_model.dart' show NotificationSettingsModel;
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotiSettingCubit extends Cubit<NotificationSettingsState> {
  final ProfileRepo profileRepo = getIt<ProfileRepo>();

  
  NotiSettingCubit() : super(NotificationSettingsInitial());

  // Fetch current notification settings
Future<void> fetchNotificationSettings() async {
  emit(NotificationSettingsLoading());
  
  final result = await profileRepo.fetchNotificationSettings();
  
  result.fold(
    (failure) => emit(NotificationSettingsError(error: failure.errorMessage)),
    (response) {
      try {
        // Print the raw response to debug
        print('Raw API Response: ${response.response!.data}');
        
        // Check if data is wrapped in another object
        final data = response.response!.data;
        final settingsData = data is Map<String, dynamic> 
            ? (data['data'] ?? data['results'] ?? data) 
            : data;
        
        final settings = NotificationSettingsModel.fromJson(settingsData);
        emit(NotificationSettingsFetched(settings: settings));
      } catch (e, stackTrace) {
        print('Parse Error: $e');
        print('Stack Trace: $stackTrace');
        emit(NotificationSettingsError(
          error: 'Failed to parse settings: ${e.toString()}'
        ));
      }
    },
  );
}
  // Update notification settings
  Future<void> updateNotificationSettings(NotificationSettingsModel settings) async {
    emit(NotificationSettingsLoading());
    print("${settings.toJson()} ============");
    final result = await profileRepo.updateNotificationSettings(settings);
    
    result.fold(
      (failure) => emit(NotificationSettingsError(error: failure.errorMessage)),
      (response) {
        emit(NotificationSettingsSuccess(message: 'Settings updated successfully'));
        // Optionally fetch updated settings
        fetchNotificationSettings();
      },
    );
  }
}