import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/notification_model.dart';
import 'package:flutter/foundation.dart';

class NotificationSocketService {
  static final NotificationSocketService _instance = NotificationSocketService._internal();
  
  factory NotificationSocketService() => _instance;
  
  NotificationSocketService._internal();
  
  final ValueNotifier<int> notificationCount = ValueNotifier(0);
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<String> connectionStatus = ValueNotifier('Disconnected');
  
  WebSocket? _socket;
  final ValueNotifier<NotificationModel?> notificationNotifier = ValueNotifier(null);
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  
  Future<void> connectWithCookie() async {
    _reconnectTimer?.cancel();
    
    if (_isConnected && _socket != null) {
      print("WebSocket already connected");
      return;
    }
    
    final sessionId = await PrefManager.getUserSessionId();
    final userId = await PrefManager.getUserDevalayId();
    
    if (sessionId == null || sessionId.isEmpty) {
      print("No session ID found, cannot connect to WebSocket");
      _updateConnectionStatus(false, 'No session ID');
      return;
    }
    
    if (userId == null || userId.isEmpty) {
      print("No user ID found, cannot connect to WebSocket");
      _updateConnectionStatus(false, 'No user ID');
      return;
    }
    
    try {
      print("Attempting to connect to WebSocket...");
      _updateConnectionStatus(false, 'Connecting...');
      
      final wsUrl = 'wss://devalay.org/ws/notifications/$userId/';
      print("WebSocket URL: $wsUrl");
      
      _socket = await WebSocket.connect(
        wsUrl,
        headers: {
          'Cookie': 'sessionid=$sessionId',
        },
      );
      
      _isConnected = true;
      _reconnectAttempts = 0;
      _updateConnectionStatus(true, 'Connected');
      print("✅ WebSocket connected successfully");
      
      _socket!.listen(
        (data) {
          _handleSocketMessage(data);
        },
        onError: (error) {
          print("❌ WebSocket error: $error");
          _handleConnectionError(error);
        },
        onDone: () {
          print("🔌 WebSocket connection closed");
          _handleConnectionClosed();
        },
      );
    } catch (e) {
      print("❌ WebSocket connection failed: $e");
      _handleConnectionError(e);
    }
  }
  
  void _updateConnectionStatus(bool connected, String status) {
    _isConnected = connected;
    isConnected.value = connected;
    connectionStatus.value = status;
    print("🔗 WebSocket Status: $status");
  }
  
  void _handleConnectionError(dynamic error) {
    _isConnected = false;
    _updateConnectionStatus(false, 'Error: $error');
    _scheduleReconnect();
  }
  
  void _handleConnectionClosed() {
    _isConnected = false;
    _updateConnectionStatus(false, 'Connection Closed');
    _scheduleReconnect();
  }
  
