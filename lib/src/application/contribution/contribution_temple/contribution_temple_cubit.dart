import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/data/model/contribution/common_model.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_devalay_model.dart';
import 'package:devalay_app/src/data/model/contribution/donateModel.dart';
import 'package:devalay_app/src/data/model/contribution/donatePaymentModel.dart';
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/model/contribution/accept_banner_model.dart';

class ContributeTempleCubit extends Cubit<ContributeTempleState> {
  ContributeTempleCubit()
      : contributeRepo = getIt<ContributeRepo>(),
        super(ContributeTempleInitial());

  ContributeRepo contributeRepo;

  ///=================================
  int sectionIndex = 0;
  int selectedChipIndex = 0;
  final List<String> filterTypes = [
    StringConstant.sortBy,
    StringConstant.orderBy
  ];
  final List<String> sortBy = [
    StringConstant.addedDate,
    StringConstant.alphabetically
  ];
  final List orderBy = [
    {
      'title': StringConstant.decending,
      'icon':
          'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/decending.svg'
    },
    {
      'title': StringConstant.ascending,
      'icon':
          'https://d3nvzmos5mh5ca.cloudfront.net/devalay_app/icons/ascending.svg'
    }
  ];
  String? selectedSortByIndex = '';
  String? selectedOrderByIndex = 'Decending';

  Map<String, int> selectedItems = {};
  bool showItems = false;
  List<String> selectedGod = [];
  bool isLoadingdev = false;
  Map<String, dynamic> godImages = {};
  String? commonId;
  Map<String, String> godApiResponseIds = {};

  int page = 1;
  bool hasMoreData = true;

  List<ContributionDevalayModel> allDate = [];

  final templeNameController = TextEditingController();
  final templeWebsiteController = TextEditingController();
  final templeGoverningController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final streetAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final landmarkController = TextEditingController();
  final pincodeController = TextEditingController();
  final nearestAirportController = TextEditingController();
  final nearestRailwayController = TextEditingController();
  final googleLinkController = TextEditingController();
  final fistHistoryController = TextEditingController();
  final secondHistoryController = TextEditingController();
  final thirdHistoryContoller = TextEditingController();
  final fourthHistoryController = TextEditingController();
  final fifthHistoryController = TextEditingController();
  final sixthHistoryController = TextEditingController();
  final firstStoryController = TextEditingController();
  final secondStoryController = TextEditingController();
  final thirdStoryController = TextEditingController();
  final fourthStoryController = TextEditingController();
  final fifthStoryController = TextEditingController();
  final firstEtymologyController = TextEditingController();
  final secondEtymologyController = TextEditingController();
  final thirdEtymologyController = TextEditingController();
  final fourthEtymologyController = TextEditingController();
  final firstArchitectureController = TextEditingController();
  final secondArchitectureController = TextEditingController();
  final thirdArchitectureController = TextEditingController();
  final fourthArchitectureController = TextEditingController();
  final taglineController = TextEditingController();
  final aboutController = TextEditingController();
  final governingName = TextEditingController();
  final governingSubtitle = TextEditingController();
  final governingDescription = TextEditingController();
  final templeAddressFromKey = GlobalKey<FormState>();
  final templeHistoryFromKey = GlobalKey<FormState>();
  final templeStoryFromKey = GlobalKey<FormState>();
  final templeEtymologyFromKey = GlobalKey<FormState>();
  final templeArchitectureFromKey = GlobalKey<FormState>();
  final donateFromKey = GlobalKey<FormState>();

  bool isPosted = false;
  String? templeId;
  String? governingId;

  bool isEditMode = false;

  String currentFilterQuery = '';

  void setCommonId(String id) {
    commonId = id;
    // You might want to emit a new state or update existing state
  }

  void initializeForAddMode() {
    debugPrint('Initializing for ADD mode');
    isEditMode = false;
    clearAllControllers();
    resetState();
    emit(ContributeTempleInitial());
  }

  void initializeForEditMode() {
    debugPrint('Initializing for EDIT mode');
    isEditMode = true;
  }

