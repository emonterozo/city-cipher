import 'package:city_cipher/models/user/game_data_model.dart';

class GameDataResponse {
  final int? statusCode;
  final bool success;
  final String message;
  final GameData? data;

  GameDataResponse({
    this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory GameDataResponse.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return GameDataResponse(
      statusCode: statusCode,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? GameData.fromJson(json['data']) : null,
    );
  }

  factory GameDataResponse.sessionExpired() {
    return GameDataResponse(
      statusCode: 401,
      success: false,
      message: "Session expired",
      data: null,
    );
  }
}
