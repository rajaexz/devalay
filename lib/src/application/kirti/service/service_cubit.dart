import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/kirti/service/service_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart' show PrefManager;
import 'package:devalay_app/src/data/model/explore/filter/admin_filter_model.dart';
import 'package:devalay_app/src/data/model/kirti/adds_on_model.dart';
import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart' show AdminOrderDetailModel;
import 'package:devalay_app/src/data/model/kirti/service_model.dart';
import 'package:devalay_app/src/data/model/kirti/skill_response_model.dart'
    show SkillResponseModel, skillResponseModelFromJson;
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/landing_screen.dart/landing_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/model/contribution/donateModel.dart';
import '../../../data/model/contribution/donatePaymentModel.dart';
import '../../../data/model/kirti/category_model.dart';
import '../../../data/model/kirti/experience_model.dart';
import '../../../data/model/kirti/expertise_model.dart';
import '../../../data/model/kirti/fetch_skill_model.dart'
    show FetchSkillModel, Pandit;
import '../../../data/model/kirti/language_model.dart';
import '../../../data/model/kirti/order_response_model.dart';
import '../../../data/model/kirti/service_detail_model.dart';

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(ServiceInitialState());

  final KirtiRepo _kirtiRepo;

  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final instructionController = TextEditingController();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final serviceFormKey = GlobalKey<FormState>();

  List<ServiceModel> _allServiceList = [];

  //filter variables
  int selectedFilter = 0;
  ServiceFilterModel? serviceFilterModel;
  List<Location>? locationList;
  List<Dev>? devList;
