class RegisterResponse {
  final String message;
  final String email;

  RegisterResponse({
    required this.message,
    required this.email,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return RegisterResponse(
      message: json['message'] ?? 'Registration successful',
      email: data['email'] ?? '',
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserData user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return LoginResponse(
      accessToken: data['access'] ?? '',
      refreshToken: data['refresh'] ?? '',
      user: UserData.fromJson(data['user'] ?? {}),
    );
  }
}

class UserData {
  final String id;
  final String email;
  final String fullName;
  final String? role;
  final bool isVerified;
  final bool isProfileCompleted;
  final bool isPro;
  final bool isActive;

  UserData({
    required this.id,
    required this.email,
    this.fullName = '',
    this.role,
    this.isVerified = false,
    this.isProfileCompleted = false,
    this.isPro = false,
    this.isActive = true,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      role: json['role'],
      isVerified: json['is_verified'] ?? json['email_verified'] ?? false,
      isProfileCompleted: json['is_profile_completed'] ?? false,
      isPro: json['is_pro'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_verified': isVerified,
      'is_profile_completed': isProfileCompleted,
      'is_pro': isPro,
      'is_active': isActive,
    };
  }

  // Helper method to get role safely
  String getRoleSafe() {
    if (role == null || role!.isEmpty) {
      return 'unknown';
    }
    return role!.toLowerCase();
  }
}

class VerifyEmailResponse {
  final String message;
  final bool isVerified;
  final String accessToken;
  final String refreshToken;

  VerifyEmailResponse({
    required this.message,
    required this.isVerified,
    this.accessToken = '',
    this.refreshToken = '',
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final data = nested is Map<String, dynamic> ? nested : json;
    return VerifyEmailResponse(
      message: json['message'] ?? 'Email verified successfully',
      isVerified: json['is_verified'] ?? true,
      accessToken: data['access'] ?? '',
      refreshToken: data['refresh'] ?? '',
    );
  }
}

class ForgotPasswordResponse {
  final String message;
  final String email;

  ForgotPasswordResponse({
    required this.message,
    required this.email,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] ?? 'OTP sent successfully',
      email: json['email'] ?? '',
    );
  }
}

class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] ?? 'Password reset successful',
    );
  }
}
