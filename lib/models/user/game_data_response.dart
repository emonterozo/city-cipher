import 'package:city_cipher/models/user/game_data_model.dart';

class GameDataResponse {
  final bool success;
  final String message;
  final GameData data;

  GameDataResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GameDataResponse.fromJson(Map<String, dynamic> json) {
    return GameDataResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: GameData.fromJson(json['data'] ?? {}),
    );
  }
}
