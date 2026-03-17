import 'package:flutter/foundation.dart';

import 'enums.dart';

class Logger {
  static LogMode _mode = LogMode.debug;

  static LogMode get mode => _mode;

  static set mode(LogMode mode) {
    Logger._mode = mode;
  }

  static const String _resetColor = '\x1B[0m';
  static const String _redColor = '\x1B[31m';
  static const String _greenColor = '\x1B[32m';
  static const String _yellowColor = '\x1B[33m';
  static const String _cyanColor = '\x1B[36m';

  static void log(dynamic data, {StackTrace? stackTrace}) {
    if (_mode == LogMode.debug) {
      if (kDebugMode) {
        print(
            '$_yellowColor ============================================= Log ========================================================$_resetColor');
        print(
            '$_greenColor Log:$_resetColor $_cyanColor$data ::: stackTrace: $stackTrace$_resetColor');
      }
    }
  }

  static void logError(dynamic data) {
    if (_mode == LogMode.debug) {
      if (kDebugMode) {
        print(
            '$_redColor ========================================= Error Log ===========================================================$_resetColor');
        print(
            '$_redColor  Error:$_resetColor $_redColor$data ::: stackTrace :${StackTrace.current}$_resetColor');
      }
    }
  }
}