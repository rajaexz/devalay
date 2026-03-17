import 'package:devalay_app/src/core/api/api_log_interceptor.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';
import 'package:devalay_app/src/core/network/network_info.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/enums.dart';

class ApiCalling {
  late Dio _dio;
  final NetworkInfo _networkInfo = NetworkInfo();
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  Future<CustomResponse> callApi({
    required ApiTypes apiTypes,
    required String url,
    String? referer,
    Object? data,
    String? token,
    Map<String, String?>? optionalHeader,
    ResponseType? responseType,
    int retryCount = 0,
  }) async {
    final bool isConnected = await _networkInfo.isConnected();
    final sessionId = await PrefManager.getUserSessionId();
    final csrf = await PrefManager.getUserCsrfToken();
    
    if (!isConnected) {
      // Show no internet toast at bottom
      NetworkErrorHandler.showNoInternetToast();
      return CustomResponse(
        error: CustomException.noInternet.message,
        statusCode: 0,
        isNetworkError: true,
      );
    }

    try {
      Response<dynamic> response;
      _initDio(token: token, responseType: responseType, optionalHeader: {
        'Cookie': 'sessionid=$sessionId;csrftoken=$csrf',
        'X-CSRFToken': csrf,
        'Referer': referer
      });
      
      switch (apiTypes) {
        case ApiTypes.get:
          response = await _dio.get(url);
          break;
        case ApiTypes.post:
          response = await _dio.post(url, data: data);
          break;
        case ApiTypes.patch:
          response = await _dio.patch(url, data: data);
          break;
        case ApiTypes.delete:
          response = await _dio.delete(url, data: data);
          break;
      }
      
      return CustomResponse(
        response: response, 
        statusCode: response.statusCode,
        isSuccessful: response.statusCode! >= 200 && response.statusCode! < 300,
      );
    } on DioException catch (e) {
      Logger.logError('API Error: ${e.message} - URL: $url - Type: ${e.type}');
      
      // Handle specific error types with toast messages
      if (e.type == DioExceptionType.connectionError) {
        // Check if it's a connection refused error (server might be down)
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('connection refused')) {
          // Retry for connection refused errors
          if (retryCount < maxRetries) {
            final delaySeconds = retryDelay.inSeconds * (retryCount + 1);
            Logger.logError('🔄 Connection refused, retrying... (Attempt ${retryCount + 1}/$maxRetries)');
            Logger.logError('⏳ Waiting $delaySeconds seconds before retry...');
            Logger.logError('📡 URL: $url');
            await Future.delayed(retryDelay * (retryCount + 1));
            Logger.logError('🔄 Retrying API call now...');
            return callApi(
              apiTypes: apiTypes,
              url: url,
              referer: referer,
              data: data,
              token: token,
              optionalHeader: optionalHeader,
              responseType: responseType,
              retryCount: retryCount + 1,
            );
          }
          // After max retries, show server unavailable message
          Logger.logError('❌ Connection refused after $maxRetries retries. Server may be down or unreachable.');
          Logger.logError('📡 Failed URL: $url');
          NetworkErrorHandler.showNetworkErrorToast('Server is temporarily unavailable. Please check your internet connection and try again.');
          return CustomResponse(
            error: 'Server is temporarily unavailable. Please check your internet connection and try again.',
            statusCode: e.response?.statusCode,
            isNetworkError: true,
          );
        }
        // For other connection errors, also retry
        if (retryCount < maxRetries) {
          Logger.logError('🔄 Connection error, retrying... (Attempt ${retryCount + 1}/$maxRetries)');
          await Future.delayed(retryDelay * (retryCount + 1));
          return callApi(
            apiTypes: apiTypes,
            url: url,
            referer: referer,
            data: data,
            token: token,
            optionalHeader: optionalHeader,
            responseType: responseType,
            retryCount: retryCount + 1,
          );
        }
        NetworkErrorHandler.showNoInternetToast();
        return CustomResponse(
          error: CustomException.noInternet.message,
          statusCode: e.response?.statusCode,
          isNetworkError: true,
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        NetworkErrorHandler.showNetworkErrorToast(CustomException.timeOutError.message);
        return CustomResponse(
          error: CustomException.timeOutError.message,
          statusCode: e.response?.statusCode,
          isTimeoutError: true,
        );
      }
      
      if (e.response?.statusCode == 400) {
        // Handle 400 Bad Request - extract and show actual error message
        String errorMessage = _extractErrorMessage(e.response?.data);
        Logger.logError('400 Bad Request - URL: $url - Error: $errorMessage');
        Logger.logError('Request Data: $data');
        NetworkErrorHandler.showNetworkErrorToast(errorMessage.isNotEmpty 
            ? errorMessage 
            : 'Invalid request. Please check your input and try again.');
        return CustomResponse(
          response: e.response,
          statusCode: e.response?.statusCode,
          error: errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Invalid request. Please check your input and try again.',
        );
      }
      if (e.response?.statusCode == 500) {
        NetworkErrorHandler.showNetworkErrorToast(CustomException.serverError.message);
        return CustomResponse(
          error: CustomException.serverError.message,
          statusCode: e.response?.statusCode,
          isServerError: true,
        );
      }
      if (e.response?.statusCode == 403) {
        // Check if it's a non-critical endpoint that should show dialog instead of redirecting
        if (_isNonCriticalEndpoint(url)) {
          // For non-critical endpoints, just show error message, don't redirect
          String errorMessage = _extractErrorMessage(e.response?.data);
          NetworkErrorHandler.showNetworkErrorToast(
            errorMessage.isNotEmpty 
                ? errorMessage 
                : 'Access denied. You don\'t have permission to access this resource.'
          );
          return CustomResponse(
            error: errorMessage.isNotEmpty 
                ? errorMessage 
                : 'Access denied. You don\'t have permission to access this resource.',
            statusCode: e.response?.statusCode,
            isAuthError: false, // Not a critical auth error
          );
        }
        
        // For critical endpoints, handle as authentication error
        NetworkErrorHandler.showNetworkErrorToast(CustomException.tokenExpired.message);
        _handle403Error();
        
        return CustomResponse(
          error: CustomException.tokenExpired.message,
          statusCode: e.response?.statusCode,
          isAuthError: true,
        );
      }
      if (e.response?.statusCode == 401) {
        // Check if it's a non-critical endpoint
        if (_isNonCriticalEndpoint(url)) {
          // For non-critical endpoints, just show error message
          String errorMessage = _extractErrorMessage(e.response?.data);
          NetworkErrorHandler.showNetworkErrorToast(
            errorMessage.isNotEmpty 
                ? errorMessage 
                : 'Authentication required. Please try again.'
          );
          return CustomResponse(
            error: errorMessage.isNotEmpty 
                ? errorMessage 
                : 'Authentication required. Please try again.',
            statusCode: e.response?.statusCode,
            isAuthError: false,
          );
        }
        
        // For critical endpoints, handle as authentication error
        NetworkErrorHandler.showNetworkErrorToast(CustomException.tokenExpired.message);
        _handle403Error();
        
        return CustomResponse(
          error: CustomException.tokenExpired.message,
          statusCode: e.response?.statusCode,
          isAuthError: true,
        );
      }
      
      // Retry logic for transient errors
      if (retryCount < maxRetries && _shouldRetry(e)) {
        await Future.delayed(retryDelay * (retryCount + 1));
        return callApi(
          apiTypes: apiTypes,
          url: url,
          referer: referer,
          data: data,
          token: token,
          optionalHeader: optionalHeader,
          responseType: responseType,
          retryCount: retryCount + 1,
        );
      }
      
      if (e.response != null) {
        String errorMessage = _extractErrorMessage(e.response?.data);
        NetworkErrorHandler.showNetworkErrorToast(errorMessage);
        return CustomResponse(
          response: e.response, 
          statusCode: e.response?.statusCode,
          error: errorMessage,
        );
      } else {
        NetworkErrorHandler.showNetworkErrorToast(CustomException.unknownError.message);
        return CustomResponse(
          error: CustomException.unknownError.message,
          statusCode: null,
        );
      }
    } catch (e) {
      Logger.logError('Unexpected API Error: $e');
      NetworkErrorHandler.showNetworkErrorToast(CustomException.unknownError.message);
      return CustomResponse(
        error: CustomException.unknownError.message,
        statusCode: null,
      );
    }
  }

