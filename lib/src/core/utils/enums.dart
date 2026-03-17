enum LogMode { debug, live }

enum ApiTypes { get, post, patch, delete }

enum CustomException {
  serverError,
  noInternet,
  timeOutError,
  tokenExpired,

  dalleImageContentViolation,
  unknownError;

  String get message {
    switch (this) {
      case CustomException.serverError:
        return 'Server Error';
      case CustomException.noInternet:
        return 'No Internet';
      case CustomException.timeOutError:
        return 'Request Time Out';
      case CustomException.tokenExpired:
        return 'Token Expired. Please Login';
      case CustomException.unknownError:
        return 'Something Went Wrong';
      case CustomException.dalleImageContentViolation:
        return 'Content policy violation';
    }
  }
}
