import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/invitations/controller/communicator_invitation_controller.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunicatorInvitationsScreen
    extends GetView<CommunicatorInvitationController> {
  const CommunicatorInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back)),
        title: Text('invitations'.tr,
            style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadReceivedInvitations,
          child: controller.receivedInvitations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.receivedInvitations.length,
            itemBuilder: (context, index) {
              final invitation =
              controller.receivedInvitations[index];
              return _InvitationCard(
                  invitation: invitation,
                  controller: controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC857).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mail_outline_rounded,
                size: 48, color: Color(0xFFFFC857)),
          ),
          const SizedBox(height: 20),
          Text('no_pending_invitations'.tr,
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Text('no_pending_desc'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 14, color: const Color(0xFF636F85))),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final CommunicatorInvitationController controller;

  const _InvitationCard(
      {required this.invitation, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFF3CC),
                backgroundImage: invitation.caregiverAvatar != null &&
                    invitation.caregiverAvatar!.isNotEmpty
                    ? NetworkImage(
                    "${AppUrl.baseUrl}${invitation.caregiverAvatar}")
                    : null,
                child: invitation.caregiverAvatar == null ||
                    invitation.caregiverAvatar!.isEmpty
                    ? Text(
                    invitation.caregiverName?.isNotEmpty == true
                        ? invitation.caregiverName![0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFC857)))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invitation.caregiverName ?? 'caregiver'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    Text(invitation.caregiverEmail ?? '',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF636F85))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('pending'.tr,
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB8860B))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          Text('wants_to_connect'.tr,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: const Color(0xFF636F85))),
          const SizedBox(height: 16),

          Obx(() {
            final isProcessing = controller.isProcessing(invitation.id);
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing
                        ? null
                        : () =>
                        controller.rejectInvitation(invitation),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('decline'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () =>
                        controller.acceptInvitation(invitation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white))
                        : Text('accept'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
