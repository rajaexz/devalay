// The rest of your imports...
import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/feed/Report_reason_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_gallery_screen.dart';
import 'package:devalay_app/src/presentation/landing_screen.dart/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class FeedHomeCubit extends Cubit<FeedHomeState> {
  FeedHomeCubit()
      : feedHomeRepo = getIt<FeedHomeRepo>(),
        super(FeedHomeInitial());
  QuillController commentController = QuillController.basic();
  final formKey = GlobalKey<FormState>();
  final postController = TextEditingController();
  final FeedHomeRepo feedHomeRepo;
  bool isPostLoad = false;

  int charCount = 0;
  List<XFile> selectedMedia = [];
  List<String> deletePost = [];
  bool deletePostLoader = false;

  bool isLike = false;

  List<FeedGetData> allData = [];
  FeedGetData singelData = FeedGetData();

  // --- Location search variables ---
  List<dynamic> locationResults = [];
  bool locationLoading = false;
  String? locationError;
  // --- End of location search variables ---

  // report reason
  List<ReportReason> reportReasons = [];
  int page = 1;
  bool hasMoreData = true;
  List<int> blockedPostIds = [];

  List<int> blockedMediaIds = [];


  void removeMedia(int index) {
    selectedMedia.removeAt(index);
    setScreenState(isLoading: false, data: allData);
  }

  navigateToGallery(context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstagramGalleryPicker(
          onMediaSelected: (List<XFile> media) {
            selectedMedia.addAll(media);
          },
        ),
      ),
    );
    setScreenState(isLoading: false, data: allData);
  }

