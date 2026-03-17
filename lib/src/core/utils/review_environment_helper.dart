import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Helper class to detect if the app is running in a review environment
/// (TestFlight or App Store review)
class ReviewEnvironmentHelper {
  static const MethodChannel _channel = MethodChannel('com.ios.devalay/testflight');

  /// Checks if the app is running in TestFlight or App Store review environment
  /// 
  /// For iOS: Detects TestFlight by checking if the app receipt is from sandbox
  /// Also detects App Store review builds by checking for production receipts
  /// For Android: Can be extended to detect internal testing tracks
  static Future<bool> isInReviewEnvironment() async {
    if (kDebugMode) {
      // In debug mode, we're not in review environment
      return false;
    }

    if (Platform.isIOS) {
      final isReview = await _isTestFlightEnvironment();
      if (isReview) {
        debugPrint('Review environment detected - skipping version check');
      }
      return isReview;
    } else if (Platform.isAndroid) {
      // For Android, you could check if it's from internal testing track
      // For now, return false as Android review is less strict
      return false;
    }

    return false;
  }

  /// Detects if iOS app is running in TestFlight or App Store review environment
  /// 
  /// Uses native method channel to check if app receipt is from sandbox
  /// TestFlight apps have a sandbox receipt
  /// Note: App Store review builds are harder to detect, so dialogs are made dismissible
  static Future<bool> _isTestFlightEnvironment() async {
    try {
      if (Platform.isIOS) {
        // First try the enhanced method
        try {
          final bool? isInReview = await _channel.invokeMethod<bool>('isInReviewEnvironment');
          if (isInReview == true) {
            debugPrint('Detected review environment via isInReviewEnvironment');
            return true;
          }
        } catch (e) {
          debugPrint('isInReviewEnvironment method not available, trying isTestFlight: $e');
        }
        
        // Fallback to original method
        final bool? isTestFlight = await _channel.invokeMethod<bool>('isTestFlight');
        if (isTestFlight == true) {
          debugPrint('Detected TestFlight environment');
          return true;
        }
        
        return false;
      }
      return false;
    } catch (e) {
      // If method channel fails, log error but don't assume review environment
      // The dialog will still be dismissible to handle App Store review cases
      debugPrint('Error checking review environment: $e');
      return false;
    }
  }

  /// Alternative: Check if we should skip version check based on app state
  /// This can be used as a fallback
  static Future<bool> shouldSkipVersionCheck() async {
    // Skip if in debug mode
    if (kDebugMode) {
      return true;
    }

    // For production, we'll rely on making the dialog dismissible
    // rather than skipping entirely, to ensure users still get update prompts
    return false;
  }
}

