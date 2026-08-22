class InvitationModel {
  final int id;
  final String email;
  final String status;
  final String type;
  final String? caregiverName;
  final String? caregiverEmail;
  final String? caregiverAvatar;
  final String? receiverName;
  final String? receiverAvatar;
  final String? createdAt;

  InvitationModel({
    required this.id,
    required this.email,
    required this.status,
    required this.type,
    this.caregiverName,
    this.caregiverAvatar,
    this.caregiverEmail,
    this.receiverName,
    this.receiverAvatar,
    this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'sent',
      caregiverName: json['sender']?['caregiver_name'] ?? json['caregiver_name'],
      caregiverAvatar: json['sender']?['caregiver_avatar'] ?? json['caregiver_avatar'],
      caregiverEmail: json['sender']?['caregiver_email'] ?? json['caregiver_email'],
      receiverName: json['receiver']?['full_name'] ?? json['receiver_name'],
      receiverAvatar: json['receiver']?['avatar'] ?? json['receiver_avatar'],
      createdAt: json['created_at'],
    );
  }
}


class ConnectionModel {
  final int id;
  final int communicatorId;
  final String communicatorName;
  final String? communicatorAvatar;
  final String? profileType;
  final String status;
  final bool isSelected;

  ConnectionModel({
    required this.id,
    required this.communicatorId,
    required this.communicatorName,
    this.communicatorAvatar,
    this.profileType,
    required this.status,
    this.isSelected = false,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {

    final dynamic communicatorField = json['communicator'];
    final bool isNestedObject = communicatorField is Map;
    final bool isIntId = communicatorField is int;

    int commId = 0;
    String commName = '';
    String? commAvatar;
    String? profileType;

    if (isNestedObject) {
      commId = communicatorField['id'] ?? 0;
      commName = communicatorField['full_name'] ?? communicatorField['name'] ?? '';
      commAvatar = communicatorField['avatar'];
      profileType = communicatorField['profile_type'];
    } else {
      commId = json['communicator_id'] ??
          (isIntId ? communicatorField : 0);
      commName = json['communicator_name'] ?? json['full_name'] ?? '';
      commAvatar = json['communicator_avatar'] ?? json['avatar'];
      profileType = json['profile_type'] ?? json['communicator_profile_type'];
    }

    return ConnectionModel(
      id: json['id'] ?? 0,
      communicatorId: commId,
      communicatorName: commName,
      communicatorAvatar: commAvatar,
      profileType: profileType,
      status: json['status'] ?? 'active',
      isSelected: json['is_selected'] ?? false,
    );
  }

  ConnectionModel copyWith({bool? isSelected}) {
    return ConnectionModel(
      id: id,
      communicatorId: communicatorId,
      communicatorName: communicatorName,
      communicatorAvatar: communicatorAvatar,
      profileType: profileType,
      status: status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ConnectionStatsModel {
  final int totalConnections;
  final int pendingInvitations;
  final int acceptedConnections;
  final int rejectedInvitations;

  ConnectionStatsModel({
    required this.totalConnections,
    required this.pendingInvitations,
    required this.acceptedConnections,
    required this.rejectedInvitations,
  });

  factory ConnectionStatsModel.fromJson(Map<String, dynamic> json) {
    return ConnectionStatsModel(
      totalConnections: json['total_connections'] ?? 0,
      pendingInvitations: json['pending_invitations'] ?? 0,
      acceptedConnections: json['accepted_connections'] ?? 0,
      rejectedInvitations: json['rejected_invitations'] ?? 0,
    );
  }
}