Future<void> fetchFeedHomeData({
  bool loadMoreData = false,
  bool upDateData = false,
}) async {
  // Don't load more if we've already determined there's no more data
  if (!hasMoreData && loadMoreData) {
    Logger.log("No more data to load");
    return;
  }

  // Don't show loading indicator when updating data
  if (!upDateData) {
    setScreenState(isLoading: true, data: allData);
  }

  // Handle pagination
  if (loadMoreData) {
    page++;
  } else {
    page = 1;
    allData.clear();
    hasMoreData = true; // Reset hasMoreData when refreshing
  }

  Logger.log("Fetching feed data - Page: $page, LoadMore: $loadMoreData");

  final result = await feedHomeRepo.fetchFeedHomeDataData(page, type: '');

  result.fold(
    (failure) {
      // Revert page increment on failure
      if (loadMoreData) {
        page--;
      }
      
      Logger.log("Failed to load feed: ${failure.toString()}");
      setScreenState(
        isLoading: false,
        data: allData,
        message: "Failed to load feed",
        hasError: true,
      );
    },
    (customResponse) {
      final responseData = customResponse.response?.data;

      // Check for "Invalid page" response
      if (responseData is Map && 
          responseData.containsKey("detail") && 
          responseData["detail"] == "Invalid page.") {
        hasMoreData = false;
        
        // Revert page increment since this page doesn't exist
        if (loadMoreData) {
          page--;
        }
        
        Logger.log("Reached end of feed data");
        setScreenState(isLoading: false, data: allData);
        return;
      }

      // Handle valid response
      if (responseData is List) {
        final newData = FeedGetData.fromList(responseData);
        
        // Check if we received any data
        if (newData.isEmpty) {
          hasMoreData = false;
          Logger.log("No more data available");
        } else {
          // Only clear if not loading more
          if (!loadMoreData) {
            allData.clear();
          }
          
          allData.addAll(newData);
          
          // If we received fewer items than expected, we might be at the end
          // Adjust this number based on your API's page size
          if (newData.length < 7) {
            hasMoreData = false;
            Logger.log("Received less data than expected, might be at end");
          }
        }
        
        Logger.log("Loaded ${newData.length} posts. Total: ${allData.length}");
        setScreenState(isLoading: false, data: allData);
      } else {
        Logger.log("Unexpected response format: $responseData");
        
        // Revert page increment on unexpected format
        if (loadMoreData) {
          page--;
        }
        
        setScreenState(
          isLoading: false,
          data: allData,
          message: "Invalid response format",
          hasError: true,
        );
      }
    },
  );

  // Handle update data scenario
  if (upDateData) {
    result.fold(
      (failure) {
        setScreenState(isLoading: false, data: allData);
      },
      (customResponse) {
        final responseData = customResponse.response?.data;
        if (responseData is List && responseData.isNotEmpty) {
          try {
            final updatedPost = FeedGetData.fromJson(responseData[0]);
            final updatedList = allData.map((post) {
              if (post.id == updatedPost.id) {
                return updatedPost;
              }
              return post;
            }).toList();
            
            allData = updatedList;
            setScreenState(isLoading: false, data: updatedList);
          } catch (e) {
            Logger.log("Error updating post: $e");
            setScreenState(isLoading: false, data: allData);
          }
        }
      },
    );
  }
}
 
 Future<void> incrementPostView(int postId) async {
    try {
      // First update the local state optimistically
      final indexInList = allData.indexWhere((post) => post.id == postId);
      if (indexInList != -1) {
        // Handle eyes as Object and convert to int safely
        final currentEyes = allData[indexInList].eyes;
        int eyesCount = 0;
        
        if (currentEyes != null) {
          if (currentEyes is int) {
            eyesCount = int.parse(allData[indexInList].eyes.toString());
          } else          eyesCount = int.tryParse(currentEyes) ?? 0;
        
        }
        
        final updatedPost = allData[indexInList].copyWith(
          eyes: (eyesCount + 1).toString(),
        );
        allData[indexInList] = updatedPost;
        setScreenState(isLoading: false, data: allData);
      }

      // Then make the API call
      final result = await feedHomeRepo.incrementPostView(postId);
      
      result.fold(
        (failure) {
          // If API fails, revert the optimistic update
          if (indexInList != -1) {
            final currentEyes = allData[indexInList].eyes;
            int eyesCount = 1; // Default to 1 since we added 1 before
            
            if (currentEyes != null) {
              if (currentEyes is int) {
                eyesCount = int.parse(allData[indexInList].eyes.toString());
              } else if (currentEyes is int) {
                eyesCount = int.tryParse(currentEyes) ?? 1;
              } else {
                eyesCount = int.tryParse(currentEyes.toString()) ?? 1;
              }
            }
            
            final revertedPost = allData[indexInList].copyWith(
              eyes: (eyesCount > 0 ? eyesCount - 1 : 0).toString(),
            );
            allData[indexInList] = revertedPost;
            setScreenState(isLoading: false, data: allData);
          }
          Logger.log("View increment failed: ${failure.toString()}");
        },
        (customResponse) {
          // Success - update with actual data from API if needed
          if (customResponse.response?.data != null) {
            try {
              final updatedPostData = FeedGetData.fromJson(customResponse.response!.data);
              if (indexInList != -1) {
                allData[indexInList] = updatedPostData;
                setScreenState(isLoading: false, data: allData);
              }
            } catch (e) {
              // If parsing fails, keep the optimistic update
              Logger.log("Failed to parse updated post data: $e");
            }
          }
          Logger.log("Post view incremented successfully for post $postId");
        },
      );
    } catch (e) {
      Logger.log("Error incrementing post view: $e");
    }
  }




