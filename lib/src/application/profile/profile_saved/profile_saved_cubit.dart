import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/profile/profile_saved/profile_saved_state.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_devalay_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_event_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_festival_model.dart';
import 'package:devalay_app/src/data/model/explore/explore_puja_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/contribution/contribution_dev_model.dart';
import '../../../data/model/contribution/contribution_festival_model.dart';
import '../../../data/model/explore/explore_dev_model.dart';

class ProfileSavedCubit extends Cubit<ProfileSavedState> {
  ProfileSavedCubit()
      : profileRepo = getIt<ProfileRepo>(),
        feedRepo = getIt<FeedHomeRepo>(),
        super(ProfileSavedInitial());

  final ProfileRepo profileRepo;
  final FeedHomeRepo feedRepo;

  List<ContributionDevalayModel> allData = [];
  List<ExploreEventModel> event = [];
  List<ExploreDevModel> dev = [];
  List<ExplorePujaModel> puja = [];
  List<ContributionFestivalModel> festival = [];
  List<FeedGetData> list = [];

  int page = 1;
  bool hasMoreData = true;

  Future<void> fetchProfileSaveTempleData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, savedTempleModel: allData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData.clear();
    }
    try {
      final result = await profileRepo.fetchProfileSavedTempleData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
          hasMoreData = false;
          setScreenState(isLoading: false, savedTempleModel: []);
        } else {
          hasMoreData = false;
          setScreenState(isLoading: false, savedTempleModel: allData);
        }
      }, (success) {
        final jsonData = success.response?.data;

        List<ContributionDevalayModel> newData = [];
        if (jsonData is List) {
          newData = jsonData
              .map((x) => ContributionDevalayModel.fromJson(x))
              .toList();
        } else if (jsonData is Map<String, dynamic>) {
          newData = [];
        }

        allData.addAll(newData);
        hasMoreData = newData.isNotEmpty;
        setScreenState(isLoading: false, savedTempleModel: allData);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, savedTempleModel: allData);
    }
  }

  Future<void> likeEvent(int id, bool isLiked) async {
    try {
      // Update UI immediately
      final currentList = List<ExploreEventModel>.from(event);
      final eventIndex = currentList.indexWhere((eventItem) => eventItem.id == id);
      
      if (eventIndex != -1) {
        final oldEvent = currentList[eventIndex];
        
        // Prevent multiple likes - user can only toggle between liked/unliked
        if ((oldEvent.liked ?? false) == isLiked) {
          // Already in the desired state, no action needed
          return;
        }
        
        // Calculate new like count with proper bounds
        int newLikeCount = oldEvent.likedCount ?? 0;
        if (isLiked && !(oldEvent.liked ?? false)) {
          // User is liking (was not liked before)
          newLikeCount = newLikeCount + 1;
        } else if (!isLiked && (oldEvent.liked ?? false)) {
          // User is unliking (was liked before)
          newLikeCount = newLikeCount > 0 ? newLikeCount - 1 : 0; // Ensure count doesn't go below 0
        }
        
        currentList[eventIndex] = oldEvent.copyWith(
          liked: isLiked,
          likedCount: newLikeCount,
        );
        
        event = currentList;
        setScreenState(isLoading: false, exploreEventModel: currentList);
      }

      // Make API call
      final result = await profileRepo.likeEvent(id, isLiked);
      
      result.fold(
        (failure) {
          // Revert on failure
          if (eventIndex != -1) {
            final currentEvent = currentList[eventIndex];
            int revertedLikeCount = currentEvent.likedCount ?? 0;
            
            if (isLiked) {
              revertedLikeCount = revertedLikeCount > 0 ? revertedLikeCount - 1 : 0;
            } else {
              revertedLikeCount = revertedLikeCount + 1;
            }
            
            currentList[eventIndex] = currentEvent.copyWith(
              liked: !isLiked,
              likedCount: revertedLikeCount,
            );
            
            event = currentList;
            setScreenState(
              isLoading: false,
              exploreEventModel: currentList,
              message: "Failed to update like status",
            );
          }
        },
        (success) {
          // Success - optionally refresh data from server to sync
          // fetchProfileSavedEventsData(); // Uncomment if you want to refresh from server
        },
      );
    } catch (e) {
      // Revert UI changes on error
      final currentList = List<ExploreEventModel>.from(event);
      final eventIndex = currentList.indexWhere((eventItem) => eventItem.id == id);
      
      if (eventIndex != -1) {
        final currentEvent = currentList[eventIndex];
        int revertedLikeCount = currentEvent.likedCount ?? 0;
        
        if (isLiked) {
          revertedLikeCount = revertedLikeCount > 0 ? revertedLikeCount - 1 : 0;
        } else {
          revertedLikeCount = revertedLikeCount + 1;
        }
        
        currentList[eventIndex] = currentEvent.copyWith(
          liked: !isLiked,
          likedCount: revertedLikeCount,
        );
        
        event = currentList;
      }
      
      setScreenState(
        isLoading: false,
        exploreEventModel: currentList,
        message: "An error occurred while updating like status",
      );
    }
  }

  Future<void> toggleDevLike(int id) async {
    final index = dev.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final oldDev = dev[index];
    final wasLiked = oldDev.liked ?? false;
    final newLiked = !wasLiked;
    final newLikeCount = newLiked
        ? (oldDev.likedCount ?? 0) + 1
        : ((oldDev.likedCount ?? 1) - 1).clamp(0, 999999);

    final updatedDev = oldDev.copyWith(liked: newLiked, likedCount: newLikeCount);
    final updatedList = List<ExploreDevModel>.from(dev);
    updatedList[index] = updatedDev;
    dev = updatedList;
    setScreenState(isLoading: false, exploreDevModel: updatedList);

    try {
      final result = await profileRepo.likeDev(id, newLiked);
      result.fold(
            (failure) {
          // revert
          final revertedTemple = oldDev.copyWith(liked: wasLiked, likedCount: oldDev.likedCount);
          final revertedList = List<ExploreDevModel>.from(dev);
          revertedList[index] = revertedTemple;
          dev = revertedList;
          setScreenState(
            isLoading: false,
            exploreDevModel: revertedList,
            message: "Failed to update like status",
          );
        },
            (success) {},
      );
    } catch (e) {
      final revertedTemple = oldDev.copyWith(liked: wasLiked, likedCount: oldDev.likedCount);
      final revertedList = List<ExploreDevModel>.from(dev);
      revertedList[index] = revertedTemple;
      dev = revertedList;
      setScreenState(
        isLoading: false,
        exploreDevModel: revertedList,
        message: "An error occurred while updating like status",
      );
    }
  }

  Future<void> toggleFestivalLike(int id) async {
    final index = festival.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final oldFestival = festival[index];
    final wasLiked = oldFestival.liked ?? false;
    final newLiked = !wasLiked;
    final newLikeCount = newLiked
        ? (oldFestival.likedCount ?? 0) + 1
        : ((oldFestival.likedCount ?? 1) - 1).clamp(0, 999999);

    final updatedDev = oldFestival.copyWith(liked: newLiked, likedCount: newLikeCount);
    final updatedList = List<ContributionFestivalModel>.from(festival);
    updatedList[index] = updatedDev;
    festival = updatedList;
    setScreenState(isLoading: false, savedFestivalModel: updatedList);

    try {
      final result = await profileRepo.likeFestival(id, newLiked);
      result.fold(
            (failure) {
          // revert
          final revertedTemple = oldFestival.copyWith(liked: wasLiked, likedCount: oldFestival.likedCount);
          final revertedList = List<ContributionFestivalModel>.from(festival);
          revertedList[index] = revertedTemple;
          festival = revertedList;
          setScreenState(
            isLoading: false,
            savedFestivalModel: revertedList,
            message: "Failed to update like status",
          );
        },
            (success) {},
      );
    } catch (e) {
      final revertedTemple = oldFestival.copyWith(liked: wasLiked, likedCount: oldFestival.likedCount);
      final revertedList = List<ContributionFestivalModel>.from(festival);
      revertedList[index] = revertedTemple;
      festival = revertedList;
      setScreenState(
        isLoading: false,
        savedFestivalModel: revertedList,
        message: "An error occurred while updating like status",
      );
    }
  }

  Future<void> saveEvent(int id, bool isSaved) async {
    try {
      final currentList = List<ExploreEventModel>.from(event);
      final eventIndex =
          currentList.indexWhere((eventItem) => eventItem.id == id);

      if (eventIndex != -1) {
        final oldEvent = currentList[eventIndex];

        if ((oldEvent.saved ?? false) == isSaved) {
          return;
        }

        int newSaveCount = oldEvent.savedCount ?? 0;
        if (isSaved && !(oldEvent.saved ?? false)) {
          newSaveCount = newSaveCount + 1;
        } else if (!isSaved && (oldEvent.saved ?? false)) {
          newSaveCount = newSaveCount > 0 ? newSaveCount - 1 : 0;
        }

        currentList[eventIndex] = oldEvent.copyWith(
          saved: isSaved,
          savedCount: newSaveCount,
        );

        event = currentList;
        setScreenState(isLoading: false, exploreEventModel: currentList);
      }

      final result = await profileRepo.saveEvent(id, isSaved);

      result.fold(
        (failure) {
          if (eventIndex != -1) {
            final currentEvent = currentList[eventIndex];
            int revertedSaveCount = currentEvent.savedCount ?? 0;

            if (isSaved) {
              revertedSaveCount =
                  revertedSaveCount > 0 ? revertedSaveCount - 1 : 0;
            } else {
              revertedSaveCount = revertedSaveCount + 1;
            }

            currentList[eventIndex] = currentEvent.copyWith(
              saved: !isSaved,
              savedCount: revertedSaveCount,
            );

            event = currentList;
            setScreenState(
              isLoading: false,
              exploreEventModel: currentList,
              message: "Failed to update save status",
            );
          }
        },
        (success) {},
      );
    } catch (e) {
      final currentList = List<ExploreEventModel>.from(event);
      final eventIndex =
          currentList.indexWhere((eventItem) => eventItem.id == id);

      if (eventIndex != -1) {
        final currentEvent = currentList[eventIndex];
        int revertedSaveCount = currentEvent.savedCount ?? 0;

        if (isSaved) {
          revertedSaveCount = revertedSaveCount > 0 ? revertedSaveCount - 1 : 0;
        } else {
          revertedSaveCount = revertedSaveCount + 1;
        }

        currentList[eventIndex] = currentEvent.copyWith(
          saved: !isSaved,
          savedCount: revertedSaveCount,
        );

        event = currentList;
      }

      setScreenState(
        isLoading: false,
        exploreEventModel: currentList,
        message: "An error occurred while updating save status",
      );
    }
  }
  Future<void> saveFestival(int id, bool isSaved) async {
    try {
      final currentList = List<ContributionFestivalModel>.from(festival);
      final festivalIndex =
          currentList.indexWhere((festivalItem) => festivalItem.id == id);

      if (festivalIndex != -1) {
        final oldFestival = currentList[festivalIndex];

        if ((oldFestival.saved ?? false) == isSaved) {
          return;
        }

        int newSaveCount = oldFestival.savedCount ?? 0;
        if (isSaved && !(oldFestival.saved ?? false)) {
          newSaveCount = newSaveCount + 1;
        } else if (!isSaved && (oldFestival.saved ?? false)) {
          newSaveCount = newSaveCount > 0 ? newSaveCount - 1 : 0;
        }

        currentList[festivalIndex] = oldFestival.copyWith(
          saved: isSaved,
          savedCount: newSaveCount,
        );

        festival = currentList;
        setScreenState(isLoading: false, savedFestivalModel: currentList);
      }

      final result = await profileRepo.saveFestival(id, isSaved);

      result.fold(
        (failure) {
          if (festivalIndex != -1) {
            final currentFestival = currentList[festivalIndex];
            int revertedSaveCount = currentFestival.savedCount ?? 0;

            if (isSaved) {
              revertedSaveCount =
                  revertedSaveCount > 0 ? revertedSaveCount - 1 : 0;
            } else {
              revertedSaveCount = revertedSaveCount + 1;
            }

            currentList[festivalIndex] = currentFestival.copyWith(
              saved: !isSaved,
              savedCount: revertedSaveCount,
            );

            festival = currentList;
            setScreenState(
              isLoading: false,
              savedFestivalModel: currentList,
              message: "Failed to update save status",
            );
          }
        },
        (success) {},
      );
    } catch (e) {
      final currentList = List<ContributionFestivalModel>.from(festival);
      final eventIndex =
          currentList.indexWhere((eventItem) => eventItem.id == id);

      if (eventIndex != -1) {
        final currentEvent = currentList[eventIndex];
        int revertedSaveCount = currentEvent.savedCount ?? 0;

        if (isSaved) {
          revertedSaveCount = revertedSaveCount > 0 ? revertedSaveCount - 1 : 0;
        } else {
          revertedSaveCount = revertedSaveCount + 1;
        }

        currentList[eventIndex] = currentEvent.copyWith(
          saved: !isSaved,
          savedCount: revertedSaveCount,
        );

        festival = currentList;
      }

      setScreenState(
        isLoading: false,
        savedFestivalModel: currentList,
        message: "An error occurred while updating save status",
      );
    }
  }

  Future<void> saveDev(int id, bool isSaved) async {
    try {
      final currentList = List<ExploreDevModel>.from(dev);
      final devIndex =
          currentList.indexWhere((devIndex) => devIndex.id == id);

      if (devIndex != -1) {
        final oldDev = currentList[devIndex];

        if ((oldDev.saved ?? false) == isSaved) {
          return;
        }

        int newSaveCount = oldDev.savedCount ?? 0;
        if (isSaved && !(oldDev.saved ?? false)) {
          newSaveCount = newSaveCount + 1;
        } else if (!isSaved && (oldDev.saved ?? false)) {
          newSaveCount = newSaveCount > 0 ? newSaveCount - 1 : 0;
        }

        currentList[devIndex] = oldDev.copyWith(
          saved: isSaved,
          savedCount: newSaveCount,
        );

        dev = currentList;
        setScreenState(isLoading: false, exploreDevModel: currentList);
      }

      final result = await profileRepo.saveDev(id, isSaved);

      result.fold(
        (failure) {
          if (devIndex != -1) {
            final currentEvent = currentList[devIndex];
            int revertedSaveCount = currentEvent.savedCount ?? 0;

            if (isSaved) {
              revertedSaveCount =
                  revertedSaveCount > 0 ? revertedSaveCount - 1 : 0;
            } else {
              revertedSaveCount = revertedSaveCount + 1;
            }

            currentList[devIndex] = currentEvent.copyWith(
              saved: !isSaved,
              savedCount: revertedSaveCount,
            );

            dev = currentList;
            setScreenState(
              isLoading: false,
              exploreDevModel: currentList,
              message: "Failed to update save status",
            );
          }
        },
        (success) {},
      );
    } catch (e) {
      final currentList = List<ExploreEventModel>.from(event);
      final devIndex =
          currentList.indexWhere((eventItem) => eventItem.id == id);

      if (devIndex != -1) {
        final currentEvent = currentList[devIndex];
        int revertedSaveCount = currentEvent.savedCount ?? 0;

        if (isSaved) {
          revertedSaveCount = revertedSaveCount > 0 ? revertedSaveCount - 1 : 0;
        } else {
          revertedSaveCount = revertedSaveCount + 1;
        }

        currentList[devIndex] = currentEvent.copyWith(
          saved: !isSaved,
          savedCount: revertedSaveCount,
        );

        event = currentList;
      }

      setScreenState(
        isLoading: false,
        exploreEventModel: currentList,
        message: "An error occurred while updating save status",
      );
    }
  }

  Future<void> fetchProfileSavedPostData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, feedList: list);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      list.clear();
    }
    try {
      final result = await profileRepo.fetchProfileSavedPostData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
          hasMoreData = false;
          setScreenState(isLoading: false, feedList: []);
        } else {
          hasMoreData = false;
          setScreenState(isLoading: false, feedList: list);
        }
      }, (success) {
        final jsonData = success.response?.data;

        List<FeedGetData> newData = [];
        if (jsonData is List) {
          newData = jsonData.map((x) => FeedGetData.fromJson(x)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          newData = [];
        }

        list.addAll(newData);
        hasMoreData = newData.isNotEmpty;
        setScreenState(isLoading: false, feedList: list);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, feedList: list);
    }
  }

  Future<void> fetchProfileSavedEventsData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreEventModel: event);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      event.clear();
    }

    try {
      final result = await profileRepo.fetchProfileSavedEventsData(page);

      result.fold((failure) {
        if (failure.errorMessage.toString() == "No data found") {
          hasMoreData = false;
          setScreenState(isLoading: false, exploreEventModel: []);
        } else {
          hasMoreData = false;
          setScreenState(isLoading: false, exploreEventModel: event);
        }
      }, (success) {
        final jsonData = success.response?.data;

        List<ExploreEventModel> newData = [];
        if (jsonData is List) {
          newData = jsonData.map((x) => ExploreEventModel.fromJson(x)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          newData = [];
        }

        event.addAll(newData);
        hasMoreData = newData.isNotEmpty;
        setScreenState(isLoading: false, exploreEventModel: event);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, exploreEventModel: event);
    }
  }

  Future<void> fetchProfileSavedDevsData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreDevModel: dev);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      dev.clear();
    }

    try {
      final result = await profileRepo.fetchProfileSavedDevData(page);

      result.fold((failure) {
        if (failure.errorMessage.toString() == "No data found") {
          hasMoreData = false;
          setScreenState(isLoading: false, exploreDevModel: []);
        } else {
          hasMoreData = false;
          setScreenState(isLoading: false, exploreDevModel: dev);
        }
      }, (success) {
        final jsonData = success.response?.data;

        List<ExploreDevModel> newData = [];
        if (jsonData is List) {
          newData = jsonData.map((x) => ExploreDevModel.fromJson(x)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          newData = [];
        }

        dev.addAll(newData);
        hasMoreData = newData.isNotEmpty;
        setScreenState(isLoading: false, exploreDevModel: dev);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, exploreDevModel: dev);
    }
  }

  Future<void> fetchProfileSavedFestivalsData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, savedFestivalModel: festival);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      festival.clear();
    }

    try {
      final result = await profileRepo.fetchProfileSavedFestivalData(page);

      result.fold((failure) {
        if (failure.errorMessage.toString() == "No data found") {
          hasMoreData = false;
          setScreenState(isLoading: false, savedFestivalModel: []);
        } else {
          hasMoreData = false;
          setScreenState(isLoading: false, savedFestivalModel: festival);
        }
      }, (success) {
        final jsonData = success.response?.data;

        List<ContributionFestivalModel> newData = [];
        if (jsonData is List) {
          newData = jsonData.map((x) => ContributionFestivalModel.fromJson(x)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          newData = [];
        }

        festival.addAll(newData);
        hasMoreData = newData.isNotEmpty;
        setScreenState(isLoading: false, savedFestivalModel: festival);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, savedFestivalModel: festival);
    }
  }

  Future<void> fetchProfileSavedPujaData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreEventModel: event);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      puja.clear();
    }
    try {
      final result = await profileRepo.fetchProfileSavedPujaData(page);

      result.fold((failure) {
        hasMoreData = false;
        setScreenState(isLoading: false, explorePujaModel: []);
        if (failure.toString() == "No data found") {
          hasMoreData = false;
        }
      }, (success) {
        final jsonData = success.response?.data;

        List<ExplorePujaModel> newData = [];
        if (jsonData is List) {
          newData = jsonData.map((x) => ExplorePujaModel.fromJson(x)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          newData = [];
        }

        puja.addAll(newData);
        hasMoreData = newData.isNotEmpty;
        setScreenState(isLoading: false, explorePujaModel: puja);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, explorePujaModel: puja);
    }
  }

  Future<void> savePost(String postId, bool isSaved) async {
    try {
      final currentList = List<FeedGetData>.from(list);
      final postIndex =
          currentList.indexWhere((post) => post.id.toString() == postId);

      if (postIndex != -1) {
        currentList[postIndex] =
            currentList[postIndex].copyWith(saved: isSaved);
        list = currentList;
        setScreenState(isLoading: false, feedList: currentList);
      }

      final result =
          await feedRepo.feedPostSavedData(postId, isSaved.toString());

      result.fold(
        (failure) {
          if (postIndex != -1) {
            currentList[postIndex] =
                currentList[postIndex].copyWith(saved: !isSaved);
            list = currentList;
            setScreenState(
              isLoading: false,
              feedList: currentList,
              message: "Failed to update save status",
            );
          }
        },
        (success) {
          fetchProfileSavedPostData();
        },
      );
    } catch (e) {
      setScreenState(
        isLoading: false,
        message: "An error occurred while saving the post",
      );
    }
  }

  Future<void> toggleTempleLike(int id) async {
    final index = allData.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final oldTemple = allData[index];
    final wasLiked = oldTemple.liked ?? false;
    final newLiked = !wasLiked;
    final newLikeCount = newLiked
        ? (oldTemple.likedCount ?? 0) + 1
        : ((oldTemple.likedCount ?? 1) - 1).clamp(0, 999999);

    final updatedTemple = oldTemple.copyWith(liked: newLiked, likedCount: newLikeCount);
    final updatedList = List<ContributionDevalayModel>.from(allData);
    updatedList[index] = updatedTemple;
    allData = updatedList;
    setScreenState(isLoading: false, savedTempleModel: updatedList);

    try {
      final result = await profileRepo.likeTemple(id, newLiked);
      result.fold(
        (failure) {
          // revert
          final revertedTemple = oldTemple.copyWith(liked: wasLiked, likedCount: oldTemple.likedCount);
          final revertedList = List<ContributionDevalayModel>.from(allData);
          revertedList[index] = revertedTemple;
          allData = revertedList;
          setScreenState(
            isLoading: false,
            savedTempleModel: revertedList,
            message: "Failed to update like status",
          );
        },
        (success) {},
      );
    } catch (e) {
      final revertedTemple = oldTemple.copyWith(liked: wasLiked, likedCount: oldTemple.likedCount);
      final revertedList = List<ContributionDevalayModel>.from(allData);
      revertedList[index] = revertedTemple;
      allData = revertedList;
      setScreenState(
        isLoading: false,
        savedTempleModel: revertedList,
        message: "An error occurred while updating like status",
      );
    }
  }

  Future<void> toggleTempleSave(int id) async {
    final index = allData.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final oldTemple = allData[index];
    final wasSaved = oldTemple.saved ?? false;
    final newSaved = !wasSaved;
    final newSaveCount = newSaved
        ? (oldTemple.savedCount ?? 0) + 1
        : ((oldTemple.savedCount ?? 1) - 1).clamp(0, 999999);

    final updatedTemple = oldTemple.copyWith(saved: newSaved, savedCount: newSaveCount);
    final updatedList = List<ContributionDevalayModel>.from(allData);
    updatedList[index] = updatedTemple;
    allData = updatedList;
    setScreenState(isLoading: false, savedTempleModel: updatedList);

    try {
      final result = await profileRepo.saveTemple(id, newSaved);
      result.fold(
        (failure) {
          // revert
          final revertedTemple = oldTemple.copyWith(saved: wasSaved, savedCount: oldTemple.savedCount);
          final revertedList = List<ContributionDevalayModel>.from(allData);
          revertedList[index] = revertedTemple;
          allData = revertedList;
          setScreenState(
            isLoading: false,
            savedTempleModel: revertedList,
            message: "Failed to update save status",
          );
        },
        (success) {},
      );
    } catch (e) {
      final revertedTemple = oldTemple.copyWith(saved: wasSaved, savedCount: oldTemple.savedCount);
      final revertedList = List<ContributionDevalayModel>.from(allData);
      revertedList[index] = revertedTemple;
      allData = revertedList;
      setScreenState(
        isLoading: false,
        savedTempleModel: revertedList,
        message: "An error occurred while updating save status",
      );
    }
  }

  void setScreenState({
    List<ContributionDevalayModel>? savedTempleModel,
    List<ContributionDevModel>? savedDevModel,
    List<ContributionFestivalModel>? savedFestivalModel,
    List<ExploreEventModel>? exploreEventModel,
    List<ExplorePujaModel>? explorePujaModel,
    List<ExploreDevModel>? exploreDevModel,
    List<ExploreFestivalModel>? exploreFestivalModel,
    List<FeedGetData>? feedList,
    required bool isLoading,
    String? message,
  }) {
    emit(ProfileSavedLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        savedTempleModel: savedTempleModel,
        saveEventModel: exploreEventModel,
        savePujaModel: explorePujaModel,
        saveDevModel: exploreDevModel,
        saveFestivalModel: savedFestivalModel,
        feedList: feedList,
        currentPage: page));
  }

  void updateEventsList(List<ExploreEventModel> updatedList) {
    event = updatedList;
    setScreenState(isLoading: false, exploreEventModel: updatedList);
  }
  // void updateDevsList(List<ExploreDevModel> updatedList) {
  //   dev = updatedList;
  //   setScreenState(isLoading: false, exploreDevModel: updatedList);
  // }
}
