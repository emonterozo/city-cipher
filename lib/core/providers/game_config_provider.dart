import 'package:flutter_riverpod/legacy.dart';
import '../../models/gameConfig/game_config_model.dart';
import '../../services/api_service.dart';

final gameConfigProvider =
    StateNotifierProvider<GameConfigNotifier, GameConfig?>(
      (ref) => GameConfigNotifier(),
    );

class GameConfigNotifier extends StateNotifier<GameConfig?> {
  GameConfigNotifier() : super(null);

  Future<void> loadConfig() async {
    final ApiService apiService = ApiService();
    final response = await apiService.getGameConfigs();

    state = response.data[0];
  }

  void setConfig(GameConfig config) {
    state = config;
  }

  void updateConfig(GameConfig config) {
    state = config;
  }

  void clear() {
    state = null;
  }
}