  bool _shouldRetry(DioException error) {
    // Don't retry connection refused errors here - handled separately above
    final errorMessage = error.message?.toLowerCase() ?? '';
    if (errorMessage.contains('connection refused')) {
      return false; // Already handled in connectionError block
    }
    
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode ?? 0) >= 500;
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return '';
    
    // Handle string responses
    if (responseData is String) {
      try {
        // Try to parse as JSON if it's a JSON string
        final parsed = responseData.replaceAll(RegExp(r'[\{\}\[\]]'), '');
        if (parsed.isNotEmpty) {
          return parsed;
        }
      } catch (e) {
        return responseData;
      }
      return responseData;
    }
    
    if (responseData is Map<String, dynamic>) {
      // Try to extract error message from common response formats
      if (responseData.containsKey('message')) {
        final msg = responseData['message'];
        if (msg is String) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
        return msg.toString();
      }
      if (responseData.containsKey('error')) {
        final err = responseData['error'];
        if (err is String) return err;
        if (err is Map) {
          // Handle nested error objects
          if (err.containsKey('message')) return err['message'].toString();
          if (err.isNotEmpty) return err.values.first.toString();
        }
        return err.toString();
      }
      if (responseData.containsKey('detail')) {
        return responseData['detail'].toString();
      }
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map) {
          // Get first error value
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
        }
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
      // Try common field error patterns
      for (var key in responseData.keys) {
        if (key.toLowerCase().contains('error') || 
            key.toLowerCase().contains('message') ||
            key.toLowerCase().contains('detail')) {
          final value = responseData[key];
          if (value is String && value.isNotEmpty) return value;
          if (value is List && value.isNotEmpty) return value.first.toString();
        }
      }
    }
    
    return '';
  }

  /// Check if the endpoint is non-critical (should show dialog instead of redirecting)
  bool _isNonCriticalEndpoint(String url) {
    final urlLower = url.toLowerCase();
    
    // List of non-critical endpoints that should not trigger login redirect
    final nonCriticalEndpoints = [
      'check-version',
      'admin-orders',
      'admin-order',
      'version',
    ];
    
    // Check if URL contains any non-critical endpoint
    for (var endpoint in nonCriticalEndpoints) {
      if (urlLower.contains(endpoint)) {
        return true;
      }
    }
    
    return false;
  }

  Future<void> _handle403Error() async {
    try {
      Logger.log("Handling 403 error - Clearing user session and navigating to login");
      
      // Sign out from Firebase if signed in
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        Logger.logError("Firebase sign out error: $e");
      }
      
      // Clear all user preferences
      PrefManager.clearPreferences();
      
      // Navigate to login page
      // Use navigatorKey to ensure we can navigate from anywhere
      final navigator = AppRouter.navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        // Pop all routes and navigate to login
        navigator.popUntil((route) => route.isFirst);
      }
      
      // Navigate to login screen
      AppRouter.go(RouterConstant.loginScreen);
      
      Logger.log("Successfully navigated to login page after 403 error");
    } catch (e) {
      Logger.logError("Error handling 403: $e");
      // Fallback navigation
      AppRouter.go(RouterConstant.loginScreen);
    }
  }

  void _initDio({
    required String? token,
    required Map<String, String?>? optionalHeader,
    required ResponseType? responseType,
  }) {
    late Map<String, String?> header;
    if (optionalHeader != null) {
      header = optionalHeader;
    }
    
    final BaseOptions options = BaseOptions(
      baseUrl: AppConstant.baseUrl,
      receiveTimeout: const Duration(seconds: 100),
      connectTimeout: const Duration(seconds: 100),
      headers: header,
      responseType: responseType ?? ResponseType.json,
    );
    
    _dio = Dio(options);
    
    // Add global error interceptor
    _dio.interceptors.add(GlobalErrorInterceptor());
    
    if (Logger.mode == LogMode.debug) {
      _dio.interceptors.add(LoggerInterceptor());
    }
  }
}

