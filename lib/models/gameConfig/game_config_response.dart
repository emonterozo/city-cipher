import 'game_config_model.dart';

class GameConfigResponse {
  final bool success;
  final List<GameConfig> data;

  GameConfigResponse({required this.success, required this.data});

  factory GameConfigResponse.fromJson(Map<String, dynamic> json) {
    return GameConfigResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((e) => GameConfig.fromJson(e))
          .toList(),
    );
  }
}
