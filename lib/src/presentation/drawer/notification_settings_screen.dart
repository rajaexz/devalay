import 'package:devalay_app/src/application/profile/noti_setting/noti_setting_cubit.dart';
import 'package:devalay_app/src/application/profile/noti_setting/noti_settings_state.dart';
import 'package:devalay_app/src/data/model/setting/notification_settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/strings.dart';
import '../core/utils/colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool pauseAll = false;
  String postsNotification = "Off";
  String commentsNotification = "Off";
  String tagsNotification = "Off";
  bool followerRequests = true;
  bool acceptedFollowRequests = true;
  bool accountSuggestions = true;
  bool newTempleAdded = true;
  bool templeUpdated = true;
  bool newEventAdded = false;
  bool eventUpdated = true;
  bool eventReminder = false;
  bool newFestivalAdded = true;
  bool newGodAdded = true;
  String myContributions = "Off";
  bool orderUpdates = true;
  bool jobUpdates = true;
  int? settingsId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    context.read<NotiSettingCubit>().fetchNotificationSettings();
  }

  int _notificationStringToInt(String value) {
    switch (value) {
      case "Off":
        return 1;
      case "from_following":
        return 2;
      case "from_everyone":
        return 3;
      default:
        return 1;
    }
  }

  String _notificationIntToString(int value) {
    switch (value) {
      case 1:
        return "Off";
      case 2:
        return "from_following";
      case 3:
        return "from_everyone";
      default:
        return "Off";
    }
  }

  // Handle nested object from API (e.g., {"id":1,"label":"off"})
  String _extractNotificationLabel(dynamic value) {
    if (value is Map) {
      // Extract the 'id' field from the map
      int? id = value['id'];
      if (id != null) {
        return _notificationIntToString(id);
      }
      // Fallback: try to extract label
      String label = value['label']?.toString().toLowerCase() ?? 'off';
      switch (label) {
        case 'off':
          return 'Off';
        case 'from_following':
          return 'from_following';
        case 'from_everyone':
          return 'from_everyone';
        default:
          return 'Off';
      }
    } else if (value is int) {
      return _notificationIntToString(value);
    } else if (value is String) {
      String label = value.toLowerCase();
      switch (label) {
        case 'off':
          return 'Off';
        case 'from_following':
          return 'from_following';
        case 'from_everyone':
          return 'from_everyone';
        default:
          return 'Off';
      }
    }
    return 'Off';
  }
  
  void _saveSettings() {
    final settings = NotificationSettingsModel(
      id: settingsId,
      pauseAllNotifications: pauseAll,
      userActivity: true,
      postNotifications: _notificationStringToInt(postsNotification),
      commentNotifications: _notificationStringToInt(commentsNotification),
      tagNotifications: _notificationStringToInt(tagsNotification),
      followerRequests: followerRequests,
      acceptedFollowRequests: acceptedFollowRequests,
      accountSuggestions: accountSuggestions,
      newTempleAdded: newTempleAdded,
      templeUpdated: templeUpdated,
      newEventAdded: newEventAdded,
      eventUpdated: eventUpdated,
      eventReminder: eventReminder,
      newFestivalAdded: newFestivalAdded,
      newGodAdded: newGodAdded,
      orderUpdates: orderUpdates,
      jobUpdates: jobUpdates,
    );

    context.read<NotiSettingCubit>().updateNotificationSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 30.sp,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          StringConstant.notification,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.appbarBgColor,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<NotiSettingCubit, NotificationSettingsState>(
        listener: (context, state) {
          if (state is NotificationSettingsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NotificationSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is NotificationSettingsFetched) {
            setState(() {
              settingsId = state.settings.id;
              pauseAll = state.settings.pauseAllNotifications;
              
              // Handle nested objects for notifications
              postsNotification = _extractNotificationLabel(state.settings.postNotifications);
              commentsNotification = _extractNotificationLabel(state.settings.commentNotifications);
              tagsNotification = _extractNotificationLabel(state.settings.tagNotifications);
              
              followerRequests = state.settings.followerRequests;
              acceptedFollowRequests = state.settings.acceptedFollowRequests;
              accountSuggestions = state.settings.accountSuggestions;
              newTempleAdded = state.settings.newTempleAdded;
              templeUpdated = state.settings.templeUpdated;
              newEventAdded = state.settings.newEventAdded;
              eventUpdated = state.settings.eventUpdated;
              eventReminder = state.settings.eventReminder;
              newFestivalAdded = state.settings.newFestivalAdded;
              newGodAdded = state.settings.newGodAdded;
              orderUpdates = state.settings.orderUpdates;
              jobUpdates = state.settings.jobUpdates;
            });
          }
        },
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
            children: [
              _buildToggleItem(
                title: StringConstant.pauseAll,
                subtitle: StringConstant.pauseAllSubtitle,
                value: pauseAll,
                onChanged: (value) => setState(() => pauseAll = value),
              ),
              Gap(24.h),
              // Wrap all sections with Opacity to show disabled state
              Opacity(
                opacity: pauseAll ? 0.4 : 1.0,
                child: Column(
                  children: [
                    _buildSectionHeader("user_activity".tr()),
                    _buildRadioSection(
                      title: StringConstant.post,
                      value: postsNotification,
                      options: ["off".tr(), "from_following".tr(), "from_everyone".tr()],
                      onChanged: (value) => setState(() => postsNotification = value),
                      enabled: !pauseAll,
                    ),
                    Gap(20.h),
                    _buildRadioSection(
                      title: StringConstant.comment,
                      value: commentsNotification,
                      options: ["off".tr(), "from_following".tr(), "from_everyone".tr()],
                      onChanged: (value) => setState(() => commentsNotification = value),
                      enabled: !pauseAll,
                    ),
                    Gap(20.h),
                    _buildRadioSection(
                      title: "tags".tr(),
                      value: tagsNotification,
                      options: ["off".tr(), "from_following".tr(), "from_everyone".tr()],
                      onChanged: (value) => setState(() => tagsNotification = value),
                      enabled: !pauseAll,
                    ),
                    Gap(24.h),
                    _buildSectionHeader("followers_following".tr()),
                    _buildToggleItem(
                      title: "follower_request".tr(),
                      value: followerRequests,
                      onChanged: (value) => setState(() => followerRequests = value),
                      enabled: !pauseAll,
                    ),
                    _buildToggleItem(
                      title: "accepted_follow_requests".tr(),
                      value: acceptedFollowRequests,
                      onChanged: (value) =>
                          setState(() => acceptedFollowRequests = value),
                      enabled: !pauseAll,
                    ),
                    _buildToggleItem(
                      title: "account_suggestions".tr(),
                      value: accountSuggestions,
                      onChanged: (value) => setState(() => accountSuggestions = value),
                      enabled: !pauseAll,
                    ),
                    Gap(24.h),
                    _buildSectionHeader("community_activity".tr()),
                    _buildSubSectionHeader(StringConstant.temples),
                    _buildToggleItem(
                      title: "new_temple_added".tr(),
                      value: newTempleAdded,
                      onChanged: (value) => setState(() => newTempleAdded = value),
                      enabled: !pauseAll,
                    ),
                    _buildToggleItem(
                      title: "temple_updated".tr(),
                      value: templeUpdated,
                      onChanged: (value) => setState(() => templeUpdated = value),
                      enabled: !pauseAll,
                    ),
                    _buildSubSectionHeader(StringConstant.events),
                    _buildToggleItem(
                      title: "new_event_added".tr(),
                      value: newEventAdded,
                      onChanged: (value) => setState(() => newEventAdded = value),
                      enabled: !pauseAll,
                    ),
                    _buildToggleItem(
                      title: "event_updated".tr(),
                      value: eventUpdated,
                      onChanged: (value) => setState(() => eventUpdated = value),
                      enabled: !pauseAll,
                    ),
                    _buildToggleItem(
                      title: "event_reminder".tr(),
                      value: eventReminder,
                      onChanged: (value) => setState(() => eventReminder = value),
                      enabled: !pauseAll,
                    ),
                    _buildSubSectionHeader("festivals_gods".tr()),
                    _buildToggleItem(
                      title: "new_festival_added".tr(),
                      value: newFestivalAdded,
                      onChanged: (value) => setState(() => newFestivalAdded = value),
                      enabled: !pauseAll,
                    ),
                    _buildToggleItem(
                      title: "new_god_added".tr(),
                      value: newGodAdded,
                      onChanged: (value) => setState(() => newGodAdded = value),
                      enabled: !pauseAll,
                    ),
                    _buildSubSectionHeader("my_contributions".tr()),
                    _buildRadioSection(
                      title: "",
                      value: myContributions,
                      options: ["off".tr(), "from_following".tr(), "from_everyone".tr()],
                      onChanged: (value) => setState(() => myContributions = value),
                      enabled: !pauseAll,
                    ),
                    Gap(24.h),
                    _buildSectionHeader("service_activity".tr()),
                    _buildSubSectionHeader("order_notification".tr()),
                    _buildToggleItem(
                      title: "order_updates".tr(),
                      value: orderUpdates,
                      onChanged: (value) => setState(() => orderUpdates = value),
                      enabled: !pauseAll,
                    ),
                    _buildSubSectionHeader("job_notification".tr()),
                    _buildToggleItem(
                      title: "job_updates".tr(),
                      value: jobUpdates,
                      onChanged: (value) => setState(() => jobUpdates = value),
                      enabled: !pauseAll,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColor.blackColor)
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColor.blackColor, fontWeight: FontWeight.w500)
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (subtitle != null) ...[
                  Gap(0.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 30.sp,
            width: 50.sp,
            child: FittedBox(
              fit: BoxFit.fill,
              child: CupertinoSwitch(
                value: value,
                activeColor: const Color(0xffE8E8E8),
                inactiveThumbColor: const Color(0xffC5C5C5),
                thumbColor: const Color(0xff555151),
                trackColor: const Color(0xffE8E8E8),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioSection({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    // Define internal values (non-translated keys)
    final internalOptions = ["Off", "from_following", "from_everyone"];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 0.h),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500, 
                color: AppColor.blackColor
              )
            ),
          ),
        ],
        ...List.generate(internalOptions.length, (index) {
          return _buildRadioOption(
            internalOptions[index], 
            options[index], 
            value, 
            onChanged, 
            enabled
          );
        }),
      ],
    );
  }

  Widget _buildRadioOption(
      String internalValue, 
      String displayText, 
      String currentValue, 
      ValueChanged<String> onChanged, 
      bool enabled) {
    final isSelected = currentValue == internalValue;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged(internalValue) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: Theme.of(context).textTheme.bodyMedium
              ),
            ),
            Radio<String>(
              value: internalValue,
              groupValue: currentValue,
              onChanged: enabled ? (value) => onChanged(value!) : null,
              activeColor: AppColor.appbarBgColor,
            ),
          ],
        ),
      ),
    );
  }
}