  void clearAllControllers() {
    templeNameController.clear();
    templeWebsiteController.clear();
    taglineController.clear();
    aboutController.clear();
    streetAddressController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    landmarkController.clear();
    pincodeController.clear();
    nearestAirportController.clear();
    nearestRailwayController.clear();
    googleLinkController.clear();

    fistHistoryController.clear();
    secondHistoryController.clear();
    thirdHistoryContoller.clear();
    fourthHistoryController.clear();
    fifthHistoryController.clear();
    sixthHistoryController.clear();

    firstStoryController.clear();
    secondStoryController.clear();
    thirdStoryController.clear();
    fourthStoryController.clear();
    fifthStoryController.clear();

    firstEtymologyController.clear();
    secondEtymologyController.clear();
    thirdEtymologyController.clear();
    fourthEtymologyController.clear();

    firstArchitectureController.clear();
    secondArchitectureController.clear();
    thirdArchitectureController.clear();
    fourthArchitectureController.clear();

    governingName.clear();
    governingSubtitle.clear();
    governingDescription.clear();

    debugPrint('All controllers cleared');
  }

  void resetState() {
    selectedItems.clear();
    selectedGod.clear();
    godImages.clear();
    showItems = false;
    isLoadingdev = false;
    isPosted = false;
    templeId = null;
    governingId = null;
    page = 1;
    hasMoreData = true;
    allDate.clear();

    debugPrint('State variables reset');
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Use email_validator plugin for proper email validation
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 1000000) {
      return 'Amount cannot exceed 10,00,000';
    }
    return null;
  }

  String? validatePAN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN is required';
    }
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid PAN (e.g., ABCDE1234F)';
    }
    return null;
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

          await fetchContributeTempleData(
            filterQuery: filterQuery,
            value: value,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
          break;
        case 1: // Under Review

          await fetchContributeTempleData(
            filterQuery: filterQuery,
            value: value,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "false",
            loadMoreData: false,
          );
          break;
        case 2: // Approved

          await fetchContributeTempleData(
            filterQuery: filterQuery,
            value: value,
            approvedVal: "true",
            rejectVal: "false",
            draftVal: "false",
            loadMoreData: false,
          );
          break;
        case 3: // Review

          await fetchContributeTempleData(
            filterQuery: filterQuery,
            value: "false",
            loadMoreData: false,
          );
        case 4: // Review
          allDate.clear();
          await fetchContributeTempleData(
            filterQuery: filterQuery,
            value: "true",
            loadMoreData: false,
          );
          break;
        default:
          await fetchContributeTempleData(
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
        data: allDate,
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

  void resetToInitialState() {
    clearAllControllers();
    resetState();
    isEditMode = false;
    emit(ContributeTempleInitial());
    debugPrint('Reset to initial state');
  }

  String? templeTitleValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter temple name';
    }
    return null;
  }
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  
  // Use email_validator plugin for proper email validation
  if (!EmailValidator.validate(value.trim())) {
    return 'Please enter a valid email address';
  }
  
  return null;
}


String? indianPhoneValidator(String? value) {
  // Allow empty values
  if (value == null || value.isEmpty) {
    return null;
  }
  
  // Remove spaces, dashes, and parentheses
  String cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  
  // Regular expression for Indian phone numbers
  // Matches: 10-digit numbers starting with 6-9
  // Also matches: +91 or 91 prefix followed by 10 digits
  final phonePattern = RegExp(
    r'^(\+91|91)?[6-9]\d{9}$',
  );
  
  if (!phonePattern.hasMatch(cleanedValue)) {
    return 'Please enter a valid Indian phone number';
  }
  
  return null;
}
String? notEmpty(String? value) {
  // Allow empty values
  if (value == null || value.isEmpty) {
    return null;
  }
  return null;
}


