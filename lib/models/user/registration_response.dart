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
  final int resendCount;
  final int remainingSend;
  final int retryAfter;

  OtpResponse({
    required this.success,
    required this.message,
    required this.resendCount,
    required this.remainingSend,
    required this.retryAfter,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      resendCount: json['resend_count'] ?? '',
      remainingSend: json['remaining_send'] ?? '',
      retryAfter: json['retry_after'] ?? 0,
    );
  }
}

class VerifyOtpResponse {
  final bool success;
  final String message;
  final String id;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.id,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      id: json['id'] ?? '',
    );
  }
}
