import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_state.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_puja_model.dart';
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';

class ContributePujaCubit extends Cubit<ContributePujaState> {
  ContributePujaCubit()
      : contributeRepo = getIt<ContributeRepo>(),
        super(ContributePujaInitial());

  ContributeRepo contributeRepo;
  int page = 1;
  bool hasMoreData = true;

  List<ContributionPujaModel> allData = [];

  final pujaTitleController = TextEditingController();
  final pujaSubTitleController = TextEditingController();
  final pujaAboutController = TextEditingController();
  final pujaPurposeController = TextEditingController();
  final pujaProcedureController = TextEditingController();

  final pujaInfoFormKey = GlobalKey<FormState>();
  final pujaPurposeFormKey = GlobalKey<FormState>();
  bool isPosted = false;
  String? pujaId;
//============Filter Variables================
 int  sectionIndex = 0;
  int selectedChipIndex = 0;
  final List<String> filterTypes = [StringConstant.sortBy, StringConstant.orderBy];
  final List<String> sortBy = [ StringConstant.addedDate, StringConstant.alphabetically];
  final List orderBy = [
    {
      'title': StringConstant.decending,
      'icon': 'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/decending.svg'
    },
    {
      'title': StringConstant.ascending,
      'icon': 'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/ascending.svg'
    }
  ];
  String? selectedSortByIndex = '';
  String? selectedOrderByIndex = 'Decending';
  String currentFilterQuery = '';