String? templeWebsiteControllerValidator(String? value) {
  // Allow empty values
  if (value == null || value.isEmpty) {
    return null;
  }
  
  // Regular expression for URL validation
  final urlPattern = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    caseSensitive: false,
  );
  
  if (!urlPattern.hasMatch(value)) {
    return 'Please enter a valid website URL';
  }
  
  return null;
}

  String? streetAddressControllerValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter temple address';
    }
    return null;
  }

  String? cityControllerValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter temple city';
    }
    return null;
  }

  String? stateControllerValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter temple state';
    }
    return null;
  }

  String? countryControllerValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter temple country';
    }
    return null;
  }

  String? pincodeControllerValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter pincode';
    }
    return null;
  }

  String? landmarkControllerValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  String? nearestAirportControllerValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  String? nearestRailwayControllerValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  String? googleLinkControllerValidator(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    return null;
  }

  String? templeHistoryFirstValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter temple name';
    }
    return null;
  }

  String? templeHistorySecondValidator(String? value) {
    if (value!.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? templeHistoryThirdValidator(String? value) {
    if (value!.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? templeHistoryFourthValidator(String? value) {
    if (value!.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? templeHistoryFifthValidator(String? value) {
    if (value!.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> fetchContributeTempleData(
      {String? value,
      String filterQuery = '',
      String? approvedVal,
      String? rejectVal,
      String? draftVal,
      bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;

    setScreenState(isLoading: true, data: allDate);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allDate.clear();
    }

    final result = await contributeRepo.fetchContributeTempleData(
        type: 'Devalay',
        value: value,
        approvedVal: approvedVal,
        rejectVal: rejectVal,
        draftVal: draftVal,
        filterQuery: filterQuery.isEmpty ? currentFilterQuery : filterQuery,
        page: page);
    result.fold(
      (failure) {
        if (failure.toString().contains("Invalid page.")) {
          hasMoreData = false;
          setScreenState(
            isLoading: false,
            data: allDate,
          );
          return;
        }

        // Handle other failures
        setScreenState(
          isLoading: false,
          message: failure.toString(),
          data: allDate,
        );
      },
      (r) {
        try {
          // Safely extract data from response
          final responseData = r.response?.data;

          if (responseData == null) {
            setScreenState(
              isLoading: false,
              message: "No data received from server",
              data: allDate,
            );
            return;
          }

          // Handle case where response contains error details
          if (responseData is Map && responseData.containsKey("detail")) {
            final detail = responseData["detail"].toString();
            if (detail.contains("Invalid page.")) {
              hasMoreData = false;
              setScreenState(
                isLoading: false,
                data: allDate,
              );
              return;
            }
          }

          // Process the data list
          List<dynamic> dataList;
          if (responseData is List) {
            dataList = responseData;
          } else if (responseData is Map && responseData.containsKey("data")) {
            dataList = responseData["data"] as List? ?? [];
          } else {
            // If response structure is unexpected, treat as empty list
            dataList = [];
          }

          final data = dataList
              .map((e) => ContributionDevalayModel.fromJson(e))
              .toList();

          if (loadMoreData) {
            allDate.addAll(data);
          } else {
            allDate = data;
          }

          // Check if we have more data to load
          // You might want to adjust this logic based on your API response structure
          hasMoreData = data.length >= 10;

          // If we received less than expected, we might be at the end
          if (data.isEmpty && loadMoreData) {
            hasMoreData = false;
          }

          setScreenState(
            isLoading: false,
            data: allDate,
          );
        } catch (e) {
          setScreenState(
            isLoading: false,
            message: "Error processing data: ${e.toString()}",
            data: allDate,
          );
        }
      },
    );
  }

  Future<void> fetchSingleContributTempleData(String id,
      {String? value}) async {
    setScreenState(isLoading: true);

    final result = await contributeRepo
        .fetchSingleContributeTempleData(id, 'Devalay', value: value);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final rawData = customResponse.response?.data;

      // Handle List or Map response safely
      ContributionDevalayModel? data;

      if (rawData is List && rawData.isNotEmpty) {
        data = ContributionDevalayModel.fromJson(rawData.first);
      } else if (rawData is Map<String, dynamic>) {
        data = ContributionDevalayModel.fromJson(rawData);
      } else {
        setScreenState(isLoading: false, message: 'Unexpected response format');
        return;
      }

      if (isEditMode) {
        templeNameController.text = data.title ?? '';
        templeWebsiteController.text = data.website ?? '';
        streetAddressController.text = data.address ?? '';
        cityController.text = data.city ?? '';
        stateController.text = data.state ?? '';
        countryController.text = data.country ?? '';
        pincodeController.text = data.pincode ?? '';
        landmarkController.text = data.landmark ?? '';
        nearestAirportController.text = data.nearestAirport ?? '';
        nearestRailwayController.text = data.nearestRailway ?? '';
        googleLinkController.text = data.googleMapLink ?? '';
        sixthHistoryController.text = data.templeHistory ?? '';
        fifthStoryController.text = data.legend ?? '';
        fourthEtymologyController.text = data.etymology ?? '';
        fourthArchitectureController.text = data.architecture ?? '';
        loadExistingGods(data);
      }

      setScreenState(isLoading: false, singleData: data,   data: allDate,);
    });
  }

  void setSelectedGods({
    required Map<String, int> selectedItems,
    required List<String> selectedGod,
    Map<String, String>? godApiResponseIds,
  }) {
    this.selectedItems = selectedItems;
    this.selectedGod = selectedGod;
    if (godApiResponseIds != null) {
      this.godApiResponseIds = godApiResponseIds;
    }
    // Emit updated state if needed
    if (state is ContributeTempleLoaded) {
      emit((state as ContributeTempleLoaded).copyWith(
          // Add any necessary state updates here
          ));
    }
  }

  void setGodImages(Map<String, dynamic> images) {
    godImages = images;

    debugPrint('God images set for: ${images.keys.join(", ")}');
  }

  void loadExistingGods(ContributionDevalayModel model) {
    if (!isEditMode) return;

    isLoadingdev = true;

    try {
      selectedItems.clear();
      selectedGod.clear();
      godImages.clear();

      if (model.devs == null || model.devs!.isEmpty) {
        debugPrint('No gods data found in the model');
        isLoadingdev = false;
        return;
      }

      for (var godEntry in model.devs!) {
        if (godEntry.dev != null &&
            godEntry.dev!.title != null &&
            godEntry.dev!.id != null) {
          selectedItems[godEntry.dev!.title!] = godEntry.dev!.id!;
          selectedGod.add(godEntry.dev!.id.toString());

          if (godEntry.image != null && godEntry.image!.isNotEmpty) {
            godImages[godEntry.dev!.title!] = godEntry.image;
          }
        }
      }

      setSelectedGods(
        selectedItems: selectedItems,
        selectedGod: selectedGod,
      );

      debugPrint('Loaded existing gods: ${selectedItems.keys.join(", ")}');
      debugPrint('Loaded god IDs: ${selectedGod.join(", ")}');
    } catch (e) {
      debugPrint('Error loading existing gods: $e');
    } finally {
      isLoadingdev = false;
    }
  }

  Future<void> createTemple() async {
    final result = await contributeRepo.submitTemple(
      templeNameController.text,
      templeWebsiteController.text,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      templeId = customResponse.response?.data['id'].toString();
      governingId =
          customResponse.response?.data['governed_by']['id'].toString();
      isPosted = true;
      setScreenState(
          isLoading: false, templeId: templeId, governingId: governingId);
    });
  }

  Future<void> updateTemple(String templeId, String governingId) async {
    int a = 1;
    final result = await contributeRepo.updateTempleInfo(
        templeId,
        templeNameController.text,
        templeWebsiteController.text,
        a,
        governingName.text,
        governingSubtitle.text,
        governingDescription.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      setScreenState(
          isLoading: false, templeId: templeId, governingId: governingId);
      final data = customResponse.response?.data;
      // updateTempleGoverningBody(data?[governingId]);
    });
  }

  Future<void> submitDevalayReview(
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
          templeId: templeId,
          governingId: governingId,
        );
      },
    );
  }

  Future<void> updateAcceptBanner(
      String type, String templeId, String id, String approved) async {
    final result = await contributeRepo.updateAcceptBanner(type, id, approved);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = AcceptBannerModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, acceptBannerModel: data);
      fetchSingleContributTempleData(templeId, value: 'true');
    });
  }

  Future<void> updateAcceptDevs(
      String templeId, String id, String approved) async {
    final result =
        await contributeRepo.updateAcceptDevs(templeId, id, approved);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = CommonModel.fromJson(customResponse.response?.data);
      setScreenState(isLoading: false, commonModel: data);
      fetchSingleContributTempleData(templeId, value: 'true');
    });
  }

  Future<void> deleteImage(String type, String templeId, String id) async {
    setScreenState(isLoading: true);
    final result = await contributeRepo.deleteImage(type, templeId);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      if (failure.toString().contains("403") ||
          failure.toString().contains("Permission denied")) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this image",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        emit(ContributeTempleError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
      }
    }, (success) {
      if (success.response?.data is Map<String, dynamic> &&
          (success.response?.data['detail'] == "Permission denied" ||
              success.response?.statusCode == 403)) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this image",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        setScreenState(isLoading: false, message: "Permission denied");
        emit(ContributeTempleError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
        return;
      }
      final data = ContributionDevalayModel.fromJson(success.response?.data);
      setScreenState(isLoading: false, singleData: data);
      Fluttertoast.showToast(
        msg: "Image deleted successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      fetchSingleContributTempleData(id, value: 'true');
    });
  }

  Future<void> deleteItem(String type, String id) async {
    setScreenState(isLoading: true);
    final result = await contributeRepo.deleteItem(type, id);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      if (failure.toString().contains("403") ||
          failure.toString().contains("Permission denied")) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this item",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        emit(ContributeTempleError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
      }
    }, (success) {
      if (success.response?.data is Map<String, dynamic> &&
          (success.response?.data['detail'] == "Permission denied" ||
              success.response?.statusCode == 403)) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this item",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        setScreenState(isLoading: false, message: "Permission denied");
        emit(ContributeTempleError(
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
      // Refresh the draft list after successful deletion
      fetchContributeTempleData(
        draftVal: "true",
        approvedVal: "false",
        rejectVal: "false",
        loadMoreData: false,
      );
    });
  }

  Future<void> updateTempleAddress(String templeId) async {
    final result = await contributeRepo.updateTempleAddress(
        templeId,
        streetAddressController.text,
        cityController.text,
        stateController.text,
        countryController.text,
        pincodeController.text,
        landmarkController.text,
        nearestAirportController.text,
        nearestRailwayController.text,
        googleLinkController.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> getLocationFromGoogleApi(String input) async {
    final currentState = state is ContributeTempleLoaded ? state as ContributeTempleLoaded : ContributeTempleLoaded(loadingState: false);
    emit(currentState.copyWith(
      locationLoading: true,
      locationError: null,
      locationResults: [],
    ));
    final result = await contributeRepo.getLocationFromGoogleApi(input);
    result.fold(
          (failure) {
        final newState = state as ContributeTempleLoaded;
        emit(newState.copyWith(
          locationLoading: false,
          locationError: "Failed to fetch locations",
        ));
      },
          (response) {
        final newState = state as ContributeTempleLoaded;
        final responseData = response.response?.data;
        List<dynamic> newResults = [];
        // Check the response data for the 'predictions' key
        if (responseData is List) {
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

  Future<void> updateTemplePhoto(
      String templeId, List<File> banner, List<File> gallery) async {
    try {
      final result =
          await contributeRepo.updateTemplePhoto(templeId, banner, gallery);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionDevalayModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });
    } catch (e) {
      setScreenState(isLoading: false, message: "Unexpected error: $e");
    }
  }

  Future<void> updateTempleBannerPhoto(
      String templeId, List<File> banner, String imageType) async {
    try {
      final result = await contributeRepo.updateTempleBannerPhoto(
          templeId, banner, imageType);

      result.fold((failure) {
        setScreenState(isLoading: false, message: failure.toString());
      }, (r) {
        final data = ContributionDevalayModel.fromJson(r.response?.data);
        setScreenState(isLoading: false, singleData: data);
      });
    } catch (e) {
      setScreenState(isLoading: false, message: "Unexpected error: $e");
    }
  }

  Future<void> rewriteHistoryWithAIApi(String question1, String question2,
      String question3, String question4, String question5) async {
    List<Map<String, String>> qaData = [
      {
        "question": question1,
        "answer": fistHistoryController.text,
      },
      {
        "question": question2,
        "answer": secondHistoryController.text,
      },
      {
        "question": question3,
        "answer": thirdHistoryContoller.text,
      },
      {
        "question": question4,
        "answer": fourthHistoryController.text,
      },
      {
        "question": question5,
        "answer": fifthHistoryController.text,
      }
    ];
    final result =
        await contributeRepo.rewriteWithAIApi('temple_history', qaData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      final content = r.response?.data['content'] as String?;
      if (content != null) {
        sixthHistoryController.text = content;
      }
    });
  }

  Future<void> rewriteStoriesWithAI(String question1, String question2,
      String question3, String question4) async {
    List<Map<String, String>> qaData = [
      {
        "question": question1,
        "answer": firstStoryController.text,
      },
      {
        "question": question2,
        "answer": secondStoryController.text,
      },
      {
        "question": question3,
        "answer": thirdStoryController.text,
      },
      {
        "question": question4,
        "answer": fourthStoryController.text,
      },
    ];
    final result = await contributeRepo.rewriteWithAIApi('legend', qaData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      final content = r.response?.data['content'] as String?;
      if (content != null) {
        fifthStoryController.text = content;
      }
    });
  }

  Future<void> rewriteEtymologyWithAI(
      String question1, String question2, String question3) async {
    List<Map<String, String>> qaData = [
      {
        "question": question1,
        "answer": firstEtymologyController.text,
      },
      {
        "question": question2,
        "answer": secondEtymologyController.text,
      },
      {
        "question": question3,
        "answer": thirdEtymologyController.text,
      },
    ];
    final result = await contributeRepo.rewriteWithAIApi('etymology', qaData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      final content = r.response?.data['content'] as String?;
      if (content != null) {
        fourthEtymologyController.text = content;
      }
    });
  }

  Future<void> rewriteArchitectureWithAI(
      String question1, String question2, String question3) async {
    List<Map<String, String>> qaData = [
      {
        "question": question1,
        "answer": firstArchitectureController.text,
      },
      {
        "question": question2,
        "answer": secondArchitectureController.text,
      },
      {
        "question": question3,
        "answer": thirdArchitectureController.text,
      }
    ];
    final result =
        await contributeRepo.rewriteWithAIApi('architecture', qaData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      final content = r.response?.data['content'] as String?;
      if (content != null) {
        fourthArchitectureController.text = content;
      }
    });
  }

  Future<void> rewriteTaglineWithAI() async {
    List<Map<String, String>> qaData = [
      {
        "question": 'temple_history',
        "answer": sixthHistoryController.text,
      },
      {
        "question": 'legend',
        "answer": fifthStoryController.text,
      },
      {
        "question": 'etymology',
        "answer": fourthEtymologyController.text,
      },
      {
        "question": 'architecture',
        "answer": fourthArchitectureController.text,
      }
    ];
    final result = await contributeRepo.rewriteWithAIApi('subtitle', qaData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      final content = r.response?.data['content'] as String?;
      if (content != null) {
        taglineController.text = content;
      }
    });
  }

  Future<void> rewriteAboutWithAI() async {
    List<Map<String, String>> qaData = [
      {
        "question": 'temple_history',
        "answer": sixthHistoryController.text,
      },
      {
        "question": 'legend',
        "answer": fifthStoryController.text,
      },
      {
        "question": 'etymology',
        "answer": fourthEtymologyController.text,
      },
      {
        "question": 'architecture',
        "answer": fourthArchitectureController.text,
      }
    ];
    final result = await contributeRepo.rewriteWithAIApi('description', qaData);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      final content = r.response?.data['content'] as String?;
      if (content != null) {
        aboutController.text = content;
      }
    });
  }

  Future<void> updateTempleHistory(String templeId) async {
    final result = await contributeRepo.updateTempleHistory(
        templeId,
        fistHistoryController.text,
        secondHistoryController.text,
        thirdHistoryContoller.text,
        fourthHistoryController.text,
        fifthHistoryController.text,
        sixthHistoryController.text);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateTempleStories(String templeId) async {
    final result = await contributeRepo.updateTempleStories(
        templeId,
        firstStoryController.text,
        secondStoryController.text,
        thirdStoryController.text,
        fourthStoryController.text,
        fifthStoryController.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateTempleEtymology(String templeId) async {
    final result = await contributeRepo.updateTempleEtymology(
      templeId,
      firstEtymologyController.text,
      secondEtymologyController.text,
      thirdEtymologyController.text,
      fourthEtymologyController.text,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateTempleArchitecture(String templeId) async {
    final result = await contributeRepo.updateTempleArchitecture(
        templeId,
        firstArchitectureController.text,
        secondArchitectureController.text,
        thirdArchitectureController.text,
        fourthArchitectureController.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<void> updateTempleEssence(String templeId) async {
    final result = await contributeRepo.updateTempleEssence(
        templeId, taglineController.text, aboutController.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleData: data);
    });
  }

  Future<CommonModel?> updateTempleGod(String id, String devId) async {
    final result = await contributeRepo.updateTempleGod(id, devId);

    return result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      return null; // Return null on failure
    }, (r) {
      final dataMap = r.response?.data;
      final data = CommonModel.fromJson(dataMap);

      setScreenState(isLoading: false, commonModel: data);
      return data; // Return the CommonModel on success
    });
  }

  // Update the updateGodPhoto method to use the API response ID
  Future<void> updateGodPhoto(String id, File? banner, String devalayId) async {
    final result = await contributeRepo.updateGodPhoto(id, banner, devalayId);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final dataMap = r.response?.data;
      final data = CommonModel.fromJson(dataMap);

      setScreenState(isLoading: false, commonModel: data);
    });
  }

  Future<void> updateTempleGoverningBody(String templeId) async {
    final result = await contributeRepo.updateTempleGoverningBody(templeId,
        governingName.text, governingSubtitle.text, governingDescription.text);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ContributionDevalayModel.fromJson(r.response?.data);
      debugPrint(data.toString());
      setScreenState(isLoading: false);
    });
  }

  Future<void> updateDonate(String name, String email, String mobileNumber,
      String message, String amount, String pan) async {
    final result = await contributeRepo.updateDonate(
        name, email, mobileNumber, message, amount, pan);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = DonateModel.fromJson(customResponse.response?.data);
      setScreenState(
          isLoading: false,
          donateModel: data,
          message: "Update Donate : ${data.id}");
      updateDonatePayment(data.id.toString());
    });
  }

  Future<void> updateDonatePayment(String donationId) async {
    final result = await contributeRepo.updateDonatePayment(donationId);
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) async {
      final data = DonatePaymentModel.fromJson(customResponse.response?.data);
      setScreenState(
          isLoading: false,
          donatePaymentModel: data,
          message: "Update Donate : ${data.paymentUrl}");

      await _launchPaymentUrl(data.paymentUrl);
    });
  }

  Future<void> _launchPaymentUrl(String? url) async {
    if (url == null || url.isEmpty) {
      print('Payment URL is empty');
      return;
    }

    try {
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);

      bool launched = false;

      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('External application failed: $e');
      }

      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          print('Platform default failed: $e');
        }
      }

      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        } catch (e) {
          print('In-app web view failed: $e');
        }
      }

      if (!launched) {
        throw Exception('All launch methods failed for URL: $formattedUrl');
      }
    } catch (e) {
      print('Error launching payment URL: $e');
      _showPaymentUrlError(url);
    }
  }

  void _showPaymentUrlError(String url) {
    // You can show a dialog or snackbar here
    print('Please open this URL manually in your browser: $url');
    // Or copy to clipboard and show message
  }

  void setScreenState(
      {List<ContributionDevalayModel>? data,
      ContributionDevalayModel? singleData,
      CommonModel? commonModel,
      AcceptBannerModel? acceptBannerModel,
      DonateModel? donateModel,
      DonatePaymentModel? donatePaymentModel,
      required bool isLoading,
      String? message,
      String? templeId,
      String? governingId,
      bool hasError = false}) {
    emit(ContributeTempleLoaded(
        loadingState: isLoading,
        errorMessage: message ?? '',
        templeList: data,
        singleTemple: singleData,
        acceptBannerModel: acceptBannerModel,
        donateModel: donateModel,
        donatePaymentModel: donatePaymentModel,
        commonModel: commonModel,
        templeId: templeId,
        governingId: governingId,
        hasError: hasError,
        currentPage: page));
  }

  void clearFilters() {
    selectedSortByIndex = 'Likes';
    selectedOrderByIndex = 'Decending';
    currentFilterQuery = '';
    page = 1;
    allDate.clear();
    hasMoreData = true;
  }
}
