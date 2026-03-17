import 'package:devalay_app/src/application/authentication/setting/setting_state.dart';
import 'package:devalay_app/src/domain/repo_impl/authentication_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection.dart';
import '../../../data/model/setting/help_support_model.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit()
      : _authenticationRepo = getIt<AuthenticationRepo>(),
        super(SettingInitial());

  final AuthenticationRepo _authenticationRepo;

  // Controllers
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final upiIdController = TextEditingController();
  final settingFormKey = GlobalKey<FormState>();

  // ============ Account Privacy ============

  Future<void> accountPrivacy(String id, String status) async {
    try {
      final result = await _authenticationRepo.accountPrivacy(id, status);
      result.fold(
        (failure) {
          debugPrint("Server sync failed: ${failure.toString()}");
        },
        (success) {
          debugPrint("Server sync successful");
        },
      );
    } catch (e) {
      debugPrint("Server sync error: ${e.toString()}");
    }
  }

  // ============ Help & Support ============

  void fetchGodForm(String name) async {
    setScreenState(isLoading: true);

    final result = await _authenticationRepo.fetchHelpSupportData(name);

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => HelpSupportModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, data: data);
    });
  }

  // ============ Payment Methods ============

  /// Fetch existing payment details
  Future<void> updatePaymentPatch() async {
    final result = await _authenticationRepo.updatePaymentPatch();
    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final dynamic raw = customResponse.response?.data;
      Map<String, dynamic> data = {};

      if (raw is List) {
        if (raw.isEmpty) {
          setScreenState(isLoading: false, message: 'No payment data found');
          return;
        }
        final first = raw.first;
        if (first is Map<String, dynamic>) {
          data = first;
        } else {
          setScreenState(isLoading: false, message: 'Unexpected payment data format');
          return;
        }
      } else if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      } else {
        setScreenState(isLoading: false, message: 'Invalid payment data');
        return;
      }

      // Populate controllers with fetched data
      accountNameController.value = TextEditingValue(text: data['account_name'] ?? '');
      accountNumberController.value = TextEditingValue(text: data['account_number'] ?? '');
      ifscCodeController.value = TextEditingValue(text: data['ifsc_code'] ?? '');
      bankNameController.value = TextEditingValue(text: data['bank_name'] ?? '');
      upiIdController.value = TextEditingValue(text: data['upi_id'] ?? '');
    });
  }

  /// Update payment details
  Future<void> updatePayment() async {
    setScreenState(isLoading: true);

    final result = await _authenticationRepo.updatePayment(
      accountName: accountNameController.text,
      accountNumber: accountNumberController.text,
      ifscCode: ifscCodeController.text,
      bankName: bankNameController.text,
      upiId: upiIdController.text,
    );

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      setScreenState(isLoading: false, message: 'Payment updated successfully');
      debugPrint("Payment update successful: ${customResponse.response?.data}");
    });
  }

  // ============ State Management ============

  void setScreenState({
    List<HelpSupportModel>? data,
    required bool isLoading,
    String? message,
    bool hasError = false,
  }) {
    emit(SettingLoaded(
      helpSupportModel: data,
      loadingState: isLoading,
      errorMessage: message ?? '',
    ));
  }

  /// Clear all form fields
  void clearFields() {
    accountNameController.clear();
    accountNumberController.clear();
    ifscCodeController.clear();
    bankNameController.clear();
    upiIdController.clear();
  }

  // ============ Lifecycle ============

  @override
  Future<void> close() {
    // Dispose all controllers to prevent memory leaks
    accountNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    upiIdController.dispose();
    return super.close();
  }
}
