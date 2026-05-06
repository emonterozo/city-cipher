class RegistrationResponse {
  final bool success;
  final String message;
  final String userId;
  final int retryAfter;

  RegistrationResponse({
    required this.success,
    required this.message,
    required this.userId,
    required this.retryAfter,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'] ?? '',
      retryAfter: json['retry_after'] ?? 0,
    );
  }
}

class OtpResponse {
  final bool success;
  final String message;
  final String id;
  final bool isLocked;
  final int resendCount;
  final int remainingSend;
  final int retryAfter;

  OtpResponse({
    required this.success,
    required this.message,
    required this.isLocked,
    required this.id,
    required this.resendCount,
    required this.remainingSend,
    required this.retryAfter,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isLocked: json['is_locked'] ?? false,
      id: json['id'] ?? '',
      resendCount: json['resend_count'] ?? 0,
      remainingSend: json['remaining_send'] ?? 0,
      retryAfter: json['retry_after'] ?? 0,
    );
  }
}

class VerifyOtpResponse {
  final bool success;
  final String message;
  final String id;
  final String accessToken;
  final String refreshToken;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.id,
    required this.accessToken,
    required this.refreshToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      id: json['id'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final bool isLocked;
  final String? id;
  final String? accessToken;
  final String? refreshToken;
  final int? resendCount;
  final int? remainingSend;
  final int? retryAfter;

  LoginResponse({
    required this.success,
    required this.message,
    required this.isLocked,
    this.id,
    this.accessToken,
    this.refreshToken,
    this.resendCount,
    this.remainingSend,
    this.retryAfter,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isLocked: json['is_locked'] ?? false,
      id: json['id'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      resendCount: json['resend_count'],
      remainingSend: json['remaining_send'],
      retryAfter: json['retry_after'],
    );
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({required this.success, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
