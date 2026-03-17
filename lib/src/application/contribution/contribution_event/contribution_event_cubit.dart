import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';
import '../../../data/model/contribution/contribution_event_model.dart';

class ContributeEventCubit extends Cubit<ContributeEventState> {
  ContributeEventCubit()
      : contributeRepo = getIt<ContributeRepo>(),
        super(ContributeEventInitial());

  ContributeRepo contributeRepo;

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
  String currentFilterQuery = '';

  int page = 1;
  bool hasMoreData = true;

  Map<String, int> selectedItems = {};
  bool showItems = false;
  List<String> selectedGod = [];

  List<ContributionEventModel> allData = [];

  List<Map<String, TextEditingController>> dateTimeControllers = [];
  int sectionIndex = 0;
  final eventTitleController = TextEditingController();
  final eventSubTitleController = TextEditingController();
  final eventAboutController = TextEditingController();
  final streetAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final pincodeController = TextEditingController();
  final nearestAirportController = TextEditingController();
  final nearestRailwayController = TextEditingController();
  final googleLinkController = TextEditingController();
  final dosController = TextEditingController();
  final dontsController = TextEditingController();
  final celebrateController = TextEditingController();

  final eventInfoFormKey = GlobalKey<FormState>();
  final eventAddressFormKey = GlobalKey<FormState>();
  final eventDetailsFormKey = GlobalKey<FormState>();
  bool isPosted = false;
  String? eventId;
  bool isEditMode = false;

  void initializeForAddMode() {
    debugPrint('Initializing for ADD mode');
    isEditMode = false;
    clearAllControllers();
    resetState();
    emit(ContributeEventInitial());
  }

  void initializeForEditMode() {
    debugPrint('Initializing for EDIT mode');
    isEditMode = true;
  }

  void clearDateTimeControllers() {
    for (var controllerSet in dateTimeControllers) {
      for (var controller in controllerSet.values) {
        controller.dispose();
      }
    }
    dateTimeControllers.clear();
  }

  void resetState() {
    selectedItems.clear();
    selectedGod.clear();
    showItems = false;
    isPosted = false;
    eventId = null;
    page = 1;
    hasMoreData = true;
    allData.clear();
    debugPrint('State variables reset');
  }

  void resetToInitialState() {
    clearAllControllers();
    resetState();
    isEditMode = false;
    emit(ContributeEventInitial());
    debugPrint('Reset to initial state');
  }

  void clearAllControllers() {
    eventTitleController.clear();
    eventSubTitleController.clear();
    eventAboutController.clear();
    streetAddressController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    pincodeController.clear();
    nearestAirportController.clear();
    nearestRailwayController.clear();
    googleLinkController.clear();
    dosController.clear();
    dontsController.clear();
    celebrateController.clear();

    for (var controllerSet in dateTimeControllers) {
      for (var controller in controllerSet.values) {
        controller.clear();
      }
    }

    debugPrint('All controllers cleared');
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

  void loadExistingDates(ContributionEventModel model) {
    clearDateTimeControllers();

    if (model.dates != null && model.dates!.isNotEmpty) {
      for (var dateEntry in model.dates!) {
        final controllers = {
          'startDate': TextEditingController(
              text: dateEntry.startDate?.toString() ?? ''),
          'startTime': TextEditingController(text: dateEntry.startTime ?? ''),
          'endDate':
              TextEditingController(text: dateEntry.endDate?.toString() ?? ''),
          'endTime': TextEditingController(text: dateEntry.endTime ?? ''),
        };
        dateTimeControllers.add(controllers);
      }
    } else {
      addNewDateTimeSet();
    }
  }

  @override
  Future<void> close() {
    clearDateTimeControllers();
    eventTitleController.dispose();
    eventSubTitleController.dispose();
    eventAboutController.dispose();
    streetAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pincodeController.dispose();
    nearestAirportController.dispose();
    nearestRailwayController.dispose();
    googleLinkController.dispose();
    dosController.dispose();
    dontsController.dispose();
    celebrateController.dispose();
    return super.close();
  }
String? eventTitleValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter event name';
  }
  if (value.length < 3) {
    return 'Event name must be at least 3 characters';
  }
  return null;
}

String? eventSubTitleValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 3) {
    return 'Subtitle must be at least 3 characters';
  }
  return null;
}

String? eventAboutValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 10) {
    return 'Description must be at least 10 characters';
  }
  return null;
}

String? streetAddressValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 5) {
    return 'Street address must be at least 5 characters';
  }
  return null;
}

String? cityValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 2) {
    return 'City name must be at least 2 characters';
  }
  // Allow only letters and spaces
  final cityPattern = RegExp(r'^[a-zA-Z\s]+$');
  if (!cityPattern.hasMatch(value)) {
    return 'City name should contain only letters';
  }
  return null;
}

String? stateValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 2) {
    return 'State name must be at least 2 characters';
  }
  // Allow only letters and spaces
  final statePattern = RegExp(r'^[a-zA-Z\s]+$');
  if (!statePattern.hasMatch(value)) {
    return 'State name should contain only letters';
  }
  return null;
}

String? countryValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 2) {
    return 'Country name must be at least 2 characters';
  }
  // Allow only letters and spaces
  final countryPattern = RegExp(r'^[a-zA-Z\s]+$');
  if (!countryPattern.hasMatch(value)) {
    return 'Country name should contain only letters';
  }
  return null;
}

String? pincodeValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  // Indian pincode validation - exactly 6 digits
  final pincodePattern = RegExp(r'^\d{6}$');
  if (!pincodePattern.hasMatch(value)) {
    return 'Please enter a valid 6-digit pincode';
  }
  return null;
}

String? landmarkValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 3) {
    return 'Landmark must be at least 3 characters';
  }
  return null;
}

String? nearestAirportValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 3) {
    return 'Airport name must be at least 3 characters';
  }
  return null;
}

String? nearestRailwayValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 3) {
    return 'Railway station name must be at least 3 characters';
  }
  return null;
}

