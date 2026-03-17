class NotificationSettingsModel {
  final int? id;
  final bool pauseAllNotifications;
  final bool userActivity;
  final int postNotifications; // 1: Off, 2: From Following, 3: From Everyone
  final int commentNotifications;
  final int tagNotifications;
  final bool followerRequests;
  final bool acceptedFollowRequests;
  final bool accountSuggestions;
  final bool newTempleAdded;
  final bool templeUpdated;
  final bool newEventAdded;
  final bool eventUpdated;
  final bool eventReminder;
  final bool newFestivalAdded;
  final bool newGodAdded;
  final bool orderUpdates;
  final bool jobUpdates;

  NotificationSettingsModel({
    this.id,
    required this.pauseAllNotifications,
    required this.userActivity,
    required this.postNotifications,
    required this.commentNotifications,
    required this.tagNotifications,
    required this.followerRequests,
    required this.acceptedFollowRequests,
    required this.accountSuggestions,
    required this.newTempleAdded,
    required this.templeUpdated,
    required this.newEventAdded,
    required this.eventUpdated,
    required this.eventReminder,
    required this.newFestivalAdded,
    required this.newGodAdded,
    required this.orderUpdates,
    required this.jobUpdates,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'pause_all_notifications': pauseAllNotifications,
      'user_activity': userActivity,
      'post_notifications': postNotifications,
      'comment_notifications': commentNotifications,
      'tag_notifications': tagNotifications,
      'follower_requests': followerRequests,
      'accepted_follow_requests': acceptedFollowRequests,
      'account_suggestions': accountSuggestions,
      'new_temple_added': newTempleAdded,
      'temple_updated': templeUpdated,
      'new_event_added': newEventAdded,
      'event_updated': eventUpdated,
      'event_reminder': eventReminder,
      'new_festival_added': newFestivalAdded,
      'new_god_added': newGodAdded,
      'order_updates': orderUpdates,
      'job_updates': jobUpdates,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'],
      pauseAllNotifications: _parseBool(json['pause_all_notifications']),
      userActivity: _parseBool(json['user_activity']),
      postNotifications: _parseNotificationValue(json['post_notifications']),
      commentNotifications: _parseNotificationValue(json['comment_notifications']),
      tagNotifications: _parseNotificationValue(json['tag_notifications']),
      followerRequests: _parseBool(json['follower_requests']),
      acceptedFollowRequests: _parseBool(json['accepted_follow_requests']),
      accountSuggestions: _parseBool(json['account_suggestions']),
      newTempleAdded: _parseBool(json['new_temple_added']),
      templeUpdated: _parseBool(json['temple_updated']),
      newEventAdded: _parseBool(json['new_event_added']),
      eventUpdated: _parseBool(json['event_updated']),
      eventReminder: _parseBool(json['event_reminder']),
      newFestivalAdded: _parseBool(json['new_festival_added']),
      newGodAdded: _parseBool(json['new_god_added']),
      orderUpdates: _parseBool(json['order_updates']),
      jobUpdates: _parseBool(json['job_updates']),
    );
  }

  // Helper method to safely parse boolean values
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // Helper method to safely parse notification integer values
  static int _parseNotificationValue(dynamic value) {
    // If null, return default value
    if (value == null) return 1;
    
    // If it's already an int, return it
    if (value is int) return value;
    
    // If it's a string, try to parse it
    if (value is String) {
      return int.tryParse(value) ?? 1;
    }
    
    // If it's a Map (nested object), try to extract an 'id' or 'value' field
    if (value is Map) {
      // Try common field names that might contain the actual value
      if (value.containsKey('id')) {
        return _parseNotificationValue(value['id']);
      }
      if (value.containsKey('value')) {
        return _parseNotificationValue(value['value']);
      }
      if (value.containsKey('type')) {
        return _parseNotificationValue(value['type']);
      }
      // If no recognizable field, return default
      return 1;
    }
    
    // Default fallback
    return 1;
  }
}