Future<void> getLocationFromGoogleApi(String input) async {
  // Get the current state, handling the initial state case
  final currentState = state is FeedHomeLoaded ? state as FeedHomeLoaded : FeedHomeLoaded(loadingState: false);
  
  // Emit a loading state. We use copyWith to preserve other state data.
  emit(currentState.copyWith(
    locationLoading: true,
    locationError: null,
    locationResults: [],
  ));

  final result = await feedHomeRepo.getLocationFromGoogleApi(input);

  result.fold(
    (failure) {
      final newState = state as FeedHomeLoaded;
      // On failure, emit a new state with the error.
      emit(newState.copyWith(
        locationLoading: false,
        locationError: "Failed to fetch locations",
      ));
    },
    (response) {
      final newState = state as FeedHomeLoaded;
      final responseData = response.response?.data;
      List<dynamic> newResults = [];

      // Fix: Handle the response structure correctly
      // Based on your JSON sample, the structure is: { "predictions": [...], "status": "OK" }
      if (responseData is Map<String, dynamic>) {
        // Check if the response has a 'predictions' key
        if (responseData.containsKey('predictions') && responseData['predictions'] is List) {
          newResults = [responseData]; // Wrap the entire response in a list to match your UI expectations
        }
      } else if (responseData is List) {
        // Handle case where API returns predictions directly as a list
        newResults = responseData;
      }

      // On success, emit the new results.
      emit(newState.copyWith(
        locationLoading: false,
        locationResults: newResults,
        locationError: null,
      ));
    },
  );
}

  Future<void> getLocationFromApi(String input) async {
    // Get the current state, handling the initial state case
    final currentState = state is FeedHomeLoaded ? state as FeedHomeLoaded : FeedHomeLoaded(loadingState: false);

    // Emit a loading state
    emit(currentState.copyWith(
      locationLoading: true,
      locationError: null,
      locationResults: [],
    ));

    final result = await feedHomeRepo.getLocationFromApi(input);

    result.fold(
          (failure) {
        final newState = state as FeedHomeLoaded;
        // On failure, emit a new state with the error
        emit(newState.copyWith(
          locationLoading: false,
          locationError: "Failed to fetch locations",
          locationResults: [],
        ));
      },
          (response) {
        final newState = state as FeedHomeLoaded;
        final responseData = response.response?.data;

        List<dynamic> locationResults = [];

        // Handle the response - your API returns a direct array of location objects
        if (responseData is List) {
          locationResults = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('predictions')) {
          // Fallback for Google Places API format if you switch APIs later
          locationResults = responseData['predictions'];
        }

        // On success, emit the new results
        emit(newState.copyWith(
          locationLoading: false,
          locationResults: locationResults,
          locationError: null,
        ));
      },
    );
  }


  void clearLocationResults() {
    // Get the current state
    final currentState = state as FeedHomeLoaded;
    // Emit a new state with empty results
    emit(currentState.copyWith(
      locationResults: [],
      locationLoading: false,
      locationError: null,
    ));
  }
  // --- End of location search functions ---

