import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_state.dart';
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/contribution/contribution_devalay_model.dart';
import '../../../data/model/explore/explore_event_model.dart';
import '../../../data/model/feed/feed_home_model.dart';

class ProfileLikedTempleCubit extends Cubit<ProfileLikedTempleState> {
  ProfileLikedTempleCubit()
      : profileRepo = getIt<ProfileRepo>(),
        super(ProfileLikedTempleInitial());

  ProfileRepo profileRepo;
  List<ContributionDevalayModel> allData = [];
  List<ExploreEventModel> event = [];
  List<FeedGetData> list = [];

  int page = 1;
  bool hasMoreData = true;

  Future<void> fetchProfileLikedTempleData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, likeTemplesModel: allData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData.clear();
    }
    try {
      final result = await profileRepo.fetchProfileLikedTempleData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
          hasMoreData = false;
          setScreenState(isLoading: false, likeTemplesModel: []);
        } else {
          hasMoreData = false;
          setScreenState(isLoading: false, likeTemplesModel: allData);
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
        setScreenState(isLoading: false, likeTemplesModel: allData);
      });
    } catch (e) {
      hasMoreData = false;
      setScreenState(isLoading: false, likeTemplesModel: allData);
    }
  }

  Future<void> likeTemple(int id, bool isLiked) async {
    try {
      // Update UI immediately
      final currentList = List<ContributionDevalayModel>.from(allData);
      final templeIndex = currentList.indexWhere((temple) => temple.id == id);
      
      if (templeIndex != -1) {
        final oldTemple = currentList[templeIndex];
        final newLikeCount = isLiked ? (oldTemple.likedCount ?? 0) + 1 : (oldTemple.likedCount ?? 0) - 1;
        
        currentList[templeIndex] = oldTemple.copyWith(
          liked: isLiked,
          likedCount: newLikeCount < 0 ? 0 : newLikeCount,
        );
        
        allData = currentList;
        setScreenState(isLoading: false, likeTemplesModel: currentList);
      }

      // Make API call
      final result = await profileRepo.likeTemple(id, isLiked);
      
      result.fold(
        (failure) {
          // Revert on failure
          if (templeIndex != -1) {
            final oldTemple = currentList[templeIndex];
            final originalLikeCount = isLiked ? (oldTemple.likedCount ?? 0) - 1 : (oldTemple.likedCount ?? 0) + 1;
            
            currentList[templeIndex] = oldTemple.copyWith(
              liked: !isLiked,
              likedCount: originalLikeCount < 0 ? 0 : originalLikeCount,
            );
            
            allData = currentList;
            setScreenState(
              isLoading: false,
              likeTemplesModel: currentList,
              message: "Failed to update like status",
            );
          }
        },
        (success) {
          // Refresh the list to get updated data
          fetchProfileLikedTempleData();
        },
      );
    } catch (e) {
      debugPrint('Like temple error: $e');
      setScreenState(
        isLoading: false,
        message: "An error occurred while updating like status",
      );
    }
  }

  Future<void> saveTemple(int id, bool isSaved) async {
    try {
      // Update UI immediately
      final currentList = List<ContributionDevalayModel>.from(allData);
      final templeIndex = currentList.indexWhere((temple) => temple.id == id);
      
      if (templeIndex != -1) {
        final oldTemple = currentList[templeIndex];
        final newSaveCount = isSaved ? (oldTemple.savedCount ?? 0) + 1 : (oldTemple.savedCount ?? 0) - 1;
        
        currentList[templeIndex] = oldTemple.copyWith(
          saved: isSaved,
          savedCount: newSaveCount < 0 ? 0 : newSaveCount,
        );
        
        allData = currentList;
        setScreenState(isLoading: false, likeTemplesModel: currentList);
      }

      // Make API call
      final result = await profileRepo.saveTemple(id, isSaved);
      
      result.fold(
        (failure) {
          // Revert on failure
          if (templeIndex != -1) {
            final oldTemple = currentList[templeIndex];
            final originalSaveCount = isSaved ? (oldTemple.savedCount ?? 0) - 1 : (oldTemple.savedCount ?? 0) + 1;
            
            currentList[templeIndex] = oldTemple.copyWith(
              saved: !isSaved,
              savedCount: originalSaveCount < 0 ? 0 : originalSaveCount,
            );
            
            allData = currentList;
            setScreenState(
              isLoading: false,
              likeTemplesModel: currentList,
              message: "Failed to update save status",
            );
          }
        },
        (success) {
          // Refresh the list to get updated data
          fetchProfileLikedTempleData();
        },
      );
    } catch (e) {
      debugPrint('Save temple error: $e');
      setScreenState(
        isLoading: false,
        message: "An error occurred while updating save status",
      );
    }
  }

  Future<void> fetchProfileLikedPostData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, feedList: list);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      list.clear();
    }
    try {
      final result = await profileRepo.fetchProfileLikedPostData(page);

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
          newData = jsonData
              .map((x) => FeedGetData.fromJson(x))
              .toList();
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

  Future<void> fetchProfileLikedEventData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreEventModel: event);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      event.clear();
    }
    try {
      final result = await profileRepo.fetchProfileLikedEventsData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
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

  Future<void> fetchProfileLikedPujaData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreEventModel: event);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData.clear();
    }
    try {
      final result = await profileRepo.fetchProfileLikedPujaData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
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

  Future<void> fetchProfileLikedFestivalData(
      {bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreEventModel: event);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      event.clear();
    }

    try {
      final result = await profileRepo.fetchProfileLikedFestivalData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
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

  Future<void> fetchProfileLikedDevsData({bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, exploreEventModel: event);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      event.clear();
    }

    try {
      final result = await profileRepo.fetchProfileLikedDevsData(page);

      result.fold((failure) {
        if (failure.toString().contains("404")) {
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

  void setScreenState({
    List<ContributionDevalayModel>? likeTemplesModel,
    List<ExploreEventModel>? exploreEventModel,
    List<FeedGetData>? feedList,
    required bool isLoading,
    String? message,
  }) {
    emit(ProfileLikedTempleLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        likeTemplesModel: likeTemplesModel,
        likeEventModel: exploreEventModel,
        feedList: feedList,
        currentPage: page));
  }
}
