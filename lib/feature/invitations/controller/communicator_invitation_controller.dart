import 'package:chatter_bee/Repository/profile_invitation_repo.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

class CommunicatorInvitationController extends GetxController {
  final ProfileInvitationRepo _repo = ProfileInvitationRepo();

  final RxBool isLoading = false.obs;
  final RxList<InvitationModel> receivedInvitations = <InvitationModel>[].obs;
  final RxSet<int> processingIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadReceivedInvitations();
  }

  Future<void> loadReceivedInvitations() async {
    try {
      isLoading.value = true;
      final response = await _repo.listInvitations(
          type: 'received', status: 'pending');

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        List<dynamic> rawList = [];

        if (responseData['data'] is Map) {
          rawList = (responseData['data'] as Map)['invitations'] ??
              (responseData['data'] as Map)['results'] ?? [];
        } else if (responseData['data'] is List) {
          rawList = responseData['data'];
        } else if (responseData['invitations'] is List) {
          rawList = responseData['invitations'];
        } else if (responseData['results'] is List) {
          rawList = responseData['results'];
        }

        receivedInvitations.value = rawList
            .map((e) =>
            InvitationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Load received invitations error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInvitation(InvitationModel invitation) async {
    if (processingIds.contains(invitation.id)) return;
    try {
      processingIds.add(invitation.id);
      processingIds.refresh();

      final response =
      await _repo.acceptInvitation(invitationId: invitation.id);
      if (response.isSuccess) {
        receivedInvitations.removeWhere((inv) => inv.id == invitation.id);
        AppToast.success('${'now_connected_with'.tr} ${invitation.caregiverName ?? 'the caregiver'}');
      } else {
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          errorMsg = firstError is List
              ? firstError.first.toString()
              : firstError.toString();
        }
        AppToast.error(errorMsg);
      }
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      AppToast.error('failed_accept'.tr);
    } finally {
      processingIds.remove(invitation.id);
      processingIds.refresh();
    }
  }

  Future<void> rejectInvitation(InvitationModel invitation) async {
    if (processingIds.contains(invitation.id)) return;
    try {
      processingIds.add(invitation.id);
      processingIds.refresh();

      final response =
      await _repo.rejectInvitation(invitationId: invitation.id);
      if (response.isSuccess) {
        receivedInvitations.removeWhere((inv) => inv.id == invitation.id);
        AppToast.show('invitation_declined'.tr);
      } else {
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          errorMsg = firstError is List
              ? firstError.first.toString()
              : firstError.toString();
        }
        AppToast.error(errorMsg);
      }
    } catch (e) {
      debugPrint('Reject invitation error: $e');
      AppToast.error('failed_decline'.tr);
    } finally {
      processingIds.remove(invitation.id);
      processingIds.refresh();
    }
  }

  bool isProcessing(int id) => processingIds.contains(id);
}
