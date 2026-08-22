import 'package:chatter_bee/Repository/profile_invitation_repo.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        Get.snackbar(
          'connected_title'.tr,
          '${'now_connected_with'.tr} ${invitation.caregiverName ?? 'the caregiver'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
          duration: const Duration(seconds: 3),
        );
      } else {
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          errorMsg = firstError is List
              ? firstError.first.toString()
              : firstError.toString();
        }
        Get.snackbar('error'.tr, errorMsg,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      Get.snackbar('error'.tr, 'failed_accept'.tr,
          snackPosition: SnackPosition.BOTTOM);
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
        Get.snackbar(
          'declined'.tr, 'invitation_declined'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          errorMsg = firstError is List
              ? firstError.first.toString()
              : firstError.toString();
        }
        Get.snackbar('error'.tr, errorMsg,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('Reject invitation error: $e');
      Get.snackbar('error'.tr, 'failed_decline'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      processingIds.remove(invitation.id);
      processingIds.refresh();
    }
  }

  bool isProcessing(int id) => processingIds.contains(id);
}
