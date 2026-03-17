import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_state.dart';

import 'package:devalay_app/src/data/model/profile/profile_info_model.dart';
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/model/profile/following_request_model.dart';

class ProfileConnectionsCubit extends Cubit<ProfileConnectionsState> {
  ProfileConnectionsCubit()
      : profileRepo = getIt<ProfileRepo>(),
        super(ProfileConnectionsInitial());
  ProfileRepo profileRepo;
  ProfileInfoModel? connections;
  String? _userId;

  void init(String id) {
    _userId = id;
    fetchConnectionData();
  }


  Future<void> fetchConnectionData() async {
    if (_userId == null) return;
    
    setScreenState(isLoading: true);
    final result = await profileRepo.fetchProfileInfoData(_userId.toString());

    result.fold((failure) {
      setScreenState(
        isLoading: false,
        message: "Failed to load profile data",
      );
    }, (success) {
      if (success.response?.data != null) {
        final data = ProfileInfoModel.fromJson(success.response?.data);
        setScreenState(isLoading: false, profileInfoModel: data);
      } else {
        setScreenState(
          isLoading: false,
          message: "No data available",
        );
      }
    });
  }

  Future<void> updateRequestStatus(String status, String id) async {
    setScreenState(isLoading: true);
    final result = await profileRepo.updateRequestStatus(status, id);

    result.fold((failure) {
      setScreenState(
        isLoading: false,
        message: "Failed to update request status",
      );
    }, (success) {
      if (success.response?.data != null) {
        final data = FollowingRequestModel.fromJson(success.response?.data);
        setScreenState(isLoading: false, followingRequestModel: data);
        fetchConnectionData(); // Refresh the data after update
      } else {
        setScreenState(
          isLoading: false,
          message: "Failed to update request",
        );
      }
    });
  }

  Future<void> updateRequestDeleteStatus(String status, String id) async {
    final result = await profileRepo.updateRequestDeleteStatus(status, id);

    result.fold((failure) {
      Fluttertoast.showToast(msg: "Profile Unsuccessfully");
    }, (success) {
      final data = FollowingRequestModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, followingRequestModel: data);
      fetchConnectionData();
    });
  }

  Future<void> updateSendRequestDeleteStatus(String status, String id) async {
    final result = await profileRepo.updateSendRequestDeleteStatus(status, id);

    result.fold((failure) {
      Fluttertoast.showToast(msg: "Profile Unsuccessfully");
    }, (success) {
      final data = FollowingRequestModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, followingRequestModel: data);
      fetchConnectionData();
    });
  }

  Future<void> updateRequestSendStatus(String status, String id) async {
    final result = await profileRepo.updateRequestSendStatus(status, id);

    result.fold((failure) {
      Fluttertoast.showToast(msg: "Profile Unsuccessfully");
    }, (success) {
      // final data = FollowingRequestModel.fromJson(success.response?.data);
      // setScreenState(isLoading: false, followingRequestModel: data);
      fetchConnectionData();
    });
  }

  Future<void> updateFollowingStatus(String status, String id,context) async {
    final result = await profileRepo.updateFollowingStatus(status, id);

    result.fold((failure) {
      Fluttertoast.showToast(msg: "Profile Unsuccessfully");
    }, (success) {
      final data = ProfileInfoModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, profileInfoModel: data);
   
      fetchConnectionData();
      Navigator.pop(context);
    });
  }

  void setScreenState({
    ProfileInfoModel? profileInfoModel,
    FollowingRequestModel? followingRequestModel,
    required bool isLoading,
    String? message,
  }) {
    emit(ProfileConnectionsLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      profileInfoModel: profileInfoModel,
      followingRequestModel: followingRequestModel,
    ));
  }
}