class GlobalErrorInterceptor extends Interceptor {
  /// Check if the endpoint is non-critical (should show dialog instead of redirecting)
  bool _isNonCriticalEndpoint(String url) {
    final urlLower = url.toLowerCase();
    
    // List of non-critical endpoints that should not trigger login redirect
    final nonCriticalEndpoints = [
      'check-version',
      'admin-orders',
      'admin-order',
      'version',
    ];
    
    // Check if URL contains any non-critical endpoint
    for (var endpoint in nonCriticalEndpoints) {
      if (urlLower.contains(endpoint)) {
        return true;
      }
    }
    
    return false;
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return '';
    
    // Handle string responses
    if (responseData is String) {
      try {
        // Try to parse as JSON if it's a JSON string
        final parsed = responseData.replaceAll(RegExp(r'[\{\}\[\]]'), '');
        if (parsed.isNotEmpty) {
          return parsed;
        }
      } catch (e) {
        return responseData;
      }
      return responseData;
    }
    
    if (responseData is Map<String, dynamic>) {
      // Try to extract error message from common response formats
      if (responseData.containsKey('message')) {
        final msg = responseData['message'];
        if (msg is String) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
        return msg.toString();
      }
      if (responseData.containsKey('error')) {
        final err = responseData['error'];
        if (err is String) return err;
        if (err is Map) {
          // Handle nested error objects
          if (err.containsKey('message')) return err['message'].toString();
          if (err.isNotEmpty) return err.values.first.toString();
        }
        return err.toString();
      }
      if (responseData.containsKey('detail')) {
        return responseData['detail'].toString();
      }
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map) {
          // Get first error value
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
        }
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
      // Try common field error patterns
      for (var key in responseData.keys) {
        if (key.toLowerCase().contains('error') || 
            key.toLowerCase().contains('message') ||
            key.toLowerCase().contains('detail')) {
          final value = responseData[key];
          if (value is String && value.isNotEmpty) return value;
          if (value is List && value.isNotEmpty) return value.first.toString();
        }
      }
    }
    
