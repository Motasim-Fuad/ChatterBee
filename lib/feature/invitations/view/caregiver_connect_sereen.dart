import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/invitations/controller/caregiver_invitation_controller.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverConnectionsScreen extends GetView<CaregiverInvitationController> {
  const CaregiverConnectionsScreen({super.key});

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
        title: Text('my_communicators'.tr,
            style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          GestureDetector(
            onTap: controller.showInviteDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Text('invite'.tr,
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingConnections.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadConnections,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBanner(),
                const SizedBox(height: 24),

                if (controller.connections.isEmpty)
                  _buildEmptyState()
                else ...[
                  Text('connected_profiles'.tr,
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text('tap_to_switch'.tr,
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF636F85))),
                  const SizedBox(height: 16),
                  ...controller.connections.map((connection) =>
                      _CommunicatorCard(
                          connection: connection,
                          controller: controller)),
                ],

                if (controller.sentInvitations.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('pending_invitations'.tr,
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  const SizedBox(height: 12),
                  ...controller.sentInvitations.map(
                          (inv) => _PendingInvitationCard(invitation: inv)),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E6), Color(0xFFFFF3CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
        Border.all(color: const Color(0xFFFFC857).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC857).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link_rounded,
                color: Color(0xFFFFC857), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('select_active_communicator'.tr,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                Text('tap_profile_below'.tr,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF636F85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC857).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline,
                  size: 48, color: Color(0xFFFFC857)),
            ),
            const SizedBox(height: 20),
            Text('no_communicators_yet'.tr,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Text('invite_communicator_desc'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: const Color(0xFF636F85))),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: Get.find<CaregiverInvitationController>()
                  .showInviteDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC857),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text('send_invitation'.tr,
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunicatorCard extends StatelessWidget {
  final ConnectionModel connection;
  final CaregiverInvitationController controller;

  const _CommunicatorCard(
      {required this.connection, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected =
          controller.selectedConnectionId.value == connection.id;
      final isSwitching =
          controller.isSwitchingTo.value == connection.id;
      final borderColor =
      isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!;
      final bgColor =
      isSelected ? const Color(0xFFF0FFF0) : Colors.white;
      final avatarBorderColor =
      isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!;

      return GestureDetector(
        onTap: isSwitching
            ? null
            : () => controller.selectCommunicator(connection),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: borderColor, width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.12)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: avatarBorderColor, width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: connection.communicatorAvatar !=
                      null &&
                      connection.communicatorAvatar!.isNotEmpty
                      ? CachedNetworkImageProvider(
                      "${AppUrl.baseUrl}${connection.communicatorAvatar}")
                      : null,
                  child: connection.communicatorAvatar == null ||
                      connection.communicatorAvatar!.isEmpty
                      ? Text(
                      connection.communicatorName.isNotEmpty
                          ? connection.communicatorName[0]
                          .toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[500]))
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(connection.communicatorName,
                        style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4CAF50).withOpacity(0.12)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        connection.profileType != null
                            ? (connection.profileType![0].toUpperCase() +
                            connection.profileType!.substring(1))
                            : 'communicator'.tr,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),

              if (isSwitching)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4CAF50)))
              else if (isSelected)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('active'.tr,
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _disconnectButton(context),
                  ],
                )
              else
                _disconnectButton(context),
            ],
          ),
        ),
      );
    });
  }

  Widget _disconnectButton(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.disconnectCommunicator(connection),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.link_off_rounded,
            size: 16, color: Colors.red),
      ),
    );
  }
}

class _PendingInvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  const _PendingInvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3CC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule,
                size: 18, color: Color(0xFFFFC857)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invitation.email,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                Text('invitation_pending'.tr,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.grey[500])),
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
    );
  }
}
