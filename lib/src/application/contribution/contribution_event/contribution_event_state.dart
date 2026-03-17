import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';
import '../../../data/model/contribution/contribution_event_model.dart';
abstract class ContributeEventState {}

class ContributeEventInitial extends ContributeEventState {}

class ContributeEventLoaded extends ContributeEventState {
  final bool loadingState;
  final bool backgroundLoading; 
  final String errorMessage;
  final List<ContributionEventModel>? eventList;
  final String? eventId;
  final ContributionEventModel? singleEvent;
  final AcceptBannerModel? acceptBannerModel;
  final CommonModel? commonModel;
  final bool hasError;
  final int currentPage;

  ContributeEventLoaded({
    required this.loadingState,
    this.backgroundLoading = false, // Default to false
    required this.errorMessage,
    this.eventList,
    this.eventId,
    this.singleEvent,
    this.acceptBannerModel,
    this.commonModel,
    required this.hasError,
    required this.currentPage,
  });

  // Add copyWith method for easier state updates
  ContributeEventLoaded copyWith({
    bool? loadingState,
    bool? backgroundLoading,
    String? errorMessage,
    List<ContributionEventModel>? eventList,
    String? eventId,
    ContributionEventModel? singleEvent,
    AcceptBannerModel? acceptBannerModel,
    CommonModel? commonModel,
    bool? hasError,
    int? currentPage,
  }) {
    return ContributeEventLoaded(
      loadingState: loadingState ?? this.loadingState,
      backgroundLoading: backgroundLoading ?? this.backgroundLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      eventList: eventList ?? this.eventList,
      eventId: eventId ?? this.eventId,
      singleEvent: singleEvent ?? this.singleEvent,
      acceptBannerModel: acceptBannerModel ?? this.acceptBannerModel,
      commonModel: commonModel ?? this.commonModel,
      hasError: hasError ?? this.hasError,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ContributeEventError extends ContributeEventState {
  final String message;
  final bool isPermissionDenied;

  ContributeEventError({
    required this.message,
    this.isPermissionDenied = false,
  });
}