Future<void> resetAndRefreshFeedData() async {
  page = 1;
  hasMoreData = true;
  allData.clear();
  await fetchFeedHomeData();
}

  Future<void> fetchFeedSinglePostData({required String id}) async {
    setScreenState(isLoading: true, data: allData);
    final result = await feedHomeRepo.fetchFeedSinglePostData(id);

    result.fold((failure) {
      setScreenState(isLoading: false, data: allData, message: "Failed to fetch single post");
    }, (customResponse) {
      final responseData = customResponse.response?.data;

      if (responseData is Map && responseData.containsKey("detail") && responseData["detail"] == "Invalid page.") {
        hasMoreData = false;
        setScreenState(isLoading: false, data: allData);
        return;
      }

      final data = FeedGetData.fromJson(responseData);
      singelData = data;
      
      final indexInList = allData.indexWhere((post) => post.id.toString() == id);
      if (indexInList != -1) {
        allData[indexInList] = data;
      }
      
      setScreenState(isLoading: false, singleData: data, data: allData);
    });
  }

  void updateCharCount() {
    final plainText = commentController.document.toPlainText().trim();
    charCount = plainText.length;
    setScreenState(isLoading: false, data: allData);
  }

  Future<void> feedCreatePost({
    List<XFile>? file,
    title,
    required List<Map<String, dynamic>> people,
    required String location,
    required List<Map<String, dynamic>> temples,
    required BuildContext context,
  }) async {
    isPostLoad = true;
    setScreenState(isLoading: false, data: allData);

    final result = await feedHomeRepo.fetchFeedCreateData(
      title,
      file ?? [],
      people,
      location,
      temples,
    );

    result.fold(
      (failure) {
        isPostLoad = false;
        setScreenState(isLoading: false, data: allData);
        Logger.log("this is ${failure.toString()}");
      },
      (customResponse) {
        Logger.log("this is ${customResponse.toString()}");
        commentController.clear();
        selectedMedia.clear();
        isPostLoad = false;
        Fluttertoast.showToast(msg: "Post Created Successfully");
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
        
        setScreenState(isLoading: false, data: allData);
        fetchFeedHomeData(upDateData: true);
      },
    );
  }

  Future<void> feedUpdatePost({
    required int id,
    List<XFile>? file,
    required title,
    required List deletedNetworkImage,
  }) async {
    isPostLoad = true;
    setScreenState(isLoading: false, data: allData);

    final result = await feedHomeRepo.feedUpdatePost(
      id,
      file ?? [],
      title,
    );

    result.fold((failure) {
      isPostLoad = false;
      setScreenState(isLoading: false, data: allData);
      Logger.log("this is ${failure.toString()}");
    }, (customResponse) {
      Logger.log("this is ${customResponse.toString()}");
      commentController.clear();
      selectedMedia = [];
      isPostLoad = false;
      AppRouter.pop();
      AppRouter.pop();
      fetchFeedHomeData(upDateData: true);
      setScreenState(isLoading: false, data: allData);
    });
  }

  Future fetchReportReasons() async {
    final result = await feedHomeRepo.fetchReportReasons();
    result.fold(
      (failure) {
        Logger.log("Follow failed: ${failure.toString()}");
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          hasError: true,
        );
      },
      (customResponse) async {
        reportReasons = [];
        for (var item in customResponse.response!.data) {
          reportReasons.add(ReportReason.fromJson(item));
        }
        setScreenState(isLoading: false, data: allData);
        return reportReasons;
      },
    );
  }

  isReportPost(String postId, int reasonId) async {
    final result = await feedHomeRepo.fetchReportPost(postId, reasonId);
    result.fold(
      (failure) {
        Logger.log("Follow failed: ${failure.toString()}");
        setScreenState(isLoading: false, message: failure.toString(), hasError: true);
      },
      (customResponse) async {
        AppRouter.pop();
        if (singelData.id.toString() == postId) {
          fetchFeedSinglePostData(id: postId);
        }
        fetchFeedHomeData(upDateData: true);
      },
    );
  }

  storeDeletePost({required String deleteId, required int id, required int index}) async {
    deletePostLoader = true;
    deletePost.add(deleteId);
    final result = await feedHomeRepo.feedDeletedPostImage(id, deletePost);
    result.fold((failure) {
      deletePost.clear();
      deletePostLoader = false;
      setScreenState(isLoading: false, data: allData, hasError: true);
      Logger.log("this is ${failure.toString()}");
    }, (customResponse) {
      deletePostLoader = false;
      removeMedia(index);
      deletePost.clear();
      AppRouter.pop();
      
      if (singelData.id == id) {
        fetchFeedSinglePostData(id: id.toString());
      }
      
      fetchFeedHomeData();
      setScreenState(isLoading: false, data: allData);
    });
  }

  Future<void> feedPostFollowingRequest({
    required int followingUserId,
    required int userId,
    required bool isFollowing,
    required int clickedPostIndex,
  }) async {
    final result = await feedHomeRepo.feedPostFollowingRequest(
      followingUserId,
      userId,
      isFollowing,
    );

    result.fold(
      (failure) {
        Logger.log("Follow failed: ${failure.toString()}");
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          hasError: true,
        );
      },
      (customResponse) async {
        if (clickedPostIndex >= 0 && clickedPostIndex < allData.length) {
          final List<FeedGetData> updatedList = List.from(allData);

          final oldPost = updatedList[clickedPostIndex].user;
          updatedList[clickedPostIndex] =
              updatedList[clickedPostIndex].copyWith(
            user: oldPost?.copyWith(followingRequests: isFollowing),
          );

          allData = updatedList;
          
          if (singelData.user?.id == followingUserId) {
            singelData = singelData.copyWith(
              user: singelData.user?.copyWith(followingRequests: isFollowing),
            );
          }
          
          setScreenState(isLoading: false, data: updatedList, singleData: singelData);
        }
      },
    );
  }

  Future<void> feedPostLike(String postId, bool isLike) async {
    final result = await feedHomeRepo.feedPostLikeData(postId, isLike.toString());
    result.fold((failure) {
      Logger.log("Like failed: ${failure.toString()}");
    }, (customResponse) async {
      final apiData = FeedGetData.fromJson(customResponse.response!.data);
      final indexInList = allData.indexWhere((post) => post.id.toString() == postId);
      if (indexInList != -1) {
        allData[indexInList] = apiData;
      }
      setScreenState(isLoading: false, data: allData);
    });
  }

  Future<void> feedPostLikeDeatail(String postId, bool isLike) async {
    try {
      final currentLikeCount = singelData.likedCount ?? 0;
      final newLikeCount = isLike ? currentLikeCount + 1 : currentLikeCount - 1;
      singelData = singelData.copyWith(
        liked: isLike,
        likedCount: newLikeCount < 0 ? 0 : newLikeCount,
      );
      final index = allData.indexWhere((e) => e.id.toString() == postId);
      if (index != -1) {
        allData[index] = singelData;
      }
      setScreenState(isLoading: false, singleData: singelData, data: allData);
      final result = await feedHomeRepo.feedPostLikeData(postId, isLike.toString());
      result.fold(
        (failure) {
          singelData = singelData.copyWith(
            liked: !isLike,
            likedCount: currentLikeCount,
          );
          if (index != -1) {
            allData[index] = singelData;
          }
          setScreenState(
            isLoading: false,
            singleData: singelData,
            data: allData,
            message: failure.toString(),
          );
        },
        (customResponse) {
          final apiData = FeedGetData.fromJson(customResponse.response!.data);
          singelData = apiData;
          if (index != -1) {
            allData[index] = apiData;
          }
          setScreenState(
            isLoading: false,
            singleData: singelData,
            data: allData,
          );
        },
      );
    } catch (e) {
      debugPrint("Like operation failed: $e");
      setScreenState(
        isLoading: false,
        singleData: singelData,
        data: allData,
        message: "An error occurred while updating like status",
      );
    }
  }

  Future<void> feedPostFollowing({
    required int followingUserId,
    required int userId,
    required bool isFollowing,
    required int clickedPostIndex,
  }) async {
    final result = await feedHomeRepo.feedPostFollowing(
      followingUserId,
      userId,
      isFollowing,
    );

    result.fold(
      (failure) {
        Logger.log("Follow failed: ${failure.toString()}");
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          hasError: true,
        );
      },
      (customResponse) async {
        if (clickedPostIndex >= 0 && clickedPostIndex < allData.length) {
          final List<FeedGetData> updatedList = List.from(allData);

          final oldPost = updatedList[clickedPostIndex].user;
          updatedList[clickedPostIndex] =
              updatedList[clickedPostIndex].copyWith(
            user: oldPost?.copyWith(followingRequests: isFollowing),
          );

          allData = updatedList;
          
          if (singelData.user?.id == followingUserId) {
            singelData = singelData.copyWith(
              user: singelData.user?.copyWith(followingRequests: isFollowing),
            );
          }
          
          setScreenState(isLoading: false, data: updatedList, singleData: singelData);
        }
      },
    );
  }

  Future feedPostSaved(String postId, bool isSave) async {
    final result = await feedHomeRepo.feedPostSavedData(postId, isSave.toString());
    result.fold((failure) {
      Logger.log("Save failed: ${failure.toString()}");
      setScreenState(
        isLoading: false,
        message: failure.toString(),
        hasError: true,
        data: allData,
      );
    }, (customResponse) {
      final updatedPost = FeedGetData.fromJson(customResponse.response!.data);
      final updatedList = allData.map((post) {
        if (post.id.toString() == postId) {
          return updatedPost;
        }
        return post;
      }).toList();
      if (singelData.id.toString() == postId) {
        singelData = updatedPost;
      }
      setScreenState(
        isLoading: false, 
        data: updatedList, 
        singleData: singelData
      );
    });
  }

  Future<void> feedPostDelete(int postId) async {
    final result = await feedHomeRepo.feedPostDeteleData(postId.toString());
    result.fold((failure) {
      Logger.log("Delete failed: ${failure.toString()}");
      setScreenState(
        isLoading: false, 
        message: failure.toString(),
        hasError: true,
        data: allData,
      );
    }, (customResponse) {
      allData.removeWhere((post) => post.id == postId);
      fetchFeedHomeData(upDateData: true);
      setScreenState(isLoading: false, data: allData);
    });
  }

  Future<void> getfeedCome(String id, int? limit) async {
    final result = await feedHomeRepo.fetchFeedHomeDataData(0);
    result.fold((failure) {
      setScreenState(isLoading: false, data: allData, message: "Failed to load feed data");
    }, (customResponse) {
      final data = FeedGetData.fromList(customResponse.response!.data);
      allData = [];
      allData.addAll(data);
      setScreenState(isLoading: false, data: allData);
    });
  }
