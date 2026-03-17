import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class to access environment variables
class EnvConfig {
  EnvConfig._();

  /// Get Razorpay Key ID from environment variables
  /// Safely handles cases where dotenv is not yet loaded
  static String get razorpayKeyId {
    try {
      // Check if dotenv is loaded before accessing
      if (dotenv.isInitialized) {
        final keyId = dotenv.env['RAZORPAY_KEY_ID'];
        if (keyId != null && keyId.isNotEmpty) {
          debugPrint('✅ Using Razorpay Key from .env: ${keyId.substring(0, 8)}...');
          return keyId;
        }
      }
    } catch (e) {
      // If dotenv is not initialized or any error occurs, use fallback
      debugPrint('⚠️ Could not access RAZORPAY_KEY_ID from env: $e');
    }
    
    // Fallback to default test key if env is not loaded or key not found
    const testKey = 'rzp_live_dQ0rFFCKNx7lZX';
    debugPrint('✅ Using Razorpay Test Key (fallback): ${testKey.substring(0, 8)}...');
    return testKey;
  }
}

