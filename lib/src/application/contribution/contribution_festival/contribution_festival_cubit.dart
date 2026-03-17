import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/contribution/contribution_festival/contribution_festival_state.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_festival_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';
import '../../../domain/repo_impl/contribution_repo.dart';

class ContributeFestivalCubit extends Cubit<ContributeFestivalState> {
  ContributeFestivalCubit()
      : contributeRepo = getIt<ContributeRepo>(),
        super(ContributeFestivalInitial());

  ContributeRepo contributeRepo;
  int page = 1;
  bool hasMoreData = true;

  ///festivle
  ///
  Map<String, int> selectedItems = {};
  bool showItems = false;
  List<String> selectedGod = [];
  bool isLoadingdev = false;

  List<ContributionFestivalModel> allData = [];
  List<Map<String, TextEditingController>> dateTimeControllers = [];
  final festivalTitleController = TextEditingController();
  final festivalSubTitleController = TextEditingController();
  final festivalAboutController = TextEditingController();
  final festivalHistoryController = TextEditingController();
  final festivalCelebrateController = TextEditingController();
  final festivalDosController = TextEditingController();
  final festivalDontsController = TextEditingController();
  final festivalInfoFormKey = GlobalKey<FormState>();
  final festivalAboutFormKey = GlobalKey<FormState>();
  final festivalCelebrateFormKey = GlobalKey<FormState>();

  bool isPosted = false;
  String? festivalId;