    return '';
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.logError('Global Error Interceptor: ${err.message}');
    
    // Don't show toast for connection errors here - let the retry logic handle it
    // The retry logic in callApi will show appropriate messages after retries are exhausted
    // This prevents showing error toasts before retries are attempted
    if (err.type == DioExceptionType.connectionError) {
      // Check if it's a connection refused error - these will be retried
      final errorMessage = err.message?.toLowerCase() ?? '';
      if (errorMessage.contains('connection refused')) {
        // Don't show toast here - retry logic will handle it
        Logger.logError('Connection refused detected - retry logic will handle this');
      } else {
        // For other connection errors, show toast only if not retrying
        // NetworkErrorHandler.showNoInternetToast();
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
               err.type == DioExceptionType.sendTimeout ||
               err.type == DioExceptionType.receiveTimeout) {
      // For timeout errors, show toast but don't redirect
      final url = err.requestOptions.uri.toString();
      if (_isNonCriticalEndpoint(url)) {
        // For non-critical endpoints, just show toast
        NetworkErrorHandler.showNetworkErrorToast(
          'Request timed out. Please check your internet connection and try again.'
        );
      } else {
        // Don't show toast here - retry logic will handle it
        // NetworkErrorHandler.showNetworkErrorToast(CustomException.timeOutError.message);
      }
    } else if (err.response?.statusCode == 400) {
      // Handle 400 Bad Request - extract and show actual error message
      String errorMessage = _extractErrorMessage(err.response?.data);
      Logger.logError('400 Bad Request Error: $errorMessage');
      Logger.logError('Request URL: ${err.requestOptions.uri}');
      Logger.logError('Request Data: ${err.requestOptions.data}');
      if (errorMessage.isNotEmpty) {
        NetworkErrorHandler.showNetworkErrorToast(errorMessage);
      } else {
        NetworkErrorHandler.showNetworkErrorToast('Invalid request. Please check your input and try again.');
      }
    } else if (err.response?.statusCode == 500) {
      NetworkErrorHandler.showNetworkErrorToast(CustomException.serverError.message);
    } else if (err.response?.statusCode == 403 || err.response?.statusCode == 401) {
      final url = err.requestOptions.uri.toString();
      
      // Check if it's a non-critical endpoint
      if (_isNonCriticalEndpoint(url)) {
        // For non-critical endpoints, just show toast, don't redirect
        String errorMessage = _extractErrorMessage(err.response?.data);
        NetworkErrorHandler.showNetworkErrorToast(
          errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Access denied. You don\'t have permission to access this resource.'
        );
      } else {
        // For critical endpoints, handle as authentication error
        NetworkErrorHandler.showNetworkErrorToast(CustomException.tokenExpired.message);
        _handleAuthError();
      }
    }
    
    // Log additional error details for debugging
    if (err.response != null) {
      Logger.logError('Response Status: ${err.response?.statusCode}');
      Logger.logError('Response Data: ${err.response?.data}');
    }
    
    super.onError(err, handler);
  }

  Future<void> _handleAuthError() async {
    try {
      Logger.log("Global Interceptor: Handling auth error - Clearing user session and navigating to login");
      
      // Sign out from Firebase if signed in
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        Logger.logError("Firebase sign out error: $e");
      }
      
      // Clear all user preferences
      PrefManager.clearPreferences();
      
      // Navigate to login page
      AppRouter.go(RouterConstant.loginScreen);
      
      Logger.log("Successfully navigated to login page after auth error");
    } catch (e) {
      Logger.logError("Error handling auth error: $e");
      // Fallback navigation
      AppRouter.go(RouterConstant.loginScreen);
    }
  }
}

class CustomResponse {
  CustomResponse({
    this.response,
    this.statusCode,
    this.error = 'Something Went Wrong',
    this.isSuccessful = false,
    this.isNetworkError = false,
    this.isTimeoutError = false,
    this.isServerError = false,
    this.isAuthError = false,
  });

  final Response<dynamic>? response;
  final int? statusCode;
  String error;
  final bool isSuccessful;
  final bool isNetworkError;
  final bool isTimeoutError;
  final bool isServerError;
  final bool isAuthError;

  bool get hasError => error != 'Something Went Wrong' || !isSuccessful;
  
  bool get shouldRetry => isNetworkError || isTimeoutError || isServerError;

  static fromJson(data) {}
}
