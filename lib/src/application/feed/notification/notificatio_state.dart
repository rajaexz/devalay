import 'package:devalay_app/src/data/model/feed/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel>? data;
  final bool loadingState;
  final bool hasError;
  final String? errorMessage;
  final bool hasMoreData;
  final bool isLoadingMore;

  NotificationLoaded({
    required this.data,
    required this.loadingState,
    required this.hasError,
    this.errorMessage,
    required this.hasMoreData,
    required this.isLoadingMore,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? data,
    bool? loadingState,
    bool? hasError,
    String? errorMessage,
    bool? hasMoreData,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      data: data ?? this.data,
      loadingState: loadingState ?? this.loadingState,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}