  String? festivalTitleValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter event name';
    }
    return null;
  }

  String? festivalSubTitleValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  Future<void> fetchContributeFestivalData(
      {String? value,
      String? approvedVal,
      String? rejectVal,
      String? draftVal,
      loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;
    setScreenState(isLoading: true, data: allData);
    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData.clear();
    }

    final result = await contributeRepo.fetchContributeTempleData(
        type: 'Festival',
        value: value,
        approvedVal: approvedVal,
        rejectVal: rejectVal,
        draftVal: draftVal,
        page: page);

    result.fold((failure) {
      hasMoreData = false;
      setScreenState(isLoading: false, data: allData);
      if (failure.toString() == "Not Found") {
        hasMoreData = false;
      }
    }, (success) {
      final data = (success.response?.data as List)
          .map((x) => ContributionFestivalModel.fromJson(x))
          .toList();
      allData.addAll(data);
      hasMoreData = data.isNotEmpty;
      setScreenState(isLoading: false, data: allData);
    });
  }

  // Method to clear all date-time controllers when needed (e.g., after form submission)
  void clearDateTimeControllers() {
    for (var controllerSet in dateTimeControllers) {
      for (var controller in controllerSet.values) {
        controller.dispose();
      }
    }
    dateTimeControllers.clear();
  }

  void addNewDateTimeSet() {
    dateTimeControllers.add({
      'startDate': TextEditingController(),
      'startTime': TextEditingController(),
      'endDate': TextEditingController(),
      'endTime': TextEditingController(),
    });

    emit(state);
  }

  void loadExistingDates(ContributionFestivalModel model) {
    clearDateTimeControllers();

    if (model.dates != null && model.dates!.isNotEmpty) {
      for (var dateEntry in model.dates!) {
        final controllers = {
          'startDate': TextEditingController(text: dateEntry.startDate),
          'startTime': TextEditingController(text: dateEntry.startTime),
          'endDate': TextEditingController(text: dateEntry.endDate.toString()),
          'endTime': TextEditingController(text: dateEntry.endTime),
        };
        dateTimeControllers.add(controllers);
      }
    } else {
      addNewDateTimeSet();
    }
  }

  Future<void> deleteItem(String type, String id) async {
    setScreenState(isLoading: true);
    final result = await contributeRepo.deleteItem(type, id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      if (failure.toString().contains("403") || failure.toString().contains("Permission denied")) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this item",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        emit(ContributeFestivalError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
      }
    }, (success) {
      if (success.response?.data is Map<String, dynamic> && 
          (success.response?.data['detail'] == "Permission denied" || success.response?.statusCode == 403)) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this item",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        setScreenState(isLoading: false, message: "Permission denied");
        emit(ContributeFestivalError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
        return;
      }
      setScreenState(isLoading: false);
      Fluttertoast.showToast(
        msg: "Item deleted successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      fetchContributeFestivalData();
    });
  }

  Future<void> updateFestivalPhoto(
      String templeId, List<File> image, String imageType) async {
    try {
      final result =
          await contributeRepo.updateFestivalPhoto(templeId, image, imageType);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionFestivalModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });
    } catch (e) {
      setScreenState(isLoading: false, message: "Unexpected error: $e");
    }
  }

  Future<void> updateAcceptBanner(
      String type, String festiveId, String id, String approved) async {
    final result = await contributeRepo.updateAcceptBanner(type, id, approved);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = AcceptBannerModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, acceptBannerModel: data);
      fetchSingleContributeFestivalData(festiveId, value: 'true');
    });
  }

  Future<void> submitFestivalReview(
    String type,
    String id,
    String approved, {
    Map<String, dynamic>? rejectReasons,
  }) async {
    final result = await contributeRepo.submitReview(
      type,
      id,
      approved,
      rejectReasons: rejectReasons,
    );

    result.fold(
      (failure) {
        setScreenState(isLoading: false, message: failure.toString());
      },
      (customResponse) {
        setScreenState(
          isLoading: false,
          festivalId: festivalId,
        );
      },
    );
  }

  Future<void> updateFestival(String festivalId) async {
    final result = await contributeRepo.updateFestivalInfo(
      festivalId,
      festivalTitleController.text,
      festivalSubTitleController.text,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      setScreenState(isLoading: false, festivalId: festivalId);
    });
  }

  Future<void> updateFestivalGod(String id, List<String> godIds) async {
    final result = await contributeRepo.updateFestivalGod(id, godIds);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      final data = ContributionFestivalModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateFestivalDate(
      String id, Map<String, String> dateTimeMap) async {
    final result = await contributeRepo.updateFestivalDate(id, dateTimeMap);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      final data = ContributionFestivalModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateFestivalAbout(String festivalId) async {
    final result = await contributeRepo.updateFestivalAbout(
      festivalId,
      festivalAboutController.text,
      festivalHistoryController.text,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      setScreenState(isLoading: false, festivalId: festivalId);
    });
  }

  Future<void> updateCelebrate(String festivalId) async {
    final result = await contributeRepo.updateCelebrate(
      festivalId,
      festivalCelebrateController.text,
      festivalDosController.text,
      festivalDontsController.text,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      setScreenState(isLoading: false, festivalId: festivalId);
    });
  }

  Future<void> createFestival() async {
    final result = await contributeRepo.submitFestival(
        festivalTitleController.text, festivalSubTitleController.text);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      festivalId = success.response?.data['id'].toString();
      isPosted = true;
      setScreenState(
        isLoading: false,
        festivalId: festivalId,
      );
    });
  }

  Future<void> fetchSingleContributeFestivalData(String id,
      {String? value}) async {
    setScreenState(isLoading: true);
    final result = await contributeRepo
        .fetchSingleContributeTempleData(id, 'Festival', value: value);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      if (failure.toString().contains("Permission denied")) {
        emit(ContributeFestivalError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
      }
    }, (success) {
      if (success.response?.data is Map<String, dynamic> && 
          success.response?.data['detail'] == "Permission denied") {
        setScreenState(isLoading: false, message: "Permission denied");
        emit(ContributeFestivalError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
        return;
      }
      final data = ContributionFestivalModel.fromJson(success.response?.data);
      festivalTitleController.text = data.title ?? '';
      festivalSubTitleController.text = data.subtitle ?? '';
      festivalAboutController.text = data.description ?? '';
      selectedItems = {};
      loadExistingDates(data);
      _loadExistingGods(data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  _loadExistingGods(ContributionFestivalModel model) {
    selectedItems = {};
    selectedGod = [];
    if (model.devs != null && model.devs!.isNotEmpty) {
      for (var godEntry in model.devs!) {
        final controllers = {
          'title': TextEditingController(text: godEntry.title ?? ''),
          'id': TextEditingController(text: godEntry.id.toString()),
        };
        selectedItems[controllers['title']!.text] =
            int.parse(controllers['id']?.text ?? '0');
        selectedGod.add(controllers['id']?.text ?? '');
      }
    } else {
      addNewDateTimeSet();
    }
  }

  void setScreenState(
      {List<ContributionFestivalModel>? data,
      ContributionFestivalModel? singleData,
      CommonModel? commonModel,
      AcceptBannerModel? acceptBannerModel,
      required bool isLoading,
      String? message,
      String? festivalId,
      bool hasError = false}) {
    emit(ContributeFestivalLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        festivalList: data,
        festivalId: festivalId,
        singleFestival: singleData,
        acceptBannerModel: acceptBannerModel,
        commonModel: commonModel,
        hasError: hasError));
  }
}
