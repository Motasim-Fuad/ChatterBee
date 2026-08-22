import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:flutter/material.dart';

class CommunicatorRepository {
  final ApiClient _client = ApiClient();

  // Get Content
  Future<ApiResponse<CommunicatorContentModel>> getContent(
      {String lang = 'en'}) async {
    return _fetchContent(AppUrl.getCommunicatorContent(lang: lang), lang: lang);
  }

  // Get Buddy Mode Content
  Future<ApiResponse<CommunicatorContentModel>> getBuddyModeContent(
      {String lang = 'en'}) async {
    return _fetchContent(AppUrl.getCommunicatorBuddyModeContent(lang: lang),
        lang: lang);
  }

  // Records that an item or quick speak was pressed
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

  // Shared fetch logic
  Future<ApiResponse<CommunicatorContentModel>> _fetchContent(String url,
      {String lang = 'en'}) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(url);

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;

        final rawData = body['data'] ?? body;
        if (rawData is Map && body['success'] != false) {
          final model = CommunicatorContentModel.fromJson(
            Map<String, dynamic>.from(rawData),
            lang: lang,
          );
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