// Updated block methods for FeedHomeCubit class


Future<void> blockUser(int postId, userid, String myId) async {
  try {
    // Add to local blocked list immediately for better UX
    if (!blockedPostIds.contains(postId)) {
      blockedPostIds.add(postId);
      final currentState = state;
      if (currentState is FeedHomeLoaded) {
        final updatedFeedList = (currentState.feedList ?? [])
            .where((post) => post.id != postId)
            .toList();
        emit(currentState.copyWith(feedList: updatedFeedList));
      }
    }

    // Call API to block the post
    final result = await feedHomeRepo.blockUser(postId, userid, myId);
    
    result.fold(
      (failure) {
        // If API fails, remove from local blocked list and restore post
        blockedPostIds.remove(postId);
        fetchFeedHomeData(upDateData: true); // Refresh to restore the post
        setScreenState(
          isLoading: false,
          data: allData,
          message: "Failed to block post: ${failure.toString()}",
          hasError: true,
        );
        Logger.log("Block post failed: ${failure.toString()}");
      },
      (customResponse) {
        // Success - post remains blocked locally and on server
        Logger.log("Post blocked successfully");
        setScreenState(isLoading: false, data: allData);
      },
    );
  } catch (e) {
   
    blockedPostIds.remove(postId);
    fetchFeedHomeData(upDateData: true);
    setScreenState(
      isLoading: false,
      data: allData,
      message: "An error occurred while blocking the post",
      hasError: true,
    );
    Logger.log("Block post error: $e");
  }
}

