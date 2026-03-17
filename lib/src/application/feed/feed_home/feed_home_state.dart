import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class FeedHomeState {}

class FeedHomeInitial extends FeedHomeState {}

class FeedHomeLoaded extends FeedHomeState {
  final List<XFile>? selectedMedia;
  final List<FeedGetData>? feedList;
  final FeedGetData? singleFeed;
  final bool loadingState;
  final bool hasError;
  final String errorMessage;
  final bool isAuthError; // New field to specifically identify auth errors

  final List<dynamic> locationResults;
  final bool locationLoading;
  final String? locationError;

  FeedHomeLoaded({
    this.feedList,
    this.singleFeed,
    this.selectedMedia,
    required this.loadingState,
    this.hasError = false,
    this.errorMessage = '',
    this.isAuthError = false, // Initialize auth error flag
    // Initialize location fields
    this.locationResults = const [],
    this.locationLoading = false,
    this.locationError,
  });

  FeedHomeLoaded copyWith({
    List<XFile>? selectedMedia,
    List<FeedGetData>? feedList,
    FeedGetData? singleFeed,
    bool? loadingState,
    bool? hasError,
    String? errorMessage,
    bool? isAuthError, // Add to copyWith
    // Location fields
    List<dynamic>? locationResults,
    bool? locationLoading,
    String? locationError,
  }) {
    return FeedHomeLoaded(
      selectedMedia: selectedMedia ?? this.selectedMedia,
      feedList: feedList ?? this.feedList,
      singleFeed: singleFeed ?? this.singleFeed,
      loadingState: loadingState ?? this.loadingState,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthError: isAuthError ?? this.isAuthError, // Include in copyWith
      // Location fields
      locationResults: locationResults ?? this.locationResults,
      locationLoading: locationLoading ?? this.locationLoading,
      locationError: locationError ?? this.locationError,
    );
  }

  // Helper method to create error state
  static FeedHomeLoaded error({
    required String errorMessage,
    bool isAuthError = false,
    List<XFile>? selectedMedia,
    List<FeedGetData>? feedList,
    FeedGetData? singleFeed,
    List<dynamic> locationResults = const [],
    bool locationLoading = false,
    String? locationError,
  }) {
    return FeedHomeLoaded(
      selectedMedia: selectedMedia,
      feedList: feedList,
      singleFeed: singleFeed,
      loadingState: false,
      hasError: true,
      errorMessage: errorMessage,
      isAuthError: isAuthError,
      locationResults: locationResults,
      locationLoading: locationLoading,
      locationError: locationError,
    );
  }

  // Helper method to create authentication error state
  static FeedHomeLoaded authError({
    String errorMessage = 'Authentication credentials were not provided',
    List<XFile>? selectedMedia,
    List<FeedGetData>? feedList,
    FeedGetData? singleFeed,
    List<dynamic> locationResults = const [],
    bool locationLoading = false,
    String? locationError,
  }) {
    return FeedHomeLoaded(
      selectedMedia: selectedMedia,
      feedList: feedList,
      singleFeed: singleFeed,
      loadingState: false,
      hasError: true,
      errorMessage: errorMessage,
      isAuthError: true, // Specifically mark as auth error
      locationResults: locationResults,
      locationLoading: locationLoading,
      locationError: locationError,
    );
  }

  // Helper method to create success state
  static FeedHomeLoaded success({
    List<XFile>? selectedMedia,
    List<FeedGetData>? feedList,
    FeedGetData? singleFeed,
    bool loadingState = false,
    List<dynamic> locationResults = const [],
    bool locationLoading = false,
    String? locationError,
  }) {
    return FeedHomeLoaded(
      selectedMedia: selectedMedia,
      feedList: feedList,
      singleFeed: singleFeed,
      loadingState: loadingState,
      hasError: false,
      errorMessage: '',
      isAuthError: false,
      locationResults: locationResults,
      locationLoading: locationLoading,
      locationError: locationError,
    );
  }

  // Helper method to create loading state
  static FeedHomeLoaded loading({
    List<XFile>? selectedMedia,
    List<FeedGetData>? feedList,
    FeedGetData? singleFeed,
    List<dynamic> locationResults = const [],
    bool locationLoading = false,
    String? locationError,
  }) {
    return FeedHomeLoaded(
      selectedMedia: selectedMedia,
      feedList: feedList,
      singleFeed: singleFeed,
      loadingState: true,
      hasError: false,
      errorMessage: '',
      isAuthError: false,
      locationResults: locationResults,
      locationLoading: locationLoading,
      locationError: locationError,
    );
  }
}