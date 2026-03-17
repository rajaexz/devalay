import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_state.dart';
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/contribution/contribution_dev_model.dart';

class ContributeDevCubit extends Cubit<ContributeDevState> {
  ContributeDevCubit()
      : contributeRepo = getIt<ContributeRepo>(),
        super(ContributeDevInitial());

  ContributeRepo contributeRepo;
  int page = 1;
  bool hasMoreData = true;
  List<ContributionDevModel> allData = [];
  final devTitleController = TextEditingController();
  final devSubTitleController = TextEditingController();
  final devAboutController = TextEditingController();
  final pujaPurposeFormKey = GlobalKey<FormState>();
  final devInfoFormKey = GlobalKey<FormState>();
  bool isEditMode = false;
  bool showItems = false;
  int sectionIndex =0;

  void initializeForAddMode() {
    debugPrint('Initializing for ADD mode');
    isEditMode = false;
    clearAllControllers();
    resetState();
    emit(ContributeDevInitial());
  }

  void initializeForEditMode() {
    debugPrint('Initializing for EDIT mode');
    isEditMode = true;
  }

  void resetToInitialState() {
    clearAllControllers();
    resetState();
    isEditMode = false;
    emit(ContributeDevInitial());
    debugPrint('Reset to initial state');
  }

  void clearAllControllers() {
    devTitleController.clear();
    devSubTitleController.clear();
    devAboutController.clear();

    debugPrint('All controllers cleared');
  }

  void resetState() {
    showItems = false;
    isPosted = false;
    devId = null;
    page = 1;
    hasMoreData = true;
    allData.clear();
    debugPrint('State variables reset');
  }

  @override
  Future<void> close() {
    devTitleController.dispose();
    devSubTitleController.dispose();
    devAboutController.dispose();
    return super.close();
  }

  String? devId;
  bool isPosted = false;
  String? devTitleValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter dev name';
    }
    return null;
  }

  Future<void> fetchSingleContributeDevData(String id, {String? value}) async {
    try {
      final result = await contributeRepo
          .fetchSingleContributeTempleData(id, 'Dev', value: value);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (customResponse) {
        final data =
            ContributionDevModel.fromJson(customResponse.response?.data);
        devTitleController.text = data.title ?? '';
        devSubTitleController.text = data.subtitle ?? '';
        devAboutController.text = data.description ?? '';
        setScreenState(isLoading: false, singleData: data, data: allData);
      });
    } catch (e) {
      setScreenState(
          isLoading: false,
          message: "Unexpected error: $e",
          data: allData,
          hasError: true);
    }
  }

  Future<void> fetchContributeDevData({
    String? value,
    String filterQuery = '',
    String? approvedVal,
    String? rejectVal,
    String? draftVal,
    bool loadMoreData = false,
  }) async
  {
    if (!hasMoreData && loadMoreData) return;

    if (loadMoreData) {
      setScreenState(isLoading: false, data: allData);
      page++;
    } else
    {
      page = 1;
      hasMoreData = true;
      allData.clear();
      setScreenState(isLoading: true, data: []);
    }

    final result = await contributeRepo.fetchContributeTempleData(
      type: 'Dev',
      value: value,
      approvedVal: approvedVal,
      rejectVal: rejectVal,
      draftVal: draftVal,
      page: page,
    );

    result.fold(
          (failure) {
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          data: loadMoreData ? allData : [],
          hasError: true,
        );
      },
          (r) {
        try {
          final data = (r.response?.data as List)
              .map((x) => ContributionDevModel.fromJson(x))
              .toList();

          if (loadMoreData) {
            allData.addAll(data);
          } else {
            allData = data;
          }

          hasMoreData = data.length >= 10;

          setScreenState(
            isLoading: false,
            data: allData,
          );
        } catch (e) {
          setScreenState(
            isLoading: false,
            message: "Error processing data: $e",
            data: allData,
            hasError: true,
          );
        }
      },
    );
  }


  Future<void> deleteItem(String type, String id) async {
    final result = await contributeRepo.deleteItem(type, id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      // final data = (customResponse.response?.data as List)
      //     .map((x) => ContributionDevalayModel.fromJson(x))
      //     .toList();
      setScreenState(isLoading: false);
      fetchContributeDevData();
    });
  }

  Future<void> updateDev(String devId) async {
    final result = await contributeRepo.updateDevInfo(
        devId,
        devTitleController.text,
        devSubTitleController.text,
        devAboutController.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      setScreenState(isLoading: false, devId: devId);
    });
  }

  Future<void> updateDevAvatar(
      String devId, String avatarId, String value) async {
    final result = await contributeRepo.updateDevAvatar(devId, value, avatarId);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      setScreenState(isLoading: false, devId: devId);
    });
  }

  Future<void> createDev() async {
    final result = await contributeRepo.submitDev(devTitleController.text,
        devSubTitleController.text, devAboutController.text);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      devId = success.response?.data['id'].toString();
      isPosted = true;
      setScreenState(
        isLoading: false,
        devId: devId,
      );
    });
  }

  Future<void> updateDevPhoto(
      String templeId, List<File> image, String imageType) async {
    try {
      final result =
          await contributeRepo.updateDevPhoto(templeId, image, imageType);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionDevModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });
    } catch (e) {
      setScreenState(isLoading: false, message: "Unexpected error: $e");
    }
  }

  Future<void> updateDevAarti(
      String devId, Map<String, dynamic> aartiData) async {
    final result =
        await contributeRepo.updateDevAarti(devId, aartiData: aartiData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      final data = ContributionDevModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, singleData: data);
      print("qwretryuhgfdd------> $aartiData");
    });
  }

  void setScreenState({
    ContributionDevModel? singleData,
    List<ContributionDevModel>? data,
    required bool isLoading,
    String? message,
    String? devId,
    bool hasError = false,
  }) {

    emit(ContributeDevLoaded(
      singleData: singleData,
      model: data,
      loadingState: isLoading,
      errorMessage: message ?? '',
      devId: devId,
      hasError: hasError,
    ));
  }
}
