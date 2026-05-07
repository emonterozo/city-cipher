import 'game_level_model.dart';

class GameLevelResponse {
  final bool success;
  final List<GameLevel> data;

  GameLevelResponse({required this.success, required this.data});

  factory GameLevelResponse.fromJson(Map<String, dynamic> json) {
    return GameLevelResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((e) => GameLevel.fromJson(e))
          .toList(),
    );
  }
}
