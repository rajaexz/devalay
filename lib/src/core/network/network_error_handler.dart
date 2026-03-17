import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
import 'package:devalay_app/src/core/utils/logger.dart';

class NetworkErrorHandler {
  static final NetworkErrorHandler _instance = NetworkErrorHandler._internal();
  factory NetworkErrorHandler() => _instance;
  NetworkErrorHandler._internal();

 
  static void handleError(dynamic error, {BuildContext? context}) {
    Logger.logError('Network Error Handler: $error');
    
    String userMessage = _getUserFriendlyMessage(error);
    
   
    _showErrorToast(userMessage);
    
    
    Logger.logError('Error details: $error');
  }

  static void handleApiError(dynamic response, {BuildContext? context}) {
    if (response == null) {
      _showErrorToast(CustomException.unknownError.message);
      return;
    }

    String errorMessage = _extractErrorMessage(response);
    _showErrorToast(errorMessage);
  }

 
  static String _getUserFriendlyMessage(dynamic error) {
    if (error == null) return CustomException.unknownError.message;

    
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return CustomException.noInternet.message;
    }

    if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timeout')) {
      return CustomException.timeOutError.message;
    }

    if (error.toString().contains('401') ||
        error.toString().contains('unauthorized')) {
      return CustomException.tokenExpired.message;
    }

    if (error.toString().contains('500') ||
        error.toString().contains('server error')) {
      return CustomException.serverError.message;
    }

    // Handle DioException
    if (error.toString().contains('DioException')) {
      if (error.toString().contains('connection')) {
        return CustomException.noInternet.message;
      }
      if (error.toString().contains('timeout')) {
        return CustomException.timeOutError.message;
      }
    }

    return CustomException.unknownError.message;
  }

  // Extract error message from API response
  static String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return CustomException.unknownError.message;

    if (responseData is Map<String, dynamic>) {
      // Try to extract error message from common response formats
      if (responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
      if (responseData.containsKey('error')) {
        return responseData['error'].toString();
      }
      if (responseData.containsKey('detail')) {
        return responseData['detail'].toString();
      }
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map) {
          return errors.values.first.toString();
        }
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    }

    return CustomException.unknownError.message;
  }

 
  static void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 3,
    );
  }

  // Show success toast at bottom
  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 2,
    );
  }

  
  static void showInfoToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 2,
    );
  }

  
  static void showNoInternetToast() {
    Fluttertoast.showToast(
      msg: 'No internet connection. Please check your network settings.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 3,
    );
  }

  // Show connection restored toast
  static void showConnectionRestoredToast() {
    Fluttertoast.showToast(
      msg: 'Internet connection restored',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 2,
    );
  }

  
  static void showNetworkErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 3,
    );
  }

  // Show warning toast
  static void showWarningToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 2,
    );
  }

 
  static bool isRetryableError(dynamic error) {
    if (error == null) return false;

    String errorString = error.toString().toLowerCase();
    
    return errorString.contains('timeout') ||
           errorString.contains('connection') ||
           errorString.contains('network') ||
           errorString.contains('500') ||
           errorString.contains('502') ||
           errorString.contains('503') ||
           errorString.contains('504');
  }

  
  static Duration getRetryDelay(dynamic error, int retryCount) {
    if (error.toString().contains('timeout')) {
      return Duration(seconds: (retryCount + 1) * 2);
    }
    if (error.toString().contains('connection')) {
      return Duration(seconds: (retryCount + 1) * 3);
    }
    return Duration(seconds: (retryCount + 1) * 1);
  }

  /// Show error dialog instead of redirecting to login
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(
                buttonText ?? 'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show error dialog for 403/401 errors without redirecting
  static void showPermissionErrorDialog(BuildContext context, {String? customMessage}) {
    final message = customMessage ?? 
        'You don\'t have permission to access this resource. Please contact support if you believe this is an error.';
    
    showErrorDialog(
      context: context,
      title: 'Access Denied',
      message: message,
      buttonText: 'OK',
    );
  }

  /// Show error dialog for timeout errors
  static void showTimeoutErrorDialog(BuildContext context) {
    showErrorDialog(
      context: context,
      title: 'Connection Timeout',
      message: 'The request took too long to complete. Please check your internet connection and try again.',
      buttonText: 'OK',
    );
  }
} 