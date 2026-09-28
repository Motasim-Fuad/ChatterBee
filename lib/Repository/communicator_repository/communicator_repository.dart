import 'dart:async';
import 'dart:convert';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/foundation.dart';

class CommunicatorRepository {
  final ApiClient _client = ApiClient();

  
  Map<String, dynamic>? _unwrap(Map<String, dynamic> body) {
    final rawData = body['data'] ?? body;
    if (rawData is Map && body['success'] != false) {
      return Map<String, dynamic>.from(rawData);
    }
    return null;
  }

  
  Future<ApiResponse<CommCategoryListResponse>> getCategoriesLite({
    required bool buddyMode,
    String lang = 'en',
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/communicator/categories/',
        queryParameters: {'lang': lang, 'buddy_mode': buddyMode.toString()},
      );
      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final raw = _unwrap(body);
        if (raw != null) {
          return ApiResponse.success(
            data: CommCategoryListResponse.fromJson(raw, lang: lang),
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Success',
          );
        }
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: body['message'] ?? 'Failed to load categories',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
        errorType: response.errorType,
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.getCategoriesLite error: $e');
      return ApiResponse.error(
        statusCode: 500,
        message: 'Something went wrong. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  
  Future<ApiResponse<CommCategoryItemsResponse>> getCategoryItems(
      int categoryId, {
        String lang = 'en',
      }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/communicator/categories/$categoryId/items/',
        queryParameters: {'lang': lang},
      );
      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final raw = _unwrap(body);
        if (raw != null) {
          return ApiResponse.success(
            data: CommCategoryItemsResponse.fromJson(raw, lang: lang),
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Success',
          );
        }
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: body['message'] ?? 'Failed to load category',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
        errorType: response.errorType,
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.getCategoryItems error: $e');
      return ApiResponse.error(
        statusCode: 500,
        message: 'Something went wrong. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  
  Future<ApiResponse<CommSubCategoryItemsResponse>> getSubCategoryItems(
      int subCategoryId, {
        String lang = 'en',
      }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/communicator/sub-categories/$subCategoryId/items/',
        queryParameters: {'lang': lang},
      );
      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final raw = _unwrap(body);
        if (raw != null) {
          return ApiResponse.success(
            data: CommSubCategoryItemsResponse.fromJson(raw, lang: lang),
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Success',
          );
        }
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: body['message'] ?? 'Failed to load sub-category',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
        errorType: response.errorType,
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.getSubCategoryItems error: $e');
      return ApiResponse.error(
        statusCode: 500,
        message: 'Something went wrong. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  
  Future<ApiResponse<CommSearchResponse>> search(
      String query, {
        String lang = 'en',
      }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/communicator/search/',
        queryParameters: {'q': query, 'lang': lang},
      );
      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final raw = _unwrap(body);
        if (raw != null) {
          return ApiResponse.success(
            data: CommSearchResponse.fromJson(raw, lang: lang),
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Success',
          );
        }
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: body['message'] ?? 'Search failed',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
        errorType: response.errorType,
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.search error: $e');
      return ApiResponse.error(
        statusCode: 500,
        message: 'Something went wrong. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  
  String _cacheKey(String lang, bool buddyMode) =>
      'comm_content_cache_${lang}_${buddyMode ? 'buddy' : 'normal'}';

  Future<CommunicatorContentModel?> getCachedContent({
    required bool buddyMode,
    String lang = 'en',
  }) async {
    try {
      final raw = StorageService().getString(_cacheKey(lang, buddyMode));
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return await compute(
        _parseCommunicatorContentIsolate,
        {'json': json, 'lang': lang},
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(
      String lang, bool buddyMode, Map<String, dynamic> rawJson) async {
    try {
      await StorageService()
          .setString(_cacheKey(lang, buddyMode), jsonEncode(rawJson));
    } catch (_) {}
  }

  
  Future<ApiResponse<CommunicatorContentModel>> getContent(
      {String lang = 'en'}) async {
    return _fetchContent(AppUrl.getCommunicatorContent(lang: lang),
        buddyMode: false, lang: lang);
  }

  
  Future<ApiResponse<CommunicatorContentModel>> getBuddyModeContent(
      {String lang = 'en'}) async {
    return _fetchContent(AppUrl.getCommunicatorBuddyModeContent(lang: lang),
        buddyMode: true, lang: lang);
  }

  
  Future<void> pressContent({
    required String contentType,
    required int contentId,
  }) async {
    try {
      await _client.post<Map<String, dynamic>>(
        AppUrl.pressContent,
        data: {
          'content_type': contentType,
          'content_id': contentId,
        },
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.pressContent error: $e');
    }
  }

  
  Future<ApiResponse<CommunicatorContentModel>> _fetchContent(
      String url, {
        required bool buddyMode,
        String lang = 'en',
      }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(url);

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;

        final rawData = body['data'] ?? body;
        if (rawData is Map && body['success'] != false) {
          final rawJson = Map<String, dynamic>.from(rawData);

          final model = await compute(
            _parseCommunicatorContentIsolate,
            {'json': rawJson, 'lang': lang},
          );

          unawaited(_saveToCache(lang, buddyMode, rawJson));

          return ApiResponse.success(
            data: model,
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Success',
          );
        }

        return ApiResponse.error(
          statusCode: response.statusCode,
          message: body['message'] ?? 'Failed to load content',
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
        errorType: response.errorType,
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.getContent error: $e');
      return ApiResponse.error(
        statusCode: 500,
        message: 'Something went wrong. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }
}


CommunicatorContentModel _parseCommunicatorContentIsolate(
    Map<String, dynamic> args) {
  final json = args['json'] as Map<String, dynamic>;
  final lang = args['lang'] as String;
  return CommunicatorContentModel.fromJson(json, lang: lang);
}