  String? pujaTitleValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter event name';
    }
    return null;
  }

  String? pujaSubTitleValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  String? pujaAboutValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  Future<void> updatePuja(String pujaId) async {
    final result = await contributeRepo.updatePujaInfo(
        pujaId,
        pujaTitleController.text,
        pujaSubTitleController.text,
        pujaAboutController.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      setScreenState(isLoading: false, pujaId: pujaId);
    });
  }

  Future<void> updatePujaPhoto(
      String pujaId, List<File> image, String imageType) async {
    try {
      final result = await contributeRepo.updatePujaPhoto(
          pujaId, image, imageType);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionPujaModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });
    } catch (e) {
      setScreenState(isLoading: false, message: "Unexpected error: $e");
    }
  }

  Future<void> updatePujaAllPhoto(
      String pujaId, List<File> banner, List<File> gallery) async {
    try {
      final result =
      await contributeRepo.updatePujaAllPhoto(pujaId, banner, gallery);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionPujaModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });
    } catch (e) {
      setScreenState(isLoading: false, message: "Unexpected error: $e");
    }
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
      // setScreenState(isLoading: false);
      fetchContributePujaData();
    });
  }

  Future<void> updatePujaPurpose(
      String pujaId,  Map<String, dynamic> purposeOutput, Map<String, dynamic> procedureOutput ) async {

      final result = await contributeRepo.updatePujaPurpose(
          pujaId, purposeOutput: purposeOutput,procedureOutput:  procedureOutput);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionPujaModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });

  }
  Future<void> updatePujaGod(String id, List<String> godIds) async {
    final result = await contributeRepo.updatePujaGod(id, godIds);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      final data = ContributionPujaModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> submitPujaReview(
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
          pujaId: pujaId,
        );
      },
    );
  }

  Future<void> createPuja() async {
    final result = await contributeRepo.submitPuja(pujaTitleController.text,
        pujaSubTitleController.text, pujaAboutController.text);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      pujaId = success.response?.data['id'].toString();
      isPosted = true;
      setScreenState(
        isLoading: false,
        pujaId: pujaId,
      );
    });
  }

  // Future<void> fetchContributePujaData(
  //     {String? value,
  //     String? approvedVal,
  //     String? rejectVal,
  //     String? draftVal,
  //     bool loadMoreData = false}) async {
  //   if (!hasMoreData && loadMoreData) return;
  //   setScreenState(isLoading: true, data: allData);
  //   if (loadMoreData) {
  //     page++;
  //   } else {
  //     page = 1;
  //     allData.clear();
  //   }

  //   final result = await contributeRepo.fetchContributeTempleData(
  //       type: 'Puja',
  //       value: value,
  //       approvedVal: approvedVal,
  //       rejectVal: rejectVal,
  //       draftVal: draftVal,
  //       page: page);

  //   result.fold((failure) {
  //     hasMoreData = false;
  //     if (failure.toString().contains("Permission denied")) {
  //       setScreenState(
  //         isLoading: false,
  //         message: failure.toString(),
  //         isPermissionDenied: true,
  //       );
  //     } else {
  //     setScreenState(isLoading: false, data: allData);
  //     if (failure.toString() == "Not Found") {
  //       hasMoreData = false;
  //       }
  //     }
  //   }, (success) {
  //     final data = (success.response?.data as List)
  //         .map((x) => ContributionPujaModel.fromJson(x))
  //         .toList();
  //     allData.addAll(data);
  //     hasMoreData = data.isNotEmpty;
  //     setScreenState(isLoading: false, data: allData);
  //   });
  // }



  Future<void> fetchContributePujaData({
    String? value,
    String filterQuery = '',
    String? approvedVal,
    String? rejectVal,
    String? draftVal,
    bool loadMoreData = false
  }) async {
    if (!hasMoreData && loadMoreData) return;

    setScreenState(isLoading: true, data: allData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData.clear();
    }

    final result = await contributeRepo.fetchContributeTempleData(
      type: 'Puja',
      value: value,
      approvedVal: approvedVal,
      rejectVal: rejectVal,
      draftVal: draftVal,
      filterQuery: filterQuery.isEmpty ? currentFilterQuery : filterQuery,
      page: page
    );

      result.fold((failure) {
      hasMoreData = false;
      if (failure.toString().contains("Permission denied")) {
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          isPermissionDenied: true,
        );
      } else {
      setScreenState(isLoading: false, data: allData);
      if (failure.toString() == "Not Found") {
        hasMoreData = false;
        }
      }
    }, (r) {
        final data = (r.response?.data as List)
            .map((e) => ContributionPujaModel.fromJson(e))
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
      },
    );
  }

  Future<void> fetchSingleContributePujaData(String id, {String? value}) async {
      setScreenState(isLoading: true);
    final result = await contributeRepo
        .fetchSingleContributeTempleData(id, 'Puja', value: value);
   result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      if (failure.toString().contains("Permission denied")) {
        emit(ContributePujaError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
      }
    }, (success) {
      if (success.response?.data is Map<String, dynamic> && 
          success.response?.data['detail'] == "Permission denied") {
        setScreenState(isLoading: false, message: "Permission denied");
        emit(ContributePujaError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
        return;
      }
      final data = ContributionPujaModel.fromJson(success.response?.data);
      pujaTitleController.text = data.title ?? '';
      pujaSubTitleController.text = data.subtitle ?? '';
      pujaAboutController.text = data.description ?? '';

      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateAcceptBanner(
      String type, String templeId, String id, String approved) async {
    final result = await contributeRepo.updateAcceptBanner(type, id, approved);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = AcceptBannerModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, acceptBannerModel: data);
      fetchSingleContributePujaData(templeId, value: 'true');
    });
  }


  Future<void> applyFilter({
    String? sortBy,
    String? orderBy,
    String? value,
    int? newSectionIndex,
  }) async {
    try {
      // Update filter selections in cubit
      if (sortBy != null) selectedSortByIndex = sortBy;
      if (orderBy != null) selectedOrderByIndex = orderBy;
      if (newSectionIndex != null) sectionIndex = newSectionIndex;

      debugPrint('Applying filter with sectionIndex: $sectionIndex');
      final filterQuery = buildFilterQuery();

      switch (sectionIndex) {
        case 0: // Draft
          await fetchContributePujaData(
            
            filterQuery: filterQuery,
            value: value,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
          break;
        case 1: // Under Review
          await fetchContributePujaData(
           
            filterQuery: filterQuery,
            value: value,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "false",
            loadMoreData: false,
          );
          break;
        case 2: // Approved
          await fetchContributePujaData(
           
            filterQuery: filterQuery,
            value: value,
            approvedVal: "true",
            rejectVal: "false",
            draftVal: "false",
            loadMoreData: false,
          );
          break;
        case 3: // Review
          await fetchContributePujaData(
         
            filterQuery: filterQuery,
            value: "false",
            loadMoreData: false,
          );
            case 4: // Review
          await fetchContributePujaData(
         
            filterQuery: filterQuery,
            value: "true",
            
            loadMoreData: false,
          );
          break;
        default:
          await fetchContributePujaData(
            filterQuery: filterQuery,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
      }

         } catch (e) {
      debugPrint('Error applying filter: $e');
      setScreenState(
        isLoading: false,
        message: "Filter error: $e",
        data: allData,
        hasError: true,
      );
      rethrow;
    }
  }

  String buildFilterQuery() {
    final List<String> queryParams = [];

    if (selectedSortByIndex != null) {
      String sortBy = selectedSortByIndex!.toLowerCase();

      if (sortBy == 'added date') sortBy = 'recent';
      if (sortBy == 'alphabetically') sortBy = 'alphabetically';

      queryParams.add('&sort_by=$sortBy');
    }

    if (selectedOrderByIndex != null) {
      String orderBy = selectedOrderByIndex == 'Ascending' ? 'asce' : 'desc';
      queryParams.add('&order_by=$orderBy');
    }

    return queryParams.isEmpty ? '' : queryParams.join('');
  }

 

  void clearFilters() {
    selectedSortByIndex = 'Likes';
    selectedOrderByIndex = 'Decending';
    currentFilterQuery = '';
    page = 1;
    allData.clear();
    hasMoreData = true;
  }


  void setScreenState(
      {List<ContributionPujaModel>? data,
      ContributionPujaModel? singleData,
        CommonModel? commonModel,
        AcceptBannerModel? acceptBannerModel,
      required bool isLoading,
      String? message,
      String? pujaId,
      bool hasError = false,
      bool isPermissionDenied = false}) {
    emit(ContributePujaLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        pujaList: data,
        acceptBannerModel: acceptBannerModel,
        commonModel: commonModel,
        pujaId: pujaId,
        singlePuja: singleData,
        hasError: hasError,
        isPermissionDenied: isPermissionDenied));
  }
}
