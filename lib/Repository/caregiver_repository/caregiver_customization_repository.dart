import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CaregiverCustomizationRepository {
  final ApiClient _apiClient = ApiClient();

  
  Future<ApiResponse<CategoryListResponse>> getCategoriesLite(
      int communicatorId, {
        required bool buddyMode,
        String lang = 'en',
      }) async {
    try {
      final response = await _apiClient.get(
        '/api/caregiver/categories/',
        queryParameters: {
          'communicator_id': communicatorId.toString(),
          'lang': lang,
          'buddy_mode': buddyMode.toString(),
        },
      );
      if (response.isSuccess && response.data != null) {
        final raw = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        return ApiResponse.success(
          data: CategoryListResponse.fromJson(raw, lang: lang),
          statusCode: 200,
          message: 'Success',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode ?? 500,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<CategoryItemsResponse>> getCategoryItems(
      int categoryId, {
        required int communicatorId,
        String lang = 'en',
      }) async {
    try {
      final response = await _apiClient.get(
        '/api/caregiver/categories/$categoryId/items/',
        queryParameters: {
          'communicator_id': communicatorId.toString(),
          'lang': lang,
        },
      );
      if (response.isSuccess && response.data != null) {
        final raw = Map<String, dynamic>.from(response.data as Map);
        return ApiResponse.success(
          data: CategoryItemsResponse.fromJson(raw, lang: lang),
          statusCode: 200,
          message: 'Success',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode ?? 500,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<SubCategoryItemsResponse>> getSubCategoryItems(
      int subCategoryId, {
        required int communicatorId,
        String lang = 'en',
      }) async {
    try {
      final response = await _apiClient.get(
        '/api/caregiver/sub-categories/$subCategoryId/items/',
        queryParameters: {
          'communicator_id': communicatorId.toString(),
          'lang': lang,
        },
      );
      if (response.isSuccess && response.data != null) {
        final raw = Map<String, dynamic>.from(response.data as Map);
        return ApiResponse.success(
          data: SubCategoryItemsResponse.fromJson(raw, lang: lang),
          statusCode: 200,
          message: 'Success',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode ?? 500,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<SearchResponse>> search(
      String query, {
        required int communicatorId,
        String lang = 'en',
      }) async {
    try {
      final response = await _apiClient.get(
        '/api/caregiver/search/',
        queryParameters: {
          'q': query,
          'communicator_id': communicatorId.toString(),
          'lang': lang,
        },
      );
      if (response.isSuccess && response.data != null) {
        final raw = Map<String, dynamic>.from(response.data as Map);
        return ApiResponse.success(
          data: SearchResponse.fromJson(raw, lang: lang),
          statusCode: 200,
          message: 'Success',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode ?? 500,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  String _cacheKey(int communicatorId, String lang, bool buddyMode) =>
      'cg_content_cache_${communicatorId}_${lang}_${buddyMode ? 'buddy' : 'normal'}';

  Future<UserContentModel?> getCachedUserContent(
      int communicatorId, {
        required bool buddyMode,
        String lang = 'en',
      }) async {
    try {
      final raw =
      StorageService().getString(_cacheKey(communicatorId, lang, buddyMode));
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return await compute(
        _parseUserContentIsolate,
        {'json': json, 'lang': lang},
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(
      int communicatorId,
      String lang,
      bool buddyMode,
      Map<String, dynamic> rawJson,
      ) async {
    try {
      await StorageService().setString(
        _cacheKey(communicatorId, lang, buddyMode),
        jsonEncode(rawJson),
      );
    } catch (_) {}
  }

  Future<ApiResponse<UserContentModel>> getUserContent(
      int communicatorId, {
        String lang = 'en',
      }) async {
    return _fetchUserContent(
      AppUrl.getCaregiverContent(communicatorId, lang: lang),
      communicatorId: communicatorId,
      buddyMode: false,
      lang: lang,
    );
  }

  Future<ApiResponse<UserContentModel>> getUserBuddyModeContent(
      int communicatorId, {
        String lang = 'en',
      }) async {
    return _fetchUserContent(
      AppUrl.getCaregiverBuddyModeContent(communicatorId, lang: lang),
      communicatorId: communicatorId,
      buddyMode: true,
      lang: lang,
    );
  }

  Future<ApiResponse<UserContentModel>> _fetchUserContent(
      String url, {
        required int communicatorId,
        required bool buddyMode,
        String lang = 'en',
      }) async {
    try {
      final response = await _apiClient.get(url);
      if (response.isSuccess && response.data != null) {
        final rawJson = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};

        final model = await compute(
          _parseUserContentIsolate,
          {'json': rawJson, 'lang': lang},
        );

        unawaited(_saveToCache(communicatorId, lang, buddyMode, rawJson));

        return ApiResponse.success(
          data: model,
          statusCode: 200,
          message: 'Success',
        );
      }
      return ApiResponse.error(
        statusCode: response.statusCode ?? 500,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> createCategory({
    required String name,
    required String color,
    required int communicatorId,
    required int order,
    File? imageFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        'communicator_id': communicatorId.toString(),
        'order': order.toString(),
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      return await _apiClient.multipartPost(AppUrl.createCategory,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> updateCategory({
    required int categoryId,
    required String name,
    required String color,
    File? imageFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      return await _apiClient.multipartPut(
          AppUrl.updateUserCategory(categoryId), formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> createSubCategory({
    required String name,
    required String color,
    required int order,
    required int communicatorId,
    required int mainCategoryId,
    File? imageFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        'order': order.toString(),
        'communicator_id': communicatorId.toString(),
        'main_category_id': mainCategoryId.toString(),
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      return await _apiClient.multipartPost(AppUrl.createSubCategory,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> updateSubCategory({
    required int subCategoryId,
    required String name,
    required String color,
    File? imageFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      return await _apiClient.multipartPut(
          AppUrl.updateUserSubCategory(subCategoryId), formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> createItem({
    required int categoryId,
    required String word,
    required String color,
    required int communicatorId,
    File? imageFile,
    File? audioFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'category_id': categoryId.toString(),
        'word': word,
        'color': color,
        'communicator_id': communicatorId.toString(),
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.aac',
              contentType: DioMediaType('audio', 'aac')),
      });
      return await _apiClient.multipartPost(AppUrl.createItem,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> updateItem({
    required int itemId,
    required String word,
    required String color,
    File? imageFile,
    File? audioFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'word': word,
        'color': color,
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.aac',
              contentType: DioMediaType('audio', 'aac')),
      });
      return await _apiClient.multipartPut(AppUrl.updateUserItem(itemId),
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> createQuickSpeak({
    required String word,
    required String color,
    required int communicatorId,
    File? imageFile,
    File? audioFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'word': word,
        'color': color,
        'communicator_id': communicatorId.toString(),
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.aac',
              contentType: DioMediaType('audio', 'aac')),
      });
      return await _apiClient.multipartPost(AppUrl.createQuickSpeak,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  
  Future<ApiResponse<dynamic>> updateQuickSpeak({
    required int quickSpeakId,
    required String word,
    required String color,
    File? imageFile,
    File? audioFile,
    String lang = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'word': word,
        'color': color,
        'lang': lang,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.aac',
              contentType: DioMediaType('audio', 'aac')),
      });
      return await _apiClient.multipartPut(
          AppUrl.updateUserQuickSpeak(quickSpeakId), formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }
}


UserContentModel _parseUserContentIsolate(Map<String, dynamic> args) {
  final json = args['json'] as Map<String, dynamic>;
  final lang = args['lang'] as String;
  return UserContentModel.fromJson(json, lang: lang);
}