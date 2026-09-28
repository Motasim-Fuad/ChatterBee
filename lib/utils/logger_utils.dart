import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: false,
      printTime: true,
    ),
  );

  
  static void logInfo(String message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  
  static void logDebug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  
  static void logWarning(String message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  
  static void logSuccess(String message) {
    if (kDebugMode) {
      _logger.i('$message');
    }
  }

  
  static void logApi(String message) {
    if (kDebugMode) {
      _logger.i('API: $message');
    }
  }
}