// Replace the existing blockPost method with this one
Future<void> blockPost(int postId, userid, String myId) async {
  try {
    // Add to local blocked list immediately for better UX
    if (!blockedPostIds.contains(postId)) {
      blockedPostIds.add(postId);
      final currentState = state;
      if (currentState is FeedHomeLoaded) {
        final updatedFeedList = (currentState.feedList ?? [])
            .where((post) => post.id != postId)
            .toList();
        emit(currentState.copyWith(feedList: updatedFeedList));
      }
    }

    // Call API to block the post
    final result = await feedHomeRepo.blockPost(postId, userid, myId);
    
    result.fold(
      (failure) {
        // If API fails, remove from local blocked list and restore post
        blockedPostIds.remove(postId);
        fetchFeedHomeData(upDateData: true); // Refresh to restore the post
        setScreenState(
          isLoading: false,
          data: allData,
          message: "Failed to block post: ${failure.toString()}",
          hasError: true,
        );
        Logger.log("Block post failed: ${failure.toString()}");
      },
      (customResponse) {
        // Success - post remains blocked locally and on server
        Logger.log("Post blocked successfully");
        setScreenState(isLoading: false, data: allData);
      },
    );
  } catch (e) {
   
    blockedPostIds.remove(postId);
    fetchFeedHomeData(upDateData: true);
    setScreenState(
      isLoading: false,
      data: allData,
      message: "An error occurred while blocking the post",
      hasError: true,
    );
    Logger.log("Block post error: $e");
  }
}


