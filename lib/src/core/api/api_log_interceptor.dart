import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final RequestOptions options = err.requestOptions;
    final String requestPath = '${options.baseUrl}${options.path}';
    Logger.logError('onError: ${options.method} request => $requestPath');
    Logger.logError('onError: ${err.error}, Message: ${err.message}');
    return super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String requestPath = '${options.baseUrl}${options.path}';
    Logger.log('onRequest: ${options.method} request => $requestPath');
    Logger.log('onRequest: Request Headers => ${options.headers}');
    Logger.log('onRequest: Request Data => ${_prettyJsonEncode(options.data)}');

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    Logger.log(
      'onResponse: StatusCode: ${response.statusCode}, Data: ${_prettyJsonEncode(response.data)}',
    );
    return super.onResponse(response, handler);
  }

  String _prettyJsonEncode(dynamic data) {
    try {
      const JsonEncoder encoder = JsonEncoder();
      final String jsonString = encoder.convert(data);
      return jsonString;
    } catch (e) {
      return data.toString();
    }
  }
}
