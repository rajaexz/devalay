import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/authentication/login/login_state.dart';
import 'package:devalay_app/src/domain/repo_impl/authentication_repo.dart';
import 'package:devalay_app/src/presentation/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

/// Cubit for handling phone-based authentication (Login & Signup)
class LoginCubit extends Cubit<LoginState> {
  LoginCubit()
      : _authenticationRepo = getIt<AuthenticationRepo>(),
        super(const LoginInitial());

  final AuthenticationRepo _authenticationRepo;

  // Form keys
  final formKey = GlobalKey<FormState>();
  final createProfileFormKey = GlobalKey<FormState>();

  // Controllers - Phone Auth Only
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  
  // Profile creation controllers (used after OTP verification)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  String otpCode = '';

  /// Check if currently in loading state
  bool get isLoading => state is LoginLoading;

  // ============ Validators ============

  String? phoneValidator(String? value) => Validators.phone(value);

  // ============ Phone Authentication Methods ============

  /// Send OTP to phone number
  Future<void> loginWithPhone(String countryCode, {bool reSend = false}) async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      emit(const LoginError('Please enter a phone number'));
      return;
    }

    final phoneNumber = countryCode + phone;

    emit(LoginLoading(message: reSend ? 'Resending OTP...' : 'Sending OTP...'));
    
    try {
      await _authenticationRepo.loginWithPhone(phoneNumber, reSend: reSend);
      emit(LoginOtpSent(phoneNumber: phoneNumber));
    } catch (e) {
      emit(LoginError('Failed to send OTP: ${e.toString()}'));
    }
  }
  
  /// Verify OTP code
  Future<bool> verifyOTP(String phoneNumber) async {
    if (otpCode.length != 6) {
      emit(const LoginError('Please enter a valid 6-digit OTP'));
      return false;
    }

    emit(const LoginLoading(message: 'Verifying OTP...'));

    try {
      await _authenticationRepo.loginWithOtp(otp: otpCode, number: phoneNumber);
      otpController.clear();
      otpCode = '';
      emit(const LoginSuccess());
      return true;
    } catch (e) {
      emit(LoginError(_mapOtpError(e)));
      return false;
    }
  }

  String _mapOtpError(Object e) {
  
    return 'OTP verification failed. Please try again.';
  }

  /// Login as guest user
  Future<void> loginAsGuest() async {
    emit(const LoginLoading(message: 'Continuing as guest...'));

    try {
      await _authenticationRepo.loginWithOtp(otp: "000000", number: "+911234567890");
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginError('Guest login failed: ${e.toString()}'));
    }
  }

  // ============ State Management ============

  /// Reset to initial state
  void resetState() {
    emit(const LoginInitial());
  }

  /// Clear all form fields
  void clearFields() {
    phoneController.clear();
    otpController.clear();
    otpCode = '';
  }

  // ============ Lifecycle ============

  @override
  Future<void> close() {
    // Dispose all controllers to prevent memory leaks
    phoneController.dispose();
    otpController.dispose();
    nameController.dispose();
    dateBirthController.dispose();
    genderController.dispose();
    return super.close();
  }
}