Future<void> blockMedia(int mediaId) async {
  try {
    // Add to local blocked list immediately
    if (!blockedMediaIds.contains(mediaId)) {
      blockedMediaIds.add(mediaId);
      emit(state); // Trigger UI update
    }

    // Call API to block the media
    final result = await feedHomeRepo.blockMedia(mediaId);
    
    result.fold(
      (failure) {
        // If API fails, remove from local blocked list
        blockedMediaIds.remove(mediaId);
        setScreenState(
          isLoading: false,
          data: allData,
          message: "Failed to block media: ${failure.toString()}",
          hasError: true,
        );
        Logger.log("Block media failed: ${failure.toString()}");
      },
      (customResponse) {
        // Success - media remains blocked
        Logger.log("Media blocked successfully");
        setScreenState(isLoading: false, data: allData);
      },
    );
  } catch (e) {
    // Handle any unexpected errors
    blockedMediaIds.remove(mediaId);
    setScreenState(
      isLoading: false,
      data: allData,
      message: "An error occurred while blocking the media",
      hasError: true,
    );
    Logger.log("Block media error: $e");
  }
}

// Add these new methods to unblock content if needed
Future<void> unblockPost(int postId) async {
  try {
    final result = await feedHomeRepo.unblockPost(postId);
    
    result.fold(
      (failure) {
        setScreenState(
          isLoading: false,
          data: allData,
          message: "Failed to unblock post: ${failure.toString()}",
          hasError: true,
        );
        Logger.log("Unblock post failed: ${failure.toString()}");
      },
      (customResponse) {
        // Remove from local blocked list and refresh
        blockedPostIds.remove(postId);
        fetchFeedHomeData(upDateData: true);
        Logger.log("Post unblocked successfully");
      },
    );
  } catch (e) {
    setScreenState(
      isLoading: false,
      data: allData,
      message: "An error occurred while unblocking the post",
      hasError: true,
    );
    Logger.log("Unblock post error: $e");
  }
}

Future<void> unblockMedia(int mediaId) async {
  try {
    final result = await feedHomeRepo.unblockMedia(mediaId);
    
    result.fold(
      (failure) {
        setScreenState(
          isLoading: false,
          data: allData,
          message: "Failed to unblock media: ${failure.toString()}",
          hasError: true,
        );
        Logger.log("Unblock media failed: ${failure.toString()}");
      },
      (customResponse) {
        // Remove from local blocked list
        blockedMediaIds.remove(mediaId);
        emit(state); // Trigger UI update
        Logger.log("Media unblocked successfully");
      },
    );
  } catch (e) {
    setScreenState(
      isLoading: false,
      data: allData,
      message: "An error occurred while unblocking the media",
      hasError: true,
    );
    Logger.log("Unblock media error: $e");
  }
}

// Add method to check if content is blocked (for UI purposes)
bool isPostBlocked(int postId) {
  return blockedPostIds.contains(postId);
}

bool isMediaBlocked(int mediaId) {
  return blockedMediaIds.contains(mediaId);
}

// Method to get filtered feed data (excluding blocked posts)
List<FeedGetData> getFilteredFeedData(List<FeedGetData> feedList) {
  return feedList.where((post) => !blockedPostIds.contains(post.id)).toList();
}

  void setScreenState({
    List<FeedGetData>? data,
    FeedGetData? singleData,
    required bool isLoading,
    String? message,
    bool hasError = false,
  }) {
    if (isClosed) {
      debugPrint('[FeedHomeCubit] Tried to emit after close');
      return;
    }

    emit(
      FeedHomeLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        hasError: hasError,
        feedList: data,
        singleFeed: singleData ?? singelData,
        locationResults: locationResults,
        locationLoading: locationLoading,
        locationError: locationError,
      ),
    );
  }
}