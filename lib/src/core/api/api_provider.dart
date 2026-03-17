import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:dio/dio.dart';

class ApiProvider {
  ApiProvider._();

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      baseUrl: AppConstant.baseUrl,
    ),
  );

  static Dio getDio({String? baseUrl}) {
    // Set dynamic base URL if provided
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }

    // Prevent adding PrettyDioLogger multiple times
    // if (kDebugMode && !_dio.interceptors.any((i) => i is DioInterceptor)) {
    //   _dio.interceptors.add(
    //     DioLogger(
    //         requestBody: false,
    //         request: true,
    //         requestHeader: false,
    //         responseHeader: false,
    //         responseBody: false),
    //   );
    // }
    return _dio;
  }
}
