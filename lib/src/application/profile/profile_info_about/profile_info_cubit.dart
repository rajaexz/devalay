import 'dart:io';

import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/profile/profile_info_model.dart';
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/repo_impl/profile_repo.dart';
import '../../../domain/repo_impl/authentication_repo.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  final ProfileRepo profileRepo = getIt<ProfileRepo>();
  final FeedHomeRepo feedHomeRepo = getIt<FeedHomeRepo>();
  final KirtiRepo kirtiRepo = getIt<KirtiRepo>();
  final AuthenticationRepo authenticationRepo = getIt<AuthenticationRepo>();
  ProfileInfoCubit() : super(ProfileInfoInitial());

  List<String> countryList = ['India', 'Nepal'];
  String? selectedCountry;

  String? userId;
  final createProfileFormKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final bioController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final countyController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  String? dropdownValue;

  // Bank account controllers
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final upiIdController = TextEditingController();

  // Track original bank account data to detect changes
  Map<String, String>? _originalBankData;

  ProfileInfoModel? profileInfoModel;

  String? userNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'User Name is required';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'User Name is required';
    }
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }
    // Check if name contains only letters and spaces (proper name format)
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmedValue)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Use email_validator plugin for proper email validation
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (value.trim().length > 15) {
      return 'Phone number must not exceed 15 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  String? dobValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of Birth is required';
    }
    try {
      final dob = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.year -
          dob.year -
          ((today.month < dob.month ||
                  (today.month == dob.month && today.day < dob.day))
              ? 1
              : 0);
      if (age < 18) {
        return 'You must be at least 18 years old';
      }
      if (age > 120) {
        return 'Please enter a valid date of birth';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }
    return null;
  }

  void init(String id) {
    userId = id;
    fetchProfileInfoData();
  }

  Future<void> fetchProfileInfoData() async {
    if (userId == null || userId!.isEmpty || userId == "null") {
      debugPrint("ProfileInfoCubit: Invalid userId - $userId");
      setScreenState(isLoading: false, message: "Invalid user ID");
      return;
    }

    // Set loading state before API call
    setScreenState(isLoading: true, profileInfoModel: profileInfoModel);

    final result = await profileRepo.fetchProfileInfoData(userId!);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
      
      // Check if the error is 404 (user not found) and automatically sign out user
      if (failure == Failure.notFound || failure.errorMessage == Failure.notFound.errorMessage) {
        // Use navigatorKey to get context for sign out
        final navigatorContext = AppRouter.navigatorKey.currentContext;
        if (navigatorContext != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Automatically sign out user when user data is not found (404)
            authenticationRepo.userSignOut(navigatorContext);
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Profile fetch unsuccessful");
      }
    }, (success) {
      final responseData = success.response?.data;
      
      // Check if response data is null
      if (responseData == null) {
        setScreenState(isLoading: false, message: "No profile data found");
        return;
      }
      
      Map<String, dynamic>? userData;
      
      // Handle both List and Map responses from API
      if (responseData is List) {
        if (responseData.isEmpty) {
          setScreenState(isLoading: false, message: "No profile data found");
          return;
        }
        
        final rawUserData = responseData[0];
        if (rawUserData == null || rawUserData is! Map) {
          setScreenState(isLoading: false, message: "Invalid profile data");
          return;
        }
        userData = Map<String, dynamic>.from(rawUserData);
      } else if (responseData is Map) {
        // API returned a single object instead of a list
        userData = Map<String, dynamic>.from(responseData);
      } else {
        setScreenState(isLoading: false, message: "Invalid profile data format");
        return;
      }

      // Cast to proper type for fromJson
      final data = ProfileInfoModel.fromJson(userData);
      profileInfoModel = data;

      // Populate controllers with fetched data (with null safety)
      firstNameController.text = (userData['name']?.toString() ?? '').trim();
      bioController.text = userData['biography']?.toString() ?? '';
      locationController.text = userData['city']?.toString() ?? '';
      countyController.text = userData['country']?.toString() ?? '';
      dobController.text = userData['dob']?.toString() ?? '';
      emailController.text = userData['email']?.toString() ?? '';
  
      PrefManager.setIsPandit(userData['is_pandit'] ?? false);
      
      String phone = userData['phone']?.toString() ?? '';
      if (phone.startsWith('+91')) {
        phoneController.text = phone.substring(3);
      } else {
        phoneController.text = phone;
      }

      // Handle gender dropdown
      String gender = userData['gender']?.toString() ?? '';
      if (['Male', 'Female', 'Other'].contains(gender)) {
        dropdownValue = gender;
      } else {
        dropdownValue = null;
      }

      // Set selected country for dropdown
      String country = userData['country']?.toString() ?? '';
      if (countryList.contains(country)) {
        selectedCountry = country;
      } else {
        selectedCountry = null;
      }

      String admin = userData['admin']?.toString() ?? '';
      PrefManager.setAdmin(admin);

      setScreenState(isLoading: false, profileInfoModel: data);
    });
  }

 Future<bool> deleteAccount(BuildContext? context) async {
  final userId = await PrefManager.getUserDevalayId();
    if (userId == null) {
      Fluttertoast.showToast(
        msg: "User ID not found",
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    try {
      // Set loading state
      setScreenState(isLoading: true, profileInfoModel: profileInfoModel);
      
      Logger.log("Attempting to delete account for user: $userId");

      // Call the repository method to delete account
      final result = await profileRepo.deleteAccount(userId);

      bool isSuccess = false;
      result.fold(
        (failure) {
          setScreenState(isLoading: false, message: failure.toString());
          Fluttertoast.showToast(
            msg: "Failed to delete account: ${failure.toString()}",
            toastLength: Toast.LENGTH_LONG,
          );
          Logger.logError("Account deletion failed: ${failure.toString()}");
          isSuccess = false;
        },
        (success) async {
          Logger.log("Account deleted successfully");
          setScreenState(isLoading: false, profileInfoModel: null);

          Fluttertoast.showToast(
            msg: "Account deleted successfully",
            toastLength: Toast.LENGTH_SHORT,
          );

          // Full sign-out (Firebase, Google, clear prefs) and navigate to intro
          if (context != null && context.mounted) {
            await authenticationRepo.userSignOut(context);
          }
          isSuccess = true;
        },
      );
      
      return isSuccess;
    } catch (e) {
      setScreenState(isLoading: false, message: e.toString());
      Fluttertoast.showToast(
        msg: "Error deleting account: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      Logger.logError("Exception in deleteAccount: $e");
      return false;
    }
  }


  void clearUserData() {
    PrefManager.clearPreferences();
  }

  Future<void> feedPostFollowingRequest({
    required int followingUserId,
    required int userId,
    required bool isFollowing,
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
        );
      },
      (customResponse) async {
        // Handle success case
        Logger.log("Follow request successful");
      },
    );
  }

  Future<void> hideRequest({
    required int userId,
    required int myId,
  }) async {
    final result = await feedHomeRepo.feedPostHideSuggestion(myId, userId);

    result.fold(
      (failure) {
        Logger.log("Hide failed: ${failure.toString()}");
        setScreenState(
          isLoading: false,
          message: failure.toString(),
        );
      },
      (customResponse) async {
        Logger.log("Hide request successful");
      },
    );
  }

  // Improved method to update all profile data
  Future<bool> updateAllProfileData(
      String selectedCountryCode, BuildContext? context,) async {
    if (userId == null) return false;

    try {
      // Set loading state
      setScreenState(isLoading: true, profileInfoModel: profileInfoModel);

      // Validate required fields
      if (firstNameController.text.trim().isEmpty ||
          dropdownValue == null ||
          phoneController.text.trim().isEmpty) {
        setScreenState(
            isLoading: false, message: "Please fill all required fields");
        return false;
      }

      final phoneWithCode = '$selectedCountryCode${phoneController.text.trim()}';

      // Prepare data with proper field names that match the API
      final result = await profileRepo.fetchDetailData(
        location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : "",
        country: countyController.text.trim().isNotEmpty ? countyController.text.trim() : "",
        dropdownValue: dropdownValue!,
        phone: phoneWithCode,
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : "",
        dob: dobController.text.trim().isNotEmpty ? dobController.text.trim() : "",
        firstName: firstNameController.text.trim(),
        bio: bioController.text.trim().isNotEmpty ? bioController.text.trim() : null,
      );

      bool isSuccess = false;
      result.fold(
        (failure) {
          setScreenState(isLoading: false, message: failure.toString());
          Fluttertoast.showToast(
            msg: "Update failed: ${failure.toString()}",
            toastLength: Toast.LENGTH_LONG,
          );
          isSuccess = false;
        },
        (success) {
          final data = ProfileInfoModel.fromJson(success.response?.data);
          profileInfoModel = data;

          // set User Name 
          PrefManager.setUserFristName(firstNameController.text.trim());
          setScreenState(isLoading: false, profileInfoModel: data);
          Fluttertoast.showToast(
            msg: "Details updated successfully",
            toastLength: Toast.LENGTH_SHORT,
          );
          isSuccess = true;
        },
      );
      return isSuccess;
    } catch (e) {
      setScreenState(isLoading: false, message: e.toString());
      Fluttertoast.showToast(
        msg: "Failed to update profile: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }
  }

 Future<bool> updateAllLoginTimeData(
      String selectedCountryCode, BuildContext? context,bool isServiceProvider) async
  {
    if (userId == null) return false;

    try {
      // Set loading state
      setScreenState(isLoading: true, profileInfoModel: profileInfoModel);

      // Validate required fields for login time data firstNameController
      if (firstNameController.text.trim().isEmpty) {
        setScreenState(isLoading: false, message: "Full Name is required");
        Fluttertoast.showToast(
          msg: "Full Name is required",
          toastLength: Toast.LENGTH_SHORT,
        );
        return false;
      }

      // Email is optional, but if provided, validate format
      if (emailController.text.trim().isNotEmpty) {
        if (!EmailValidator.validate(emailController.text.trim())) {
          setScreenState(isLoading: false, message: "Invalid email format");
          Fluttertoast.showToast(
            msg: "Please enter a valid email address",
            toastLength: Toast.LENGTH_SHORT,
          );
          return false;
        }
      }

      if (phoneController.text.trim().isEmpty) {
        setScreenState(isLoading: false, message: "Phone number is required");
        Fluttertoast.showToast(
          msg: "Phone number is required",
          toastLength: Toast.LENGTH_SHORT,
        );
        return false;
      }

      if (dobController.text.trim().isEmpty) {
        setScreenState(isLoading: false, message: "Date of Birth is required");
        Fluttertoast.showToast(
          msg: "Date of Birth is required",
          toastLength: Toast.LENGTH_SHORT,
        );
        return false;
      }

      if (dropdownValue == null) {
        setScreenState(isLoading: false, message: "Gender is required");
        Fluttertoast.showToast(
          msg: "Gender is required",
          toastLength: Toast.LENGTH_SHORT,
        );
        return false;
      }

      // Prepare phone with country code - ensure selectedCountryCode is not null
      final String countryCode = selectedCountryCode.isNotEmpty ? selectedCountryCode : '+91';
      final phoneWithCode = '$countryCode${phoneController.text.trim()}';

      // Ensure selectedCountry has a fallback value
      final String fallbackCountry = selectedCountry ?? 'India';
      
      Logger.log("Updating login time data with validated inputs");

    
      final result = await profileRepo.fetchDetailData(
        location: locationController.text.trim(),
        country: countyController.text.trim().isNotEmpty 
            ? countyController.text.trim() 
            : fallbackCountry,
        dropdownValue: dropdownValue!,
        phone: phoneWithCode,
        email: emailController.text.trim().isNotEmpty 
            ? emailController.text.trim() 
            : "", // Pass null instead of empty string
        dob: dobController.text.trim().isNotEmpty 
            ? dobController.text.trim() 
            : "", // Pass null instead of empty string
        firstName: firstNameController.text.trim(),
        bio: bioController.text.trim().isNotEmpty 
            ? bioController.text.trim() 
            : null, 
            isServiceProvider:isServiceProvider
         
      );

      bool isSuccess = false;
      result.fold(
        (failure) {
          setScreenState(isLoading: false, message: failure.toString());
          Fluttertoast.showToast(
            msg: "Update failed: ${failure.toString()}",
            toastLength: Toast.LENGTH_LONG,
          );
          Logger.logError("Login time data update failed: ${failure.toString()}");
          isSuccess = false;
        },
        (success) {
          final data = ProfileInfoModel.fromJson(success.response?.data);
     
          profileInfoModel = data;
         PrefManager.setIsPandit(success.response?.data["is_pandit"]);
        
          PrefManager.setUserFristName(firstNameController.text.trim());
          
          setScreenState(isLoading: false, profileInfoModel: data);
          Fluttertoast.showToast(
            msg: "Details updated successfully",
            toastLength: Toast.LENGTH_SHORT,
          );
          
          Logger.log("Login time data updated successfully");
          
          // Navigate to landing page on success
          if (context != null && context.mounted) {
            AppRouter.go("/landing");
          }
          isSuccess = true;
        },
      );
      
      return isSuccess;
    } catch (e) {
      setScreenState(isLoading: false, message: e.toString());
      Fluttertoast.showToast(
        msg: "Failed to update profile: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      Logger.logError("Exception in updateAllLoginTimeData: $e");
      return false;
    }
  }
  Future<void> updateProfileImage(File dp) async {
    if (userId == null) return;

    setScreenState(isLoading: true, profileInfoModel: profileInfoModel);

    final result = await profileRepo.updateProfileImage(dp);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      final data = ProfileInfoModel.fromJson(success.response?.data);
      profileInfoModel = data;
      setScreenState(isLoading: false, profileInfoModel: data);
      if (AppRouter.canPop()) {
        AppRouter.pop();
      }
    });
  }

  Future<void> updateBackgroundImage(File dp) async {
    if (userId == null) return;

    setScreenState(isLoading: true, profileInfoModel: profileInfoModel);

    final result = await profileRepo.updateBackgroundImage(dp);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (success) {
      final data = ProfileInfoModel.fromJson(success.response?.data);
      profileInfoModel = data;
      setScreenState(isLoading: false, profileInfoModel: data);
      AppRouter.pop();
    });
  }

  void setScreenState({
    ProfileInfoModel? profileInfoModel,
    required bool isLoading,
    String? message,
  }) {
    emit(ProfileInfoLoaded(
      loadingState: isLoading,
      errorMessage: message ?? '',
      profileInfoModel: profileInfoModel,
    ));
  }

  /// Fetch bank account details
  Future<void> fetchBankAccountData() async {
    try {
      final result = await kirtiRepo.fetchBankAccounts();

      result.fold((failure) {
        debugPrint('Failed to fetch bank accounts: ${failure.toString()}');
        // Don't show error if no data exists (first time setup)
      }, (success) {
        final responseData = success.response?.data;
        if (responseData != null) {
          // Handle both List and Map responses
          Map<String, dynamic>? bankData;
          if (responseData is List && responseData.isNotEmpty) {
            bankData = Map<String, dynamic>.from(responseData[0]);
          } else if (responseData is Map) {
            bankData = Map<String, dynamic>.from(responseData);
          }

          if (bankData != null) {
            // Populate controllers
            accountNameController.text = bankData['account_name']?.toString() ?? '';
            accountNumberController.text = bankData['account_number']?.toString() ?? '';
            ifscCodeController.text = bankData['ifsc_code']?.toString() ?? '';
            bankNameController.text = bankData['bank_name']?.toString() ?? '';
            upiIdController.text = bankData['upi_id']?.toString() ?? '';

            // Store original data for change detection
            _originalBankData = {
              'account_name': accountNameController.text,
              'account_number': accountNumberController.text,
              'ifsc_code': ifscCodeController.text,
              'bank_name': bankNameController.text,
              'upi_id': upiIdController.text,
            };
          }
        }
      });
    } catch (e) {
      Logger.logError(e);
      debugPrint('Error fetching bank accounts: $e');
    }
  }

  /// Check if bank account data has changed
  bool hasBankDataChanged() {
    if (_originalBankData == null) {
      // If no original data, check if any field has value
      return accountNameController.text.trim().isNotEmpty ||
          accountNumberController.text.trim().isNotEmpty ||
          ifscCodeController.text.trim().isNotEmpty ||
          bankNameController.text.trim().isNotEmpty ||
          upiIdController.text.trim().isNotEmpty;
    }

    return accountNameController.text.trim() != (_originalBankData!['account_name'] ?? '') ||
        accountNumberController.text.trim() != (_originalBankData!['account_number'] ?? '') ||
        ifscCodeController.text.trim() != (_originalBankData!['ifsc_code'] ?? '') ||
        bankNameController.text.trim() != (_originalBankData!['bank_name'] ?? '') ||
        upiIdController.text.trim() != (_originalBankData!['upi_id'] ?? '');
  }

  /// Save bank account details
  Future<bool> saveBankAccountData() async {
    try {
      // Validate required fields
      if (accountNameController.text.trim().isEmpty ||
          accountNumberController.text.trim().isEmpty ||
          ifscCodeController.text.trim().isEmpty ||
          bankNameController.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Please fill all required fields');
        return false;
      }

      final result = await kirtiRepo.saveBankAccounts(
        accountName: accountNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        bankName: bankNameController.text.trim(),
        upiId: upiIdController.text.trim().isNotEmpty ? upiIdController.text.trim() : null,
      );

      bool isSuccess = false;
      result.fold((failure) {
        Fluttertoast.showToast(msg: 'Failed to save bank account details');
        Logger.logError(failure);
      }, (success) {
        isSuccess = true;
        // Update original data after successful save
        _originalBankData = {
          'account_name': accountNameController.text.trim(),
          'account_number': accountNumberController.text.trim(),
          'ifsc_code': ifscCodeController.text.trim(),
          'bank_name': bankNameController.text.trim(),
          'upi_id': upiIdController.text.trim(),
        };
        Fluttertoast.showToast(msg: 'Bank account details saved successfully');
      });

      return isSuccess;
    } catch (e) {
      Logger.logError(e);
      Fluttertoast.showToast(msg: 'Error saving bank account details');
      return false;
    }
  }

  @override
  Future<void> close() {
    // Clean up controllers
    firstNameController.dispose();
    bioController.dispose();
    dobController.dispose();
    locationController.dispose();
    countyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    // Dispose bank account controllers
    accountNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    upiIdController.dispose();
    return super.close();
  }
}