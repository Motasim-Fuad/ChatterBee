import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/services/api_client.dart';

class ProfileInvitationRepo {
  final ApiClient _apiClient = ApiClient();

  
  Future<ApiResponse<Map<String, dynamic>>> sendInvitation({
    required String email,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      AppUrl.sendInvitation,
      data: {'email': email},
    );
  }

  
  Future<ApiResponse<Map<String, dynamic>>> acceptInvitation({
    required int invitationId,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      AppUrl.acceptInvitation,
      data: {'invitation_id': invitationId},
    );
  }

  
  Future<ApiResponse<Map<String, dynamic>>> rejectInvitation({
    required int invitationId,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      AppUrl.rejectInvitation,
      data: {'invitation_id': invitationId},
    );
  }

  
  Future<ApiResponse<Map<String, dynamic>>> listInvitations({
    String type = 'all',
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {'type': type};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    return await _apiClient.get<Map<String, dynamic>>(
      AppUrl.listInvitations,
      queryParameters: queryParams,
    );
  }

  
  Future<ApiResponse<Map<String, dynamic>>> listConnections() async {
    return await _apiClient.get<Map<String, dynamic>>(AppUrl.listConnections);
  }

  
  Future<ApiResponse<Map<String, dynamic>>> disconnectProfile({
    required int connectionId,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      AppUrl.disconnectProfile,
      data: {'connection_id': connectionId},
    );
  }

  
  Future<ApiResponse<Map<String, dynamic>>> getConnectionStats() async {
    return await _apiClient.get<Map<String, dynamic>>(AppUrl.connectionStats);
  }

  
  Future<ApiResponse<Map<String, dynamic>>> copyDefaultContent({
    required int targetUserId,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      AppUrl.copyDefaultContent,
      data: {'target_user_id': targetUserId},
    );
  }
}