String? googleLinkValidator(String? value) {
  // Optional field - allow empty
  if (value == null || value.isEmpty) {
    return null;
  }
  
  // Clean the value
  value = value.trim();
  
  // Check if it's a Google Maps link
  if (!value.contains('google.com/maps') && !value.contains('goo.gl/maps')) {
    return 'Please enter a valid Google Maps link';
  }
  
  // Basic URL validation
  final urlPattern = RegExp(
    r'^https?:\/\/',
    caseSensitive: false,
  );
  
  if (!urlPattern.hasMatch(value)) {
    return 'Link must start with http:// or https://';
  }
  
  return null;
}
  Future<void> updateEvent(String eventId) async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result = await contributeRepo.updateEventInfo(
          eventId,
          eventTitleController.text,
          eventSubTitleController.text,
          eventAboutController.text);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (success) {
        setScreenState(isLoading: false, eventId: eventId, data: allData);
      });
    } catch (e) {
      setScreenState(
          isLoading: false,
          message: "Unexpected error: $e",
          data: allData,
          hasError: true);
    }
  }

  Future<void> updateEventPhoto(
      String templeId, List<File> image, String imageType) async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result =
          await contributeRepo.updateEventPhoto(templeId, image, imageType);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (r) {
        final data = ContributionEventModel.fromJson(r.response?.data);
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

  Future<void> updateEventAllPhoto(
      String eventId, List<File> banner, List<File> gallery) async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result =
          await contributeRepo.updateEventAllPhoto(eventId, banner, gallery);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (r) {
        final data = ContributionEventModel.fromJson(r.response?.data);
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

  Future<void> createEvent() async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result = await contributeRepo.submitEvent(eventTitleController.text,
          eventSubTitleController.text, eventAboutController.text);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (success) {
        eventId = success.response?.data['id'].toString();
        isPosted = true;
        setScreenState(isLoading: false, eventId: eventId, data: allData);
      });
    } catch (e) {
      setScreenState(
          isLoading: false,
          message: "Unexpected error: $e",
          data: allData,
          hasError: true);
    }
  }

  Future<void> deleteItem(String type, String id) async {
    try {
      setScreenState(backgroundLoading: true, isLoading: false, data: allData);

      final result = await contributeRepo.deleteItem(type, id);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            backgroundLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (customResponse) {
        setScreenState(
            isLoading: false, backgroundLoading: false, data: allData);
      });
    } catch (e) {
      setScreenState(
          isLoading: false,
          backgroundLoading: false,
          message: "Unexpected error: $e",
          data: allData,
          hasError: true);
    }
  }

  Future<void> submitEventReview(
    String type,
    String id,
    String approved, {
    Map<String, dynamic>? rejectReasons,
  }) async {
    try {
      setScreenState(backgroundLoading: true, isLoading: false, data: allData);

      final result = await contributeRepo.submitReview(
        type,
        id,
        approved,
        rejectReasons: rejectReasons,
      );

      result.fold(
        (failure) {
          setScreenState(
              isLoading: false,
              backgroundLoading: false,
              message: failure.toString(),
              data: allData,
              hasError: true);
        },
        (customResponse) {
          setScreenState(
              isLoading: false,
              backgroundLoading: false,
              eventId: eventId,
              data: allData);
        },
      );
    } catch (e) {
      setScreenState(
          isLoading: false,
          backgroundLoading: false,
          message: "Unexpected error: $e",
          data: allData,
          hasError: true);
    }
  }

  Future<void> updateEventAddress(
      String eventId, String devalay, String value) async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result = await contributeRepo.updateEventAddress(
          eventId,
          value,
          devalay,
          streetAddressController.text,
          cityController.text,
          stateController.text,
          countryController.text,
          pincodeController.text,
          nearestAirportController.text,
          nearestRailwayController.text,
          googleLinkController.text);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (success) {
        final data = ContributionEventModel.fromJson(success.response?.data);
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

  Future<void> updateEventGod(String id, List<String> godIds) async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result = await contributeRepo.updateEventGod(id, godIds);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (success) {
        final data = ContributionEventModel.fromJson(success.response?.data);
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

  Future<void> updateEventAdditionalDetail(String eventId) async {
    try {
      setScreenState(isLoading: true, data: allData);

      final result = await contributeRepo.updateEventAdditionalDetail(eventId,
          celebrateController.text, dosController.text, dontsController.text);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (success) {
        final data = ContributionEventModel.fromJson(success.response?.data);
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

  Future<void> updateAcceptBanner(
      String type, String templeId, String id, String approved) async {
    try {
      setScreenState(backgroundLoading: true, isLoading: false, data: allData);

      final result =
          await contributeRepo.updateAcceptBanner(type, id, approved);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            backgroundLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (customResponse) {
        final data = AcceptBannerModel.fromJson(customResponse.response?.data);
        setScreenState(
            isLoading: false,
            backgroundLoading: false,
            acceptBannerModel: data,
            data: allData);
        fetchSingleContributeEventData(templeId, value: 'true');
      });
    } catch (e) {
      setScreenState(
          isLoading: false,
          backgroundLoading: false,
          message: "Unexpected error: $e",
          data: allData,
          hasError: true);
    }
  }

  Future<void> updateEventDate(
      String id, Map<String, String> dateTimeMap) async {
    try {
      setScreenState(isLoading: true, data: allData);
      final result = await contributeRepo.updateEventDate(id, dateTimeMap);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (success) {
        final data = ContributionEventModel.fromJson(success.response?.data);
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

  Future<void> deleteEventImage(String type, String eventId, String id) async {
    setScreenState(backgroundLoading: true, isLoading: false, data: allData);

    final result = await contributeRepo.deleteImage(type, eventId);

    result.fold((failure) {
      if (failure.toString().contains("403") ||
          failure.toString().contains("Permission denied")) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this image",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        emit(ContributeEventError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
      }
      setScreenState(
          isLoading: false,
          backgroundLoading: false,
          message: failure.toString(),
          data: allData,
          hasError: true);
    }, (success) {
      if (success.response?.data is Map<String, dynamic> &&
          (success.response?.data['detail'] == "Permission denied" ||
              success.response?.statusCode == 403)) {
        Fluttertoast.showToast(
          msg: "You don't have permission to delete this image",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        setScreenState(
            isLoading: false,
            backgroundLoading: false,
            message: "Permission denied",
            data: allData,
            hasError: true);
        emit(ContributeEventError(
          message: "Permission denied",
          isPermissionDenied: true,
        ));
        return;
      }
      final jsonMap = success.response?.data;
      final data = ContributionEventModel.fromJson(jsonMap);
      setScreenState(
          isLoading: false,
          backgroundLoading: false,
          singleData: data,
          data: allData);
      Fluttertoast.showToast(
        msg: "Image deleted successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      fetchSingleContributeEventData(id, value: 'true');
    });
  }

  Future<void> applyFilter({
    String? sortBy,
    String? orderBy,
    String? value,
    int? newSectionIndex,
  }) async {
    try {
      if (sortBy != null) selectedSortByIndex = sortBy;
      if (orderBy != null) selectedOrderByIndex = orderBy;
      if (newSectionIndex != null) sectionIndex = newSectionIndex;

      debugPrint('Applying filter with sectionIndex: $sectionIndex');
      final filterQuery = buildFilterQuery();

      switch (sectionIndex) {
        case 0: // Draft
          await fetchContributeEventData(
            
            filterQuery: filterQuery,
            value: value,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
          break;
        case 1: // Under Review
          await fetchContributeEventData(
           
            filterQuery: filterQuery,
            value: value,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "false",
            loadMoreData: false,
          );
          break;
        case 2: // Approved
          await fetchContributeEventData(
           
            filterQuery: filterQuery,
            value: value,
            approvedVal: "true",
            rejectVal: "false",
            draftVal: "false",
            loadMoreData: false,
          );
          break;
        case 3: // Review
          await fetchContributeEventData(
         
            filterQuery: filterQuery,
            value: "false",
            loadMoreData: false,
          );
            case 4: // Review
          await fetchContributeEventData(
         
            filterQuery: filterQuery,
            value: "true",
            
            loadMoreData: false,
          );
          break;
        default:
          await fetchContributeEventData(
         
            filterQuery: filterQuery,
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
      }

      debugPrint('Filter applied successfully. Section: $sectionIndex, Data count: ${allData.length}');
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

  Future<void> fetchContributeEventData(
      {String? value,
     
      String filterQuery = '',
      String? approvedVal,
      String? rejectVal,
      String? draftVal,
      bool loadMoreData = false}) async
  {
    
    if (!hasMoreData && loadMoreData) return;

    if (loadMoreData) {
      setScreenState(backgroundLoading: true, isLoading: false, data: allData);
      page++;
    } else {
      setScreenState(isLoading: true, data: []);
      page = 1;
      allData.clear();
    }

    final result = await contributeRepo.fetchContributeTempleData(
        type: 'Event',
        value: value,
        approvedVal: approvedVal,
        rejectVal: rejectVal,
        draftVal: draftVal,
         filterQuery: filterQuery.isEmpty ? currentFilterQuery : filterQuery,
        page: page);

    result.fold(
      (failure) {
        setScreenState(
            isLoading: false,
            backgroundLoading: false,
            message: failure.toString(),
            data: loadMoreData ? allData : [],
            hasError: true);
      },
      (r) {
        try {
          final data = (r.response?.data as List)
              .map((x) => ContributionEventModel.fromJson(x))
              .toList();

          if (loadMoreData) {
            allData.addAll(data);
          } else {
            allData = data;
          }

          hasMoreData = data.length >= 10;

          setScreenState(
            isLoading: false,
            backgroundLoading: false,
            data: allData,
          );
        } catch (e) {
          setScreenState(
              isLoading: false,
              backgroundLoading: false,
              message: "Error processing data: $e",
              data: allData,
              hasError: true);
        }
      },
    );
  }

  Future<void> fetchSingleContributeEventData(String id,
      {String? value}) async {
    try {
      final result = await contributeRepo
          .fetchSingleContributeTempleData(id, 'Event', value: value);

      result.fold((failure) {
        setScreenState(
            isLoading: false,
            message: failure.toString(),
            data: allData,
            hasError: true);
      }, (customResponse) {
        final data =
            ContributionEventModel.fromJson(customResponse.response?.data);
        eventTitleController.text = data.title ?? '';
        eventSubTitleController.text = data.subtitle ?? '';
        eventAboutController.text = data.description ?? '';
        streetAddressController.text = data.address ?? '';
        cityController.text = data.city ?? '';
        stateController.text = data.state ?? '';
        countryController.text = data.country ?? '';
        pincodeController.text = data.landmark ?? '';
        nearestAirportController.text = data.nearestAirport ?? '';
        nearestRailwayController.text = data.nearestRailway ?? '';
        googleLinkController.text = data.googleMapLink ?? '';
        dosController.text = data.dos ?? '';
        dontsController.text = data.donts ?? '';

        loadExistingDates(data);
        _loadExistingGods(data);

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

  _loadExistingGods(ContributionEventModel model) {
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
    selectedSortByIndex = '';
    selectedOrderByIndex = '';
    currentFilterQuery = '';
    page = 1;
    allData.clear();
    hasMoreData = true;
  }

  void setScreenState(
      {List<ContributionEventModel>? data,
      ContributionEventModel? singleData,
      CommonModel? commonModel,
      AcceptBannerModel? acceptBannerModel,
      required bool isLoading,
      bool backgroundLoading = false,
      String? message,
      String? eventId,
      bool hasError = false}) {
    if (isClosed) {
      debugPrint(
          'Skipping state emission because ContributeEventCubit is closed.');
      return;
    }

    emit(ContributeEventLoaded(
        loadingState: isLoading,
        backgroundLoading: backgroundLoading,
        errorMessage: message ?? '',
        eventList: data ?? allData,
        eventId: eventId,
        singleEvent: singleData,
        acceptBannerModel: acceptBannerModel,
        commonModel: commonModel,
        hasError: hasError,
        currentPage: page));

    debugPrint(
        'State emitted: loading=$isLoading, backgroundLoading=$backgroundLoading, hasError=$hasError, dataCount=${data?.length ?? allData.length}');
  }
}
