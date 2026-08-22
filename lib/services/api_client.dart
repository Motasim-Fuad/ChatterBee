import 'dart:async';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import '../config/app_url.dart';
import '../utils/logger_utils.dart';

class ApiClient {
  late Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  bool _isLoggingOut = false;
  Future<_RefreshResult>? _refreshInFlight;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppUrl.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          LoggerUtils.logApi('REQUEST[${options.method}] => ${options.uri}');
          LoggerUtils.logDebug('Headers: ${options.headers}');
          if (options.data != null) {
            LoggerUtils.logDebug('Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          LoggerUtils.logSuccess(
              'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          LoggerUtils.logDebug('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          LoggerUtils.logError(
              'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          LoggerUtils.logError('Error Message: ${error.message}');

          if (error.response?.statusCode == 401) {
            final isAuthRequest = error.requestOptions.path.contains('login') ||
                error.requestOptions.path.contains('token/refresh');

            final alreadyRetried = error.requestOptions.extra['authRetried'] == true;
            if (!isAuthRequest && !alreadyRetried && !_isLoggingOut) {
              final refreshResult = await _refreshTokenSingleFlight();

              if (refreshResult == _RefreshResult.success) {
                final options = error.requestOptions;
                final token = await _secureStorage.getAccessToken();
                options.headers['Authorization'] = 'Bearer $token';
                options.extra['authRetried'] = true;

                try {
                  final response = await _dio.request(
                    options.path,
                    options: Options(
                      method: options.method,
                      headers: options.headers,
                    ),
                    data: options.data,
                    queryParameters: options.queryParameters,
                  );
                  return handler.resolve(response);
                } catch (e) {
                  return handler.next(error);
                }
              } else if (refreshResult == _RefreshResult.sessionExpired) {
                await _handleAutoLogout();
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<_RefreshResult> _refreshTokenSingleFlight() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;

    final future = _refreshToken();
    _refreshInFlight = future;
    future.whenComplete(() {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    });
    return future;
  }

  Future<_RefreshResult> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return _RefreshResult.sessionExpired;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: AppUrl.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ));
      final response = await refreshDio.post(
        AppUrl.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final payload = body is Map && body['data'] is Map ? body['data'] : body;
        final newAccessToken = payload is Map ? payload['access'] : null;
        if (newAccessToken is! String || newAccessToken.isEmpty) {
          return _RefreshResult.temporaryFailure;
        }
        await _secureStorage.saveAccessToken(newAccessToken);
        LoggerUtils.logSuccess('Token refreshed successfully');
        return _RefreshResult.success;
      }
      return _RefreshResult.temporaryFailure;
    } on DioException catch (e) {
      LoggerUtils.logError('Token refresh failed: $e');
      final status = e.response?.statusCode;
      return status == 401 || status == 403
          ? _RefreshResult.sessionExpired
          : _RefreshResult.temporaryFailure;
    } catch (e) {
      LoggerUtils.logError('Token refresh failed: $e');
      return _RefreshResult.temporaryFailure;
    }
  }

  Future<void> _handleAutoLogout() async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;

    try {
      LoggerUtils.logWarning('Auto logout triggered due to 401');

      final authRepository = AuthRepository();
      await authRepository.handleUnauthorized();
    } catch (e) {
      LoggerUtils.logError('Auto logout error: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  Future<ApiResponse<T>> get<T>(
      String url, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<T>> multipartPost<T>(
      String url, {
        required FormData formData,
        Map<String, dynamic>? queryParameters,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      final response = await _dio.post(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<T>> multipartPut<T>(
      String url, {
        required FormData formData,
        Map<String, dynamic>? queryParameters,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      final response = await _dio.put(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  ApiResponse<T> _handleResponse<T>(Response response) {
    final statusCode = response.statusCode ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(
        data: response.data,
        statusCode: statusCode,
        message: response.data is Map
            ? (response.data['message'] ?? 'Success')
            : 'Success',
      );
    } else {
      return ApiResponse.error(
        statusCode: statusCode,
        message: response.data is Map
            ? (response.data['message'] ?? 'Request failed')
            : 'Request failed',
        errors: response.data is Map ? response.data['errors'] : null,
      );
    }
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(
          statusCode: 408,
          message: 'Connection timeout. Please check your internet connection.',
          errorType: ErrorType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final responseData = error.response?.data;

        String message = 'An error occurred';
        Map<String, dynamic>? errors;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ??
              responseData['error'] ??
              responseData['detail'] ??
              'Server error';
          errors = responseData['errors'];
        }

        return ApiResponse.error(
          statusCode: statusCode,
          message: message,
          errors: errors,
          errorType: _getErrorType(statusCode),
        );

      case DioExceptionType.connectionError:
        return ApiResponse.error(
          statusCode: 0,
          message: 'No internet connection. Please check your network.',
          errorType: ErrorType.network,
        );

      case DioExceptionType.cancel:
        return ApiResponse.error(
          statusCode: 0,
          message: 'Request cancelled',
          errorType: ErrorType.cancelled,
        );

      default:
        return ApiResponse.error(
          statusCode: 500,
          message: error.message ?? 'An unexpected error occurred',
          errorType: ErrorType.unknown,
        );
    }
  }

  ErrorType _getErrorType(int statusCode) {
    if (statusCode == 401) return ErrorType.unauthorized;
    if (statusCode == 403) return ErrorType.forbidden;
    if (statusCode == 404) return ErrorType.notFound;
    if (statusCode == 422) return ErrorType.validationError;
    if (statusCode >= 500) return ErrorType.serverError;
    return ErrorType.unknown;
  }
}

enum _RefreshResult { success, sessionExpired, temporaryFailure }

class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final ErrorType? errorType;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
    this.errorType,
  });

  factory ApiResponse.success({
    required T data,
    required int statusCode,
    required String message,
  }) {
    return ApiResponse(
      success: true,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error({
    required int statusCode,
    required String message,
    Map<String, dynamic>? errors,
    ErrorType? errorType,
  }) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      message: message,
      errors: errors,
      errorType: errorType,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;

  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return fieldErrors?.toString();
  }
}

enum ErrorType {
  network,
  timeout,
  serverError,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  cancelled,
  unknown,
}
