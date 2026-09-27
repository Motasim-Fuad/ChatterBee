import 'dart:async';
import 'dart:convert';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/foundation.dart';

class CommunicatorRepository {
  final ApiClient _client = ApiClient();

  String _cacheKey(String lang, bool buddyMode) =>
      'comm_content_cache_${lang}_${buddyMode ? 'buddy' : 'normal'}';

  /// Instantly returns the last-cached content (if any) without touching
  /// the network. Call this first so the UI can paint immediately, then
  /// call [getContent] / [getBuddyModeContent] in the background to
  /// refresh with the latest data.
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
    } catch (_) {
      // A failed cache write should never break the actual data flow.
    }
  }

  // Get Content
  Future<ApiResponse<CommunicatorContentModel>> getContent(
      {String lang = 'en'}) async {
    return _fetchContent(AppUrl.getCommunicatorContent(lang: lang),
        buddyMode: false, lang: lang);
  }

  // Get Buddy Mode Content
  Future<ApiResponse<CommunicatorContentModel>> getBuddyModeContent(
      {String lang = 'en'}) async {
    return _fetchContent(AppUrl.getCommunicatorBuddyModeContent(lang: lang),
        buddyMode: true, lang: lang);
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

          // NOTE: this response currently carries every category, every
          // sub-category and every item (thousands of records) in one
          // payload. Decoding/mapping that on the main isolate is what
          // causes the loading freeze, so we push it to a background
          // isolate with `compute`. This is a mitigation — the real fix
          // is a lighter/paginated backend endpoint.
          final model = await compute(
            _parseCommunicatorContentIsolate,
            {'json': rawJson, 'lang': lang},
          );

          // Cache the raw JSON (fire-and-forget) so the next app open
          // can paint instantly from disk.
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

/// Top-level function so it can run inside a background isolate via
/// [compute]. Must stay top-level (or static) — instance methods can't
/// be sent across isolates.
CommunicatorContentModel _parseCommunicatorContentIsolate(
    Map<String, dynamic> args) {
  final json = args['json'] as Map<String, dynamic>;
  final lang = args['lang'] as String;
  return CommunicatorContentModel.fromJson(json, lang: lang);
}