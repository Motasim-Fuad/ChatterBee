import 'dart:io';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:dio/dio.dart';

class CaregiverCustomizationRepository {
  final ApiClient _apiClient = ApiClient();

  // Loads user content in normal mode
  Future<ApiResponse<UserContentModel>> getUserContent(
      int communicatorId, {
        String lang = 'en',
      }) async {
    return _fetchUserContent(
      AppUrl.getCaregiverContent(communicatorId, lang: lang),
      lang: lang,
    );
  }

  // Loads user content in buddy mode
  Future<ApiResponse<UserContentModel>> getUserBuddyModeContent(
      int communicatorId, {
        String lang = 'en',
      }) async {
    return _fetchUserContent(
      AppUrl.getCaregiverBuddyModeContent(communicatorId, lang: lang),
      lang: lang,
    );
  }

  Future<ApiResponse<UserContentModel>> _fetchUserContent(String url,
      {String lang = 'en'}) async {
    try {
      final response = await _apiClient.get(url);
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(
          data: UserContentModel.fromJson(response.data!, lang: lang),
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

  // Create Category
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

  // Update Category
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

  // Create Sub Category
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

  // Update Sub Category
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

  // Create Item
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

  // Update Item
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

  // Create Quick Speak
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

  // Update Quick Speak
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