int? expId;
  
  // Pagination for available pandits
  int panditPage = 1;
  bool hasMorePandits = true;
  List<Pandit> allPandits = [];
  int? _currentOrderId;
  List<int> _currentExpertiseIds = [];
  
  String? selectedLocationIndex;
  String? searchQuery = '';
  final List<String> filterTypes = [
    StringConstant.location,
    StringConstant.sortBy,

  ];
  final List<String> sortBy = ['Most Experienced', 'Most contributed', 'Most followed'];
  String? selectedSortByIndex ;
 
  Map<String, dynamic> selectedLocationFilterMap = {};

  final List<String> queryParams = [];
  String filterQuery = '';
  final FocusNode focusNode = FocusNode();
  final TextEditingController searchLocationController = TextEditingController();
  final TextEditingController searchDevController = TextEditingController();

  String currentFilterQuery = '';

 
  String buildFilterQuery() {
    queryParams.clear();

  
    if (selectedLocationIndex != null && selectedLocationFilterMap.isNotEmpty) {
      final city = selectedLocationFilterMap['city'];
      final state = selectedLocationFilterMap['state'];
      final country = selectedLocationFilterMap['country'];

      if (city != null && city.toString().isNotEmpty) {
        queryParams.add('city=${Uri.encodeComponent(city.toString())}');
      }
      if (state != null && state.toString().isNotEmpty) {
        queryParams.add('state=${Uri.encodeComponent(state.toString())}');
      }
      if (country != null && country.toString().isNotEmpty) {
        queryParams.add('country=${Uri.encodeComponent(country.toString())}');
      }
    }

 
    if (selectedSortByIndex != null && selectedLocationFilterMap.isNotEmpty) {
      String sortBy = selectedSortByIndex!.toLowerCase();

          if (sortBy == 'most contributed') sortBy = 'most_contributed';
            if (sortBy == 'most followed ') sortBy = 'most_followed';
               if (sortBy == 'most experienced  ') sortBy = 'most_experienced';


      queryParams.add('sort_by=$sortBy');
    }

    return queryParams.isEmpty ? '' : '?${queryParams.join('&')}';
  }

  // ✅ Apply filters and fetch data
  Future<void> applyFilters(AdminOrderDetailModel? order) async {
    if (order == null || expId == null) return;
    
    currentFilterQuery = buildFilterQuery();
    
    // Reset pagination when filters are applied
    panditPage = 1;
    allPandits.clear();
    hasMorePandits = true;

    await fetchAvailablePandits(
      orderId: order.id,
      expertiseIds: [expId!],
      query: currentFilterQuery,
      loadMore: false, // Explicitly reset pagination
    );
  }

  // ✅ Reset all filters
  void resetFilters() {
    selectedLocationIndex = null;
    selectedLocationFilterMap = {};
    selectedSortByIndex = 'Likes';
  
    searchLocationController.clear();
    searchDevController.clear();
    currentFilterQuery = '';
  }


  Future<void> fetchFilterOptions() async {
    setScreenState(isLoading: true);
    final result = await _kirtiRepo.fetchFilterOptions();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ServiceFilterModel.fromJson(r.response?.data);
      serviceFilterModel = data;
      locationList = data.location;
      devList = data.dev;
      
      setScreenState(
        isLoading: false,
        serviceFilterModel: [data], // Wrap in list for compatibility
      );
      
      debugPrint('✅ Filter options loaded: ${locationList?.length} locations');
    });
  }

  // ✅ Error clear karne ka method
  void clearError() {
    if (isClosed) return;
    setScreenState(isLoading: false, message: '');
  }

  // ✅ Retry function
  void retryUpdateSkill({
    required String? skillId,
    required String? categoryId,
    required String? expertiseId,
    required List<File> workImages,
    required String? available,
    required bool? isPandit,
    required String? about,
    required String? experience,
    required String? travelPreference,
    required BuildContext context,
  }) {
    clearError();

    updateSkillData(
      skillId: skillId,
      isPandit: isPandit,
      categoryId: categoryId,
      expertiseId: expertiseId,
      workImages: workImages,
      available: available,
      about: about,
      experience: experience,
      travelPreference: travelPreference,
      context: context,
    );
  }

  // ✅ Fetch services with filters applied
  Future<void> fetchServiceData() async {
    setScreenState(isLoading: true);
    debugPrint('🔍 Fetching services with query: $currentFilterQuery');
    
    final result = await _kirtiRepo.fetchServiceData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ((r.response?.data ?? []) as List)
          .map((x) => ServiceModel.fromJson(x))
          .toList();

      _allServiceList = data;
      debugPrint('✅ Loaded ${data.length} services');
      setScreenState(isLoading: false, data: _allServiceList);
    });
  }

  // ✅ Search within loaded services
  void searchService(String query) {
    debugPrint('🔍 Search query: $query');

    final filtered = query.isEmpty
        ? _allServiceList
        : _allServiceList
            .where((service) =>
                service.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    debugPrint('✅ Filtered result count: ${filtered.length}');
    setScreenState(isLoading: false, data: filtered);
  }

  Future<void> fetchSingleServiceData(String id) async {
    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchSingleServiceData(id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = ServiceDetailModel.fromJson(r.response?.data);
      setScreenState(isLoading: false, singleService: data);
    });
  }

  Future<bool> deleteSkillData(String skillId) async {
    setScreenState(isLoading: true, message: '');
    final result = await _kirtiRepo.deleteSkillData(skillId);
    bool isDeleted = false;

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      isDeleted = true;
      setScreenState(isLoading: false, message: '');
    });

    return isDeleted;
  }

  Future<void> fetchAddOnsData() async {
    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchAddOnsData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      final data = (r.response?.data as List)
          .map((x) => AddsOnModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, addOnsList: data);
    });
  }

  downloadInvoice(orderId, mounted, context) async {
    final result = await _kirtiRepo.downloadInvoice(orderId);
    result.fold(
      (failure) {
        throw Exception(failure.toString());
      },
      (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invoice downloaded successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () async {
                  final filePath = success.response?.data['filePath'];
                  if (filePath != null) {
                    await OpenFile.open(filePath);
                  }
                },
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>?> createRazorpayOrder({
    required String serviceId,
    required String plan,
    required List<int> addOns,
    required String address,
    required String name,
    required String scheduledDatetime,
    required String mobileNumber,
  }) async {
    setScreenState(isLoading: true);

    final result = await _kirtiRepo.createRazorpayOrder(
      serviceId: serviceId,
      plan: plan,
      addOns: addOns,
      address: address,
      name: name,
      scheduledDatetime: scheduledDatetime,
      mobileNumber: mobileNumber,
    );

    Map<String, dynamic>? responseData;

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
      if (r.response?.data is Map<String, dynamic>) {
        responseData = r.response!.data as Map<String, dynamic>;
      }
    });

    return responseData;
  }

  Future<void> createOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required bool paymentStatus,
    required int plan,
    required List<int> addOns,
    required int serviceSection,
    required String scheduledDatetime,
    required String name,
    required String address,
    required String mobileNumber,
  }) async {
    setScreenState(isLoading: true);

    final result = await _kirtiRepo.createOrder(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      paymentStatus: paymentStatus,
      plan: plan,
      addOns: addOns,
      serviceSection: serviceSection,
      scheduledDatetime: scheduledDatetime,
      name: name,
      address: address,
      mobileNumber: mobileNumber,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (r) {
      setScreenState(isLoading: false);
    });
  }

  void fetchRoleData() async {
    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchRoleData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => LanguageModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, languageList: data);
    });
  }

  void fetchSkillData(String id) async {
    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchSkillData(id);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = FetchSkillModel.fromJson(customResponse.response?.data);
  
      setScreenState(isLoading: false, fetchSkillModel: data);
    });
  }

  void fetchCategoryData(String? roleId) async {
    if (isClosed) return;

    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchCategoryData(roleId);

    if (isClosed) return;

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => CategoryModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, categoryList: data);
    });
  }

  void fetchExpertiseData(String? roleId, String? categoryId) async {
    if (isClosed) return;

    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchExpertiseData(roleId, categoryId);

    if (isClosed) return;

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => ExpertiseModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, expertiseList: data);
    });
  }

  void fetchExperienceData() async {
    if (isClosed) return;

    setScreenState(isLoading: true);

    final result = await _kirtiRepo.fetchExperienceData();

    if (isClosed) return;

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => ExperienceModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, experienceList: data);
    });
  }

  Future<void> fetchAvailablePandits({
    required int? orderId,
    required List<int> expertiseIds,
    required String query,
    bool loadMore = false,
  }) async {
    if (isClosed) return;
    
    // If loading more but no more data, return
    if (loadMore && !hasMorePandits) return;

    // Store current params for pagination
    _currentOrderId = orderId;
    _currentExpertiseIds = expertiseIds;

    if (loadMore) {
      panditPage++;
    } else {
      // Reset pagination for new search
      panditPage = 1;
      allPandits.clear();
      hasMorePandits = true;
    }

    setScreenState(isLoading: true, availablePandits: allPandits);
    
    final result = await _kirtiRepo.fetchAvailablePandits(
      orderId: orderId,
      expertiseIds: expertiseIds,
      query: query,
      page: panditPage,
    );

    if (isClosed) return;

    result.fold((failure) {
      hasMorePandits = false;
      setScreenState(
        isLoading: false,
        message: failure.toString(),
        availablePandits: allPandits,
      );
    }, (customResponse) {
      final responseData = customResponse.response?.data;
      List<Pandit> pandits = [];
      bool nextPageAvailable = false;
      
      if (responseData is List) {
        pandits = responseData
            .map((e) => Pandit.fromJson(e as Map<String, dynamic>))
            .toList();
        nextPageAvailable = pandits.length >= 10;
      } else if (responseData is Map<String, dynamic>) {
        // Check for 'next' field for pagination
        final next = responseData['next'];
        nextPageAvailable = next != null && next.toString().isNotEmpty;
        
        final panditsList = responseData['pandits'];
        if (panditsList is List) {
          pandits = panditsList
              .map((e) => Pandit.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          final results = responseData['results'];
          if (results is List) {
            pandits = results
                .map((e) => Pandit.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }

      // Add to existing list or replace
      if (loadMore) {
        allPandits.addAll(pandits);
      } else {
        allPandits = pandits;
      }
      
      hasMorePandits = nextPageAvailable;

      setScreenState(
        isLoading: false,
        availablePandits: allPandits,
      );
    });
  }

  /// Load more pandits (for pagination)
  Future<void> loadMorePandits() async {
    if (!hasMorePandits || _currentOrderId == null || _currentExpertiseIds.isEmpty) return;
    
    await fetchAvailablePandits(
      orderId: _currentOrderId,
      expertiseIds: _currentExpertiseIds,
      query: currentFilterQuery,
      loadMore: true,
    );
  }

  Future<void> requestPandits({
    required int orderId,
    required List<int> panditIds,
  }) async {
    if (isClosed) return;

    setScreenState(isLoading: true, message: '');

    final result = await _kirtiRepo.requestPandits(
      orderId: orderId,
      panditIds: panditIds,
    );

    if (isClosed) return;

    result.fold((failure) {
      setScreenState(
        isLoading: false,
        message: failure.toString(),
      );
    }, (customResponse) {
      setScreenState(
        isLoading: false,
        message: 'Pandit assigned successfully',
      );
    });
  }

void updateSkillData({
  required String? skillId,
  required bool? isPandit,
  required String? categoryId,
  required String? expertiseId,
  required List<File> workImages,
  required String? available,
  required String? about,
  required String? experience,
  required String? travelPreference,
  required BuildContext context,
}) async {
  setScreenState(isLoading: true, message: '');

  final result = await _kirtiRepo.updateSkillData(
    skillId,
    categoryId,
    expertiseId,
    available,
    about,
    experience,
    travelPreference,
    workImages,
  );

  result.fold((failure) {
    setScreenState(isLoading: false, message: failure.toString());
  }, (customResponse) async {
    if (!customResponse.isSuccessful) {
      final errorMessage = customResponse.error.isNotEmpty
          ? customResponse.error
          : 'Unknown error occurred';
      setScreenState(
        isLoading: false,
        message: errorMessage,
      );
      return;
    }

    try {
      SkillResponseModel data;

      if (customResponse.response?.data is String) {
        data = skillResponseModelFromJson(customResponse.response?.data);
        setScreenState(isLoading: false, skillResponseModel: data, message: '');
        
     
      } else if (customResponse.response?.data is Map<String, dynamic>) {
        data = SkillResponseModel.fromJson(customResponse.response?.data);
        
        // ⭐ Save pandit status FIRST
         PrefManager.setIsPandit(isPandit ?? true);
        
        // ⭐ Update state
        setScreenState(isLoading: false, skillResponseModel: data, message: '');

        // ⭐ Wait a bit for state to update
        await Future.delayed(const Duration(milliseconds: 100));

        if (!context.mounted) return;

        // ⭐ Use pushReplacement or go instead of pop + push
        // Option 1: Replace current screen with landing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LandingScreen(), // Use your actual landing screen widget
          ),
        );

        // ⭐ OR Option 2: If using GoRouter
        // context.go(RouterConstant.landingScreen);

        // ⭐ OR Option 3: Pop and then push
        // if (Navigator.canPop(context)) {
        //   Navigator.pop(context);
        // }
        // await Future.delayed(const Duration(milliseconds: 100));
        // if (context.mounted) {
        //   context.push(RouterConstant.landingScreen);
        // }
        
        return;
        
      } else {
        throw Exception(
          'Unexpected response format: ${customResponse.response?.data.runtimeType}',
        );
      }

    } catch (e) {
      setScreenState(isLoading: false, message: 'Error parsing response: $e');
    }
  });
}
 
 
 
  Future<void> updateOrderPayment(String donationId) async {
    final result = await _kirtiRepo.updateDonatePayment(donationId);
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
    print('Please open this URL manually in your browser: $url');
  }

  void setScreenState({
    List<ServiceModel>? data,
    ServiceDetailModel? singleService,
    SkillResponseModel? skillResponseModel,
    FetchSkillModel? fetchSkillModel,
    OrderResponseModel? orderResponseModel,
    DonateModel? donateModel,
    DonatePaymentModel? donatePaymentModel,
    List<AddsOnModel>? addOnsList,
    List<LanguageModel>? languageList,
    List<CategoryModel>? categoryList,
    List<ExpertiseModel>? expertiseList,
    List<ExperienceModel>? experienceList,
    List<Pandit>? availablePandits,
    List<ServiceFilterModel>? serviceFilterModel,
    required bool isLoading,
    String? message,
  }) {
    if (isClosed) return;

    final currentState = state;

    if (currentState is ServiceLoadedState) {
      emit(ServiceLoadedState(
        serviceList: data ?? currentState.serviceList,
        service: singleService ?? currentState.service,
        skillResponseModel: skillResponseModel ?? currentState.skillResponseModel,
        fetchSkillModel: fetchSkillModel ?? currentState.fetchSkillModel,
        orderResponseModel: orderResponseModel ?? currentState.orderResponseModel,
        addOnsList: addOnsList ?? currentState.addOnsList,
        isLoading: isLoading,
        errorMessage: message ?? currentState.errorMessage,
        languageList: languageList ?? currentState.languageList,
        categoryList: categoryList ?? currentState.categoryList,
        expertiseList: expertiseList ?? currentState.expertiseList,
        experienceList: experienceList ?? currentState.experienceList,
        availablePandits: availablePandits ?? currentState.availablePandits,
        donateModel: donateModel,
        donatePaymentModel: donatePaymentModel,
        loadingState: isLoading,
        serviceFilterModel: serviceFilterModel ?? currentState.serviceFilterModel,
      ));
    } else {
      emit(ServiceLoadedState(
        loadingState: isLoading,
        serviceList: data,
        service: singleService,
        skillResponseModel: skillResponseModel,
        fetchSkillModel: fetchSkillModel,
        orderResponseModel: orderResponseModel,
        donateModel: donateModel,
        donatePaymentModel: donatePaymentModel,
        addOnsList: addOnsList,
        languageList: languageList,
        categoryList: categoryList,
        expertiseList: expertiseList,
        experienceList: experienceList,
        availablePandits: availablePandits,
        isLoading: isLoading,
        errorMessage: message ?? '',
        serviceFilterModel: serviceFilterModel,
      ));
    }
  }
}