  void _handleSocketMessage(dynamic data) {
    // Skip connection confirmation messages
    if (data is String &&
        (data == "Connected successfully" ||
            data.contains("connected") ||
            data.contains("Connection"))) {
      print("📡 WebSocket: $data");
      return;
    }
    
    try {
      final decoded = json.decode(data);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('type') &&
            decoded['type'] == 'notification' &&
            decoded.containsKey('message')) {
          print("🔔 Received NEW notification: $decoded");
          
          // Create notification model and notify listeners
          _requestLatestNotifications(decoded);
          
          // ✅ INCREMENT COUNT ONLY FOR NEW NOTIFICATIONS
          incrementNotificationCount();
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error parsing WebSocket message: $e");
      }
    }
  }
  
  void _requestLatestNotifications(Map<String, dynamic> data) {
    // Create a placeholder notification from WebSocket data
    final placeholder = NotificationModel(
      id: data["id"] ?? 0, // Use actual ID if available
      notificationMsge: data["message"],
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      type: data["type"], // Include type if available
    );
    
    // Notify all listeners about new notification
    notificationNotifier.value = placeholder;
    
    print("📬 New notification created: ${placeholder.notificationMsge}");
  }
  
  void incrementNotificationCount() {
    notificationCount.value += 1;
    if (kDebugMode) {
      print("🔢 Notification count INCREASED: ${notificationCount.value}");
    }
    _saveNotificationCount();
  }
  
  void decrementNotificationCount() {
    if (notificationCount.value > 0) {
      notificationCount.value -= 1;
      if (kDebugMode) {
        print("🔢 Notification count DECREASED: ${notificationCount.value}");
      }
      _saveNotificationCount();
    }
  }
  
  void resetNotificationCount() {
    notificationCount.value = 0;
    if (kDebugMode) {
      print("🔢 Notification count RESET to 0");
    }
    _saveNotificationCount();
  }
  
  Future<void> _saveNotificationCount() async {
    await PrefManager.setNotificationCount(notificationCount.value);
  }
  
  Future<void> loadNotificationCount() async {
    final count = await PrefManager.getUnreadNotificationCount() ?? 0;
    notificationCount.value = count;
    print("📊 Loaded notification count from storage: $count");
  }
  
  /// Set notification count directly (used when API returns actual count)
  void setNotificationCount(int count) {
    notificationCount.value = count;
    _saveNotificationCount();
    print("🔢 Notification count SET to: $count");
  }
  
  /// Sync count from API response
  Future<void> syncNotificationCountFromApi(int apiCount) async {
    if (notificationCount.value != apiCount) {
      notificationCount.value = apiCount;
      await _saveNotificationCount();
      print("🔄 Synced notification count from API: $apiCount");
    }
  }
  
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (!_isConnected && _reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      
      print("🔄 Scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${delay.inSeconds}s");
      _updateConnectionStatus(false, 'Reconnecting in ${delay.inSeconds}s...');
      
      _reconnectTimer = Timer(delay, () {
        if (!_isConnected) {
          connectWithCookie();
        }
      });
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      print("❌ Max reconnect attempts reached. Stopping reconnection.");
      _updateConnectionStatus(false, 'Connection Failed - Max attempts reached');
    }
  }
  
  void send(Map<String, dynamic> message) {
    if (_socket != null && _isConnected) {
      try {
        final encoded = json.encode(message);
        _socket?.add(encoded);
        print("📤 Sent message: $message");
      } catch (e) {
        print("❌ Error sending message: $e");
        _handleConnectionError(e);
      }
    } else {
      print("⚠️ WebSocket not connected. Attempting to reconnect...");
      connectWithCookie();
    }
  }
  
  void removeNotification(int notificationId) {
    send({
      "action": "delete",
      "notification_id": notificationId,
    });
    
    print("🗑️ Sent delete request for notification $notificationId");
  }
  
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    
    if (_socket != null) {
      try {
        _socket?.close();
        print("🔌 WebSocket manually disconnected");
      } catch (e) {
        print("❌ Error closing socket: $e");
      }
    }
    _socket = null;
    _isConnected = false;
    _updateConnectionStatus(false, 'Disconnected');
  }
  
  void ping() {
    if (_isConnected) {
      print("🏓 Sending ping...");
      send({"action": "ping"});
    } else {
      print("⚠️ Cannot ping - WebSocket not connected");
    }
  }
  
  // Utility methods
  bool get isWebSocketConnected => _isConnected;
  String get currentConnectionStatus => connectionStatus.value;
  int get reconnectAttempts => _reconnectAttempts;
  
  void forceReconnect() {
    print("🔄 Force reconnecting WebSocket...");
    _reconnectAttempts = 0;
    disconnect();
    connectWithCookie();
  }
  
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
    print("🔄 Reset reconnect attempts");
  }
  
  Future<void> testConnection() async {
    print("🧪 Testing WebSocket connection...");
    final sessionId = await PrefManager.getUserSessionId();
    final userId = await PrefManager.getUserDevalayId();
    
    print("Session ID: ${sessionId ?? 'Not found'}");
    print("User ID: ${userId ?? 'Not found'}");
    
    if (sessionId != null && userId != null) {
      final wsUrl = 'wss://devalay.org/ws/notifications/$userId/';
      print("WebSocket URL: $wsUrl");
      print("Ready to connect!");
    } else {
      print("❌ Missing required data for connection");
    }
  }
}