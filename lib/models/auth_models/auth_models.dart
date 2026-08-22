class RegisterResponse {
  final String message;
  final String? email;
  final String? userId;

  RegisterResponse({
    required this.message,
    this.email,
    this.userId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? 'Registration successful',
      email: json['email'],
      userId: json['user_id']?.toString() ?? json['id']?.toString(),
    );
  }
}


class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserData user;
  final String message;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access'] ?? json['access_token'] ?? '',
      refreshToken: json['refresh'] ?? json['refresh_token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
      message: json['message'] ?? 'Login successful',
    );
  }
}


class UserData {
  final String id;
  final String email;
  final String fullName;
  final String? role;
  final String? avatar;
  final bool? isVerified;

  UserData({
    required this.id,
    required this.email,
    required this.fullName,
    this.role,
    this.avatar,
    this.isVerified,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'avatar': avatar,
      'is_verified': isVerified,
    };
  }
}
