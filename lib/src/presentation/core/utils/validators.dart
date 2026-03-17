import 'package:devalay_app/src/presentation/core/constants/strings.dart';

/// Centralized form validators for consistent validation across the app.
/// 
/// Usage:
/// ```dart
/// TextFormField(
///   validator: Validators.phone,
/// )
/// ```
class Validators {
  Validators._(); // Private constructor to prevent instantiation

  // Pre-compiled regex patterns for better performance
  static final _phoneRegex = RegExp(r'^[0-9]+$');
  static final _nameRegex = RegExp(r'^[a-zA-Z\s]+$');

  /// Validates phone number
  /// 
  /// Default minimum digits is 10
  static String? phone(String? value, {bool required = true, int minDigits = 10}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return required ? StringConstant.pleaseEnterPhoneNumber : null;
    }
    if (trimmed.length < minDigits) {
      return StringConstant.phoneMinDigits(minDigits);
    }
    if (!_phoneRegex.hasMatch(trimmed)) {
      return StringConstant.phoneDigitsOnly;
    }
    return null;
  }

  /// Validates name (letters and spaces only)
  /// 
  /// Default minimum length is 2 characters
  static String? name(String? value, {bool required = true, int minLength = 2}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return required ? 'Name is required' : null;
    }
    if (trimmed.length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    if (!_nameRegex.hasMatch(trimmed)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates OTP code
  /// 
  /// Default length is 6 digits
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'OTP can only contain digits';
    }
    return null;
  }

  /// Validates required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
