import 'dart:io';
import 'package:dio/dio.dart';

class Failure {
  static const Failure requestCancelled = Failure._('Request Cancelled');
  static const Failure unauthorisedRequest = Failure._('Unauthorised Request');
  static const Failure badRequest = Failure._('Bad Request');
  static const Failure badCertificate = Failure._('Bad Certificate');
  static const Failure unknown = Failure._('Unknown Error Occurred');
  static const Failure methodNotAllowed = Failure._('Method Not Allowed');
  static const Failure notAcceptable = Failure._('Not Acceptable');
  static const Failure requestTimeout = Failure._('Request Timeout');
  static const Failure sendTimeout = Failure._('Send Timeout');
  static const Failure connectTimeout = Failure._('Connect Timeout');
  static const Failure conflict = Failure._('Error due to a Conflict');
  static const Failure internalServerError = Failure._('Internal Server Error');
  static const Failure notImplemented = Failure._('Not Implemented');
  static const Failure serviceUnavailable = Failure._('Service Unavailable');
  static const Failure noInternetConnection =
      Failure._('No Internet Connection');
  static const Failure formatException = Failure._('Format Exception');
  static const Failure unableToProcess = Failure._('Unable to Process');
  static const Failure unexpectedError = Failure._('Unexpected Error');
  static const Failure invalidCredentials = Failure._('Invalid Credentials');
  static const Failure permissionDenied = Failure._('Permission Denied');
  static const Failure accountLocked = Failure._('Account Locked');
  static const Failure notFound = Failure._('Not Found');
  static const Failure authenticationFailureFromServer =
      Failure._('Authentication Failure from Server');

  static Failure customError(String message) {
    return Failure._(message);
  }

  static Failure invalidPort(String port) {
    return Failure._('Invalid Port: $port');
  }

  const Failure._(this.errorMessage);

  final String errorMessage;

  static Failure getDioException(error) {
    if (error is Exception) {
      try {
        Failure networkExceptions;
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              networkExceptions = requestCancelled;
              break;
            case DioExceptionType.connectionTimeout:
              networkExceptions = requestTimeout;
              break;
            case DioExceptionType.connectionError:
              networkExceptions = noInternetConnection;
              break;
            case DioExceptionType.receiveTimeout:
              networkExceptions = sendTimeout;
              break;
            case DioExceptionType.badCertificate:
              networkExceptions = badCertificate;
              break;
            case DioExceptionType.unknown:
              networkExceptions = unknown;
              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 400:
                  networkExceptions = unauthorisedRequest;
                  break;
                case 401:
                  networkExceptions = unauthorisedRequest;
                  break;
                case 403:
                  networkExceptions = unauthorisedRequest;
                  break;
                case 404:
                  networkExceptions = notFound;
                  break;
                case 408:
                  networkExceptions = requestTimeout;
                  break;
                case 409:
                  networkExceptions = conflict;
                  break;
                case 500:
                  networkExceptions = internalServerError;
                  break;
                case 503:
                  networkExceptions = serviceUnavailable;
                  break;
                default:
                  var responseCode = error.response!.statusCode;
                  networkExceptions =
                      Failure._("Received Invalid status code: $responseCode");
              }
              break;
            case DioExceptionType.sendTimeout:
              networkExceptions = sendTimeout;
              break;
          }
        } else if (error is SocketException) {
          networkExceptions = connectTimeout;
        } else {
          networkExceptions = unexpectedError;
        }
        return networkExceptions;
      } on FormatException catch (_) {
        return formatException;
      } catch (_) {
        return unexpectedError;
      }
    } else if (error is ArgumentError) {
      if (error.toString().contains("is not a subtype of ")) {
        return unableToProcess;
      } else {
        return unexpectedError;
      }
    }

    return unexpectedError;
  }

  static Failure getDioBadResponseException(Response<dynamic> response) {
    return Failure.getDioException(DioException.badResponse(
        statusCode: response.statusCode ?? 400,
        requestOptions: response.requestOptions,
        response: response));
  }

  static String getErrorMessage(Failure networkExceptions) {
    switch (networkExceptions) {
      case Failure.authenticationFailureFromServer:
        return 'Authentication Failure';
      case Failure.invalidCredentials:
        return 'Invalid Credentials';
      case Failure.badCertificate:
        return 'Bad Certificate';
      case Failure.unknown:
        return 'Unknown Error Occurred';
      case Failure.notImplemented:
        return 'Not Implemented';
      case Failure.requestCancelled:
        return 'Request Cancelled';
      case Failure.internalServerError:
        return 'Internal Server Error';
      case Failure.serviceUnavailable:
        return 'Service unavailable';
      case Failure.methodNotAllowed:
        return 'Method Allowed';
      case Failure.badRequest:
        return 'Bad request';
      case Failure.unauthorisedRequest:
        return 'Unauthorised request';
      case Failure.unexpectedError:
        return 'Unexpected error occurred';
      case Failure.requestTimeout:
        return 'Connection request timeout';
      case Failure.noInternetConnection:
        return 'No internet connection';
      case Failure.conflict:
        return 'Error due to a conflict';
      case Failure.sendTimeout:
        return 'Send timeout in connection with API server';
      case Failure.unableToProcess:
        return 'Unable to process the data';
      case Failure.formatException:
        return 'Unexpected error occurred';
      case Failure.notAcceptable:
        return 'Not acceptable';
      case Failure.accountLocked:
        return 'Account locked';
      case Failure.connectTimeout:
        return 'Unable to establish a connection';
      default:
        return 'Unknown Error';
    }
  }

  @override
  String toString() {
    return errorMessage;
  }
}

class FailureResponse {
  String errorMessage;
  Map<String, dynamic> data;

  FailureResponse({required this.errorMessage, required this.data});
}
