import 'dart:io';
import 'package:chatter_bee/models/activity/activity_models.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../config/app_url.dart';

class ActivityRepository {
  final ApiClient _apiClient = ApiClient();

  Future<int?> _activityCommunicatorId() async {
    if (!Get.isRegistered<CommunicatorSessionService>()) return null;
    return CommunicatorSessionService.to.resolveActivityCommunicatorId();
  }

  // List Activities
  Future<ApiResponse<List<ActivityModel>>> getActivities({
    int days = 30,
    int limit = 100,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? ordering,
  }) async {
    try {
      final communicatorId = await _activityCommunicatorId();
      final queryParams = <String, dynamic>{
        'days': days,
        'limit': limit,
        if (status != null) 'status': status,
        if (dateFrom != null) 'from': dateFrom,
        if (dateTo != null) 'to': dateTo,
        if (ordering != null) 'ordering': ordering,
        if (communicatorId != null) 'communicator_id': communicatorId,
      };

      final response = await _apiClient.get<dynamic>(
        AppUrl.activities,
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> rawList = data['data'] ?? [];
        return ApiResponse.success(
          data: rawList
              .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          statusCode: response.statusCode,
          message: response.message,
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to fetch activities: $e',
      );
    }
  }

  // Create Activity
  Future<ApiResponse<ActivityModel>> createActivity({
    required String activityName,
    required String datetime,
    File? imageFile,
    String status = 'in_progress',
  }) async {
    try {
      final communicatorId = await _activityCommunicatorId();
      final formData = FormData.fromMap({
        'activity_name': activityName,
        'datetime': datetime,
        'status': status,
        if (communicatorId != null) 'communicator_id': communicatorId,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _apiClient.multipartPost<dynamic>(
        AppUrl.activitiesCreate,
        formData: formData,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse.success(
          data: ActivityModel.fromJson(
              data['data'] as Map<String, dynamic>),
          statusCode: response.statusCode,
          message: response.message,
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to create activity: $e',
      );
    }
  }

  // Update Activity (PATCH)
  Future<ApiResponse<ActivityModel>> updateActivity({
    required int activityId,
    String? activityName,
    String? datetime,
    String? status,
    File? imageFile,
  }) async {
    try {
      final map = <String, dynamic>{};
      final communicatorId = await _activityCommunicatorId();
      if (communicatorId != null) map['communicator_id'] = communicatorId;
      if (activityName != null) map['activity_name'] = activityName;
      if (datetime != null) map['datetime'] = datetime;
      if (status != null) map['status'] = status;
      if (imageFile != null) {
        map['image_icon'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _apiClient.multipartPut<dynamic>(
        AppUrl.activityUpdate(activityId),
        formData: formData,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse.success(
          data: ActivityModel.fromJson(
              (data['data'] ?? data) as Map<String, dynamic>),
          statusCode: response.statusCode,
          message: response.message,
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to update activity: $e',
      );
    }
  }

  // Delete Activity
  Future<ApiResponse<bool>> deleteActivity(int activityId) async {
    try {
      final response = await _apiClient.delete<dynamic>(
        AppUrl.activityDelete(activityId),
      );

      if (response.statusCode == 204 || response.isSuccess) {
        return ApiResponse.success(
          data: true,
          statusCode: response.statusCode,
          message: 'Activity deleted successfully',
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to delete activity: $e',
      );
    }
  }
}
