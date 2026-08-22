import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Info log - General information
  static void logInfo(String message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  // Debug log - Debugging information
  static void logDebug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  // Warning log - Warning messages
  static void logWarning(String message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  // Error log - Error messages
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  // Success log - Success messages
  static void logSuccess(String message) {
    if (kDebugMode) {
      _logger.i('✅ $message');
    }
  }

  // API log - API related logs
  static void logApi(String message) {
    if (kDebugMode) {
      _logger.i('🌐 API: $message');
    }
  }
}
