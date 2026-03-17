import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/feed/notification/notificatio_state.dart';
import 'package:devalay_app/src/data/model/feed/notification_model.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:devalay_app/src/presentation/notification/web_socket/web_socket.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FeedHomeRepo exploreRepo;
  List<NotificationModel> _notifications = [];
  final NotificationSocketService _socketService = NotificationSocketService();
  bool _isSocketListenerAttached = false;
  
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 10;
  
  String _currentType = '';

  NotificationCubit()
      : exploreRepo = getIt<FeedHomeRepo>(),
        super(NotificationInitial());

  Future<void> fetchNotification({
    required bool isRead,
    bool isRefresh = false,
    required String type 
  }) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        _hasMoreData = true;
        _notifications.clear();
        _currentType = type;
      }

      if (_currentPage == 1) {
        emit(NotificationLoaded(
          data: [],
          loadingState: true,
          hasError: false,
          hasMoreData: _hasMoreData,
          isLoadingMore: false,
        ));
      }

      String apiType = _getApiType(type);

      final result = await exploreRepo.getNotificationType(
        page: _currentPage,
        limit: _pageSize,
        type: apiType
      );

      result.fold(
        (failure) {
          emit(NotificationLoaded(
            data: _notifications,
            loadingState: false,
            hasError: true,
            errorMessage: "Something went wrong.",
            hasMoreData: _hasMoreData,
            isLoadingMore: false,
          ));
        },
        (customResponse) async {
          final responseData = customResponse.response?.data;

          print("📦 API Response type: ${responseData.runtimeType}");

          if (responseData is String && responseData.contains("No Results Found")) {
            _hasMoreData = false;
            // No notifications means 0 unread
            if (_currentPage == 1) {
              _socketService.setNotificationCount(0);
            }
            emit(NotificationLoaded(
              data: _notifications,
              loadingState: false,
              hasError: false,
              hasMoreData: false,
              isLoadingMore: false,
            ));
            return;
          }

          if (responseData is Map<String, dynamic>) {
            final results = responseData['results'];
            
            // ✅ Check if API returns unread_count directly
            final apiUnreadCount = responseData['unread_count'];
            
            if (results is List) {
              final parsedData = results
                  .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                  .toList();

              _hasMoreData = parsedData.length == _pageSize;
              
              if (_currentPage == 1) {
                _notifications = parsedData;
              } else {
                _notifications.addAll(parsedData);
              }
              
              // ✅ UPDATE NOTIFICATION COUNT - prefer API count if available
              if (apiUnreadCount != null && apiUnreadCount is int) {
                _socketService.setNotificationCount(apiUnreadCount);
                print("📋 Using API unread count: $apiUnreadCount");
              } else if (_currentPage == 1) {
                // Only calculate from list on first page to avoid incorrect counts
                int unreadCount = parsedData.where((n) => !(n.isRead ?? false)).length;
                _socketService.setNotificationCount(unreadCount);
                print("📋 Calculated unread count from page 1: $unreadCount");
              }
              
              print("📋 Fetched ${parsedData.length} notifications, total: ${_notifications.length}");
              
              emit(NotificationLoaded(
                data: List.from(_notifications),
                loadingState: false,
                hasError: false,
                hasMoreData: _hasMoreData,
                isLoadingMore: false,
              ));
              return;
            }
          }

          if (responseData is List) {
            final parsedData = responseData
                .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                .toList();

            _hasMoreData = parsedData.length == _pageSize;
            
            if (_currentPage == 1) {
              _notifications = parsedData;
              
              // ✅ UPDATE NOTIFICATION COUNT only on first page
              int unreadCount = parsedData.where((n) => !(n.isRead ?? false)).length;
              _socketService.setNotificationCount(unreadCount);
              print("📋 Calculated unread count: $unreadCount");
            } else {
              _notifications.addAll(parsedData);
            }
            
            print("📋 Fetched ${parsedData.length} notifications, total: ${_notifications.length}");
            
            emit(NotificationLoaded(
              data: List.from(_notifications),
              loadingState: false,
              hasError: false,
              hasMoreData: _hasMoreData,
              isLoadingMore: false,
            ));
            return;
          }

          print("❌ Unexpected response format: ${responseData.runtimeType}");
          emit(NotificationLoaded(
            data: _notifications,
            loadingState: false,
            hasError: true,
            errorMessage: "Unexpected data format from the server.",
            hasMoreData: _hasMoreData,
            isLoadingMore: false,
          ));
        },
      );
    } catch (e, stackTrace) {
      print("❌ Notification fetch failed: $e\n$stackTrace");
      emit(NotificationLoaded(
        data: _notifications,
        loadingState: false,
        hasError: true,
        errorMessage: "Something went wrong. Please try again.",
        hasMoreData: _hasMoreData,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    
    emit(NotificationLoaded(
      data: List.from(_notifications),
      loadingState: false,
      hasError: false,
      hasMoreData: _hasMoreData,
      isLoadingMore: true,
    ));

    _currentPage++;
    
    try {
      String apiType = _getApiType(_currentType);
      
      final result = await exploreRepo.getNotificationType(
        page: _currentPage,
        limit: _pageSize,
        type: apiType
      );

      result.fold(
        (failure) {
          _currentPage--;
          emit(NotificationLoaded(
            data: List.from(_notifications),
            loadingState: false,
            hasError: true,
            errorMessage: "Failed to load more notifications.",
            hasMoreData: _hasMoreData,
            isLoadingMore: false,
          ));
        },
        (customResponse) {
          final responseData = customResponse.response?.data;
          
          if (responseData is Map<String, dynamic>) {
            final results = responseData['results'];
            if (results is List && results.isNotEmpty) {
              final parsedData = results
                  .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                  .toList();

              _hasMoreData = parsedData.length == _pageSize;
              _notifications.addAll(parsedData);
              
              print("📋 Loaded ${parsedData.length} more notifications, total: ${_notifications.length}");
            } else {
              _hasMoreData = false;
            }
          }
          else if (responseData is List && responseData.isNotEmpty) {
            final parsedData = responseData
                .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                .toList();

            _hasMoreData = parsedData.length == _pageSize;
            _notifications.addAll(parsedData);
            
            print("📋 Loaded ${parsedData.length} more notifications, total: ${_notifications.length}");
          } else {
            _hasMoreData = false;
          }

          emit(NotificationLoaded(
            data: List.from(_notifications),
            loadingState: false,
            hasError: false,
            hasMoreData: _hasMoreData,
            isLoadingMore: false,
          ));
        },
      );
    } catch (e) {
      _currentPage--;
      print("❌ Load more notifications failed: $e");
      
      emit(NotificationLoaded(
        data: List.from(_notifications),
        loadingState: false,
        hasError: true,
        errorMessage: "Failed to load more notifications.",
        hasMoreData: _hasMoreData,
        isLoadingMore: false,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  String _getApiType(String tabType) {
    switch (tabType.toLowerCase()) {
      case 'all':
        return 'all';
      case 'temple':
        return 'Temple';
      case 'people':
        return 'People';
      case 'event':
        return 'Event';
      case 'god':
        return 'God';
      case 'dashboard':
        return 'Dashboard';
      default:
        return '';
    }
  }

  void connectToSocketWithSession() {
    _socketService.connectWithCookie();
    
    if (_isSocketListenerAttached) {
      _socketService.notificationNotifier.removeListener(_onNewNotification);
      _isSocketListenerAttached = false;
    }
    
    _socketService.notificationNotifier.addListener(_onNewNotification);
    _isSocketListenerAttached = true;
    
    print("✅ Socket listener attached for new notifications");
  }
  
  void _onNewNotification() {
    try {
      final notification = _socketService.notificationNotifier.value;
      if (notification == null) return;
      
      print("🆕 Processing new notification: ${notification.notificationMsge}");
      
      // Check if notification already exists
      final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
      
      if (existingIndex >= 0) {
        // Update existing notification
        _notifications[existingIndex] = notification;
        print("♻️ Updated existing notification at index $existingIndex");
      } else {
        // Add new notification at the beginning
        _notifications.insert(0, notification);
        print("➕ Added NEW notification to list (Count is already incremented by socket service)");
      }
      
      // Emit updated list
      emit(NotificationLoaded(
        data: List.from(_notifications),
        loadingState: false,
        hasError: false,
        hasMoreData: _hasMoreData,
        isLoadingMore: _isLoadingMore,
      ));
      
      print("✅ Notification list updated, total notifications: ${_notifications.length}");
    } catch (e) {
      print("❌ Socket notification handling failed: $e");
    }
  }

  Future<void> markAsRead() async {
    try {
      final result = await exploreRepo.notificationReadAndUnReadPost();

      result.fold(
        (failure) {
          print("❌ Mark all as read API failed: $failure");
        },
        (success) {
          print("✅ Mark all as read API success");
          
          // Update local state
      final updatedNotifications = _notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      _notifications = updatedNotifications;
          
          // Reset notification count
          _socketService.resetNotificationCount();

      emit(NotificationLoaded(
        data: List.from(_notifications),
        loadingState: false,
        hasError: false,
        hasMoreData: _hasMoreData,
        isLoadingMore: _isLoadingMore,
      ));
        },
      );
    } catch (e) {
      print("❌ Mark as read failed: $e");
    }
  }

  Future<void> markSingleAsRead(int notificationId) async {
    try {
      // Call API first
      final result = await exploreRepo.markSingleNotificationAsRead(notificationId);
      
      result.fold(
        (failure) {
          print("❌ Mark notification $notificationId as read failed: $failure");
        },
        (success) {
          print("✅ Marked notification $notificationId as read");
          
          // Update local state only after API success
      final updatedNotifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          if (!(notification.isRead ?? false)) {
            _socketService.decrementNotificationCount();
          }
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      _notifications = updatedNotifications;

      emit(NotificationLoaded(
        data: List.from(_notifications),
        loadingState: false,
        hasError: false,
        hasMoreData: _hasMoreData,
        isLoadingMore: _isLoadingMore,
      ));
        },
      );
    } catch (e) {
      print("❌ Mark single as read failed: $e");
    }
  }

  void removeNotification(int notificationId) {
    final notification = _notifications.firstWhere(
      (notification) => notification.id == notificationId,
      orElse: () => NotificationModel(),
    );
    
    if (notification.id != null && !(notification.isRead ?? false)) {
      _socketService.decrementNotificationCount();
    }
    
    _socketService.removeNotification(notificationId);
    _notifications.removeWhere((notification) => notification.id == notificationId);

    emit(NotificationLoaded(
      data: List.from(_notifications),
      loadingState: false,
      hasError: false,
      hasMoreData: _hasMoreData,
      isLoadingMore: _isLoadingMore,
    ));
  }
  
  Future<void> markAllAsRead() async {
    // markAsRead now handles both API call and count reset
    await markAsRead();
  }
  
  @override
  Future<void> close() {
    if (_isSocketListenerAttached) {
      _socketService.notificationNotifier.removeListener(_onNewNotification);
    }
    return super.close();
  }
}