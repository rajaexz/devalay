import 'dart:async';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_state.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/feed/feed_home_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final FeedHomeRepo feedHomeRepo;
  StreamSubscription? updateSubscription;
  List<FeedGetData> allData = [];
  FeedGetData? event;
  int page = 1;
  String? _userId;
  bool hasMoreData = true;

  ProfileCubit()
      : profileRepo = getIt<ProfileRepo>(),
        feedHomeRepo = getIt<FeedHomeRepo>(),
        super(ProfileInitial());

  void init(String id) {
    _userId = id;
    fetchProfileData();
  }

  Future<void> feedPostFollowing({
    required int followingUserId,
    required int userId,
    required int postId,
    required bool isFollowing,
    required int clickedPostIndex,
  }) async {
    try {
      if (clickedPostIndex >= 0 && clickedPostIndex < allData.length) {
        final List<FeedGetData> updatedList = List.from(allData);
        final oldPost = updatedList[clickedPostIndex].user;

        updatedList[clickedPostIndex] = updatedList[clickedPostIndex].copyWith(
          user: oldPost?.copyWith(
            following: isFollowing,
            followingRequests: isFollowing,
          ),
        );

        allData = updatedList;
        setScreenState(isLoading: false, data: updatedList);
      }

      final result = await feedHomeRepo.feedPostFollowing(
        followingUserId,
        userId,
        isFollowing,
      );

      result.fold(
        (failure) {
          Logger.log("Follow failed: ${failure.toString()}");

          if (clickedPostIndex >= 0 && clickedPostIndex < allData.length) {
            final List<FeedGetData> revertList = List.from(allData);
            final oldPost = revertList[clickedPostIndex].user;

            revertList[clickedPostIndex] =
                revertList[clickedPostIndex].copyWith(
              user: oldPost?.copyWith(
                following: !isFollowing,
                followingRequests: !isFollowing,
              ),
            );

            allData = revertList;
            setScreenState(
              isLoading: false,
              data: revertList,
              message: "Failed to update follow status",
              hasError: true,
            );
          }
        },
        (customResponse) async {},
      );
    } catch (e) {
      Logger.log("Follow operation failed: ${e.toString()}");
      setScreenState(
        isLoading: false,
        message: "An error occurred",
        hasError: true,
      );
    }
  }

  // OPTIMIZED SAVE METHOD - Only updates necessary data
  Future<void> feedPostSaved(String postId, bool isSave) async {
    try {
      // Update local data immediately for better UX
      _updateLocalSaveData(postId, isSave);

      // Make API call
      final result =
          await feedHomeRepo.feedPostSavedData(postId, isSave.toString());

      result.fold(
        (failure) {
          Logger.log("Save failed: ${failure.toString()}");
          // Revert local changes on failure
          _updateLocalSaveData(postId, !isSave);
          
          // Only show error, don't emit full state
          _showTemporaryError("Failed to update save status");
        },
        (customResponse) async {
          // Update with server response
          final updatedPost =
              FeedGetData.fromJson(customResponse.response!.data);
          _updateLocalSaveDataFromServer(postId, updatedPost);
        },
      );
    } catch (e) {
      Logger.log("Save operation failed: ${e.toString()}");
      // Revert local changes on exception
      _updateLocalSaveData(postId, !isSave);
      _showTemporaryError("An error occurred");
    }
  }

  Future<void> feedPostDelete(int postId) async {
    try {
      final currentState = state;
      FeedGetData? singleFeedData;

      if (currentState is ProfileLoaded && currentState.singleFeed != null) {
        singleFeedData = currentState.singleFeed;
      }

      final List<FeedGetData> originalData = List.from(allData);
      FeedGetData? originalSingleFeed = singleFeedData;

      final List<FeedGetData> updatedList = List.from(allData);
      final index = updatedList.indexWhere((post) => post.id == postId);

      if (index != -1) {
        updatedList.removeAt(index);
        allData = updatedList;
      }

      if (singleFeedData != null && singleFeedData.id == postId) {
        singleFeedData = null;
      }

      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(
            loadingState: false,
            errorMessage: currentState.errorMessage,
            hasError: currentState.hasError,
            feedList: updatedList,
            singleFeed: singleFeedData));
      }

      // Check if we can pop before attempting to pop
      if (AppRouter.canPop()) {
        AppRouter.pop();
      }

      final result = await feedHomeRepo.feedPostDeteleData(postId.toString());

      result.fold(
        (failure) {
          Logger.log("Delete failed: ${failure.toString()}");

          // 404 Not Found = post already deleted on server; treat as success and keep list updated
          final isNotFound = failure == Failure.notFound ||
              failure.errorMessage == Failure.notFound.errorMessage;
          if (isNotFound) {
            if (currentState is ProfileLoaded) {
              emit(ProfileLoaded(
                  loadingState: false,
                  errorMessage: '',
                  hasError: false,
                  feedList: allData,
                  singleFeed: singleFeedData));
            }
            return;
          }

          allData = originalData;

          if (currentState is ProfileLoaded) {
            emit(ProfileLoaded(
                loadingState: false,
                errorMessage: "Failed to delete post",
                hasError: true,
                feedList: originalData,
                singleFeed: originalSingleFeed));
          }
        },
        (customResponse) async {
          if (currentState is ProfileLoaded) {
            emit(ProfileLoaded(
                loadingState: false,
                errorMessage: '',
                hasError: false,
                feedList: allData,
                singleFeed: singleFeedData));
          }
        },
      );
    } catch (e) {
      Logger.log("Delete operation failed: ${e.toString()}");

      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(
            loadingState: false,
            errorMessage: "An error occurred",
            hasError: true,
            feedList: currentState.feedList,
            singleFeed: currentState.singleFeed));
      }
    }
  }

  Future<void> fetchProfileData(
      {bool loadMoreData = false, bool upDateData = false}) async {
    if (_userId == null) return;
    if (!hasMoreData && loadMoreData) return;

    !upDateData ? setScreenState(isLoading: true, data: allData) : null;

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData.clear();
    }

    final result = await profileRepo.fetchProfileData(page, _userId.toString());
    result.fold((failure) {
      setScreenState(isLoading: false, data: allData);
    }, (customResponse) {
      // Add null safety check for response
      if (customResponse.response?.data == null) {
        setScreenState(isLoading: false, data: allData);
        return;
      }
      
      try {
        final responseData = customResponse.response!.data;
        
        // Check if response data is a list
        if (responseData is List) {
          final data = FeedGetData.fromList(responseData);
          if (!loadMoreData) allData.clear();
          allData.addAll(data);
          hasMoreData = data.isNotEmpty;
          setScreenState(isLoading: false, data: allData);
        } else {
          // Handle unexpected response format
          setScreenState(isLoading: false, data: allData);
        }
      } catch (e) {
        // Handle parsing errors
        setScreenState(isLoading: false, data: allData);
      }
    });

    if (upDateData) {
      result.fold((failure) {
        setScreenState(isLoading: false, data: allData);
      }, (customResponse) {
        // Add null safety check for response
        if (customResponse.response?.data == null) {
          setScreenState(isLoading: false, data: allData);
          return;
        }
        
        try {
          final responseData = customResponse.response!.data;
          
          // Check if response data is a list and get first item
          if (responseData is List && responseData.isNotEmpty) {
            final updatedPost = FeedGetData.fromJson(responseData[0] as Map<String, dynamic>);
            
            final updatedList = allData.map((post) {
              if (post.id == updatedPost.id) {
                return updatedPost;
              }
              return post;
            }).toList();

            setScreenState(
              isLoading: false,
              data: updatedList,
            );
          } else if (responseData is Map) {
            // Handle single object response
            final updatedPost = FeedGetData.fromJson(responseData as Map<String, dynamic>);
            
            final updatedList = allData.map((post) {
              if (post.id == updatedPost.id) {
                return updatedPost;
              }
              return post;
            }).toList();

            setScreenState(
              isLoading: false,
              data: updatedList,
            );
          } else {
            setScreenState(isLoading: false, data: allData);
          }
        } catch (e) {
          // Handle parsing errors
          setScreenState(isLoading: false, data: allData);
        }
      });
    }
  }

  // OPTIMIZED LIKE METHOD - Only updates necessary data
  Future<void> feedPostLike2(
      String postId, bool isLike, BuildContext context) async {
    try {
      // Update local data immediately for better UX
      _updateLocalLikeData(postId, isLike);

      // Make API call
      final result =
          await feedHomeRepo.feedPostLikeData(postId, isLike.toString());

      result.fold(
        (failure) {
          Logger.log("Like failed: ${failure.toString()}");
          // Revert local changes on failure
          _updateLocalLikeData(postId, !isLike);
          
          // Only show error, don't emit full state
          _showTemporaryError("Failed to update like status");
        },
        (customResponse) async {
          // Update with server response
          final apiData = FeedGetData.fromJson(customResponse.response!.data);
          _updateLocalLikeDataFromServer(postId, apiData);
        },
      );
    } catch (e) {
      Logger.log("Like operation failed: ${e.toString()}");
      // Revert local changes on exception
      _updateLocalLikeData(postId, !isLike);
      _showTemporaryError("An error occurred");
    }
  }

  // Helper method to update local like data without emitting full state
  void _updateLocalLikeData(String postId, bool isLike) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    bool hasChanges = false;
    FeedGetData? singleFeedData = currentState.singleFeed;
    List<FeedGetData> updatedList = List.from(allData);

    // Update in list
    final index = updatedList.indexWhere((post) => post.id.toString() == postId);
    if (index != -1) {
      final oldPost = updatedList[index];
      final newLikeCount = isLike
          ? (oldPost.likedCount ?? 0) + 1
          : (oldPost.likedCount ?? 0) - 1;

      updatedList[index] = oldPost.copyWith(
        liked: isLike,
        likedCount: newLikeCount < 0 ? 0 : newLikeCount,
      );
      hasChanges = true;
    }

    // Update single feed if exists
    if (singleFeedData != null && singleFeedData.id.toString() == postId) {
      final newLikeCount = isLike
          ? (singleFeedData.likedCount ?? 0) + 1
          : (singleFeedData.likedCount ?? 0) - 1;

      singleFeedData = singleFeedData.copyWith(
        liked: isLike,
        likedCount: newLikeCount < 0 ? 0 : newLikeCount,
      );
      hasChanges = true;
    }

    // Only emit if there were actual changes
    if (hasChanges) {
      allData = updatedList;
      emit(ProfileLoaded(
        loadingState: false,
        errorMessage: '',
        hasError: false,
        feedList: updatedList,
        singleFeed: singleFeedData,
      ));
    }
  }

  // Helper method to update with server data
  void _updateLocalLikeDataFromServer(String postId, FeedGetData apiData) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    bool hasChanges = false;
    FeedGetData? singleFeedData = currentState.singleFeed;
    List<FeedGetData> updatedList = List.from(allData);

    // Update in list with server data
    final index = updatedList.indexWhere((post) => post.id.toString() == postId);
    if (index != -1) {
      final oldPost = updatedList[index];
      updatedList[index] = oldPost.copyWith(
        liked: apiData.liked,
        likedCount: apiData.likedCount,
        commentsCount: apiData.commentsCount,
      );
      hasChanges = true;
    }

    // Update single feed with server data
    if (singleFeedData != null && singleFeedData.id.toString() == postId) {
      singleFeedData = singleFeedData.copyWith(
        liked: apiData.liked,
        likedCount: apiData.likedCount,
        commentsCount: apiData.commentsCount,
      );
      hasChanges = true;
    }

    // Only emit if there were actual changes
    if (hasChanges) {
      allData = updatedList;
      emit(ProfileLoaded(
        loadingState: false,
        errorMessage: '',
        hasError: false,
        feedList: updatedList,
        singleFeed: singleFeedData,
      ));
    }
  }

  // Helper method to update local save data without emitting full state
  void _updateLocalSaveData(String postId, bool isSave) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    bool hasChanges = false;
    FeedGetData? singleFeedData = currentState.singleFeed;
    List<FeedGetData> updatedList = List.from(allData);

    // Update in list
    final index = updatedList.indexWhere((post) => post.id.toString() == postId);
    if (index != -1) {
      final oldPost = updatedList[index];
      updatedList[index] = oldPost.copyWith(saved: isSave);
      hasChanges = true;
    }

    // Update single feed if exists
    if (singleFeedData != null && singleFeedData.id.toString() == postId) {
      singleFeedData = singleFeedData.copyWith(saved: isSave);
      hasChanges = true;
    }

    // Only emit if there were actual changes
    if (hasChanges) {
      allData = updatedList;
      emit(ProfileLoaded(
        loadingState: false,
        errorMessage: '',
        hasError: false,
        feedList: updatedList,
        singleFeed: singleFeedData,
      ));
    }
  }

  // Helper method to update save data with server data
  void _updateLocalSaveDataFromServer(String postId, FeedGetData updatedPost) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    bool hasChanges = false;
    FeedGetData? singleFeedData = currentState.singleFeed;
    List<FeedGetData> updatedList = allData.map((post) {
      if (post.id.toString() == postId) {
        hasChanges = true;
        return updatedPost;
      }
      return post;
    }).toList();

    // Update single feed with server data
    if (singleFeedData != null && singleFeedData.id.toString() == postId) {
      singleFeedData = updatedPost;
      hasChanges = true;
    }

    // Only emit if there were actual changes
    if (hasChanges) {
      allData = updatedList;
      emit(ProfileLoaded(
        loadingState: false,
        errorMessage: '',
        hasError: false,
        feedList: updatedList,
        singleFeed: singleFeedData,
      ));
    }
  }

  // Helper method to show temporary error without full state rebuild
  void _showTemporaryError(String message) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(
        loadingState: false,
        errorMessage: message,
        hasError: true,
        feedList: currentState.feedList,
        singleFeed: currentState.singleFeed,
      ));
      
      // Clear error after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (state is ProfileLoaded) {
          final current = state as ProfileLoaded;
          emit(ProfileLoaded(
            loadingState: current.loadingState,
            errorMessage: '',
            hasError: false,
            feedList: current.feedList,
            singleFeed: current.singleFeed,
          ));
        }
      });
    }
  }

  Future<void> fetchMediaInfoData(String id) async {
    final result = await profileRepo.fetchMediaInfoData(id);
    result.fold((failure) {
      setScreenState(isLoading: false, singleData: event);
    }, (customResponse) {
      final data = FeedGetData.fromJson(customResponse.response!.data);
      setScreenState(isLoading: true, singleData: data);
    });
  }

  void setScreenState(
      {List<FeedGetData>? data,
      FeedGetData? singleData,
      required bool isLoading,
      String? message,
      bool hasError = false}) {
    emit(ProfileLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        hasError: hasError,
        feedList: data,
        singleFeed: singleData));
  }

  @override
  Future<void> close() {
    updateSubscription?.cancel();
    return super.close();
  }
}