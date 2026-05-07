import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/gameConfig/game_config_model.dart';
import 'api_service_provider.dart';

final gameConfigProvider =
    StateNotifierProvider<GameConfigNotifier, GameConfig?>((ref) {
      return GameConfigNotifier(ref);
    });

class GameConfigNotifier extends StateNotifier<GameConfig?> {
  final Ref ref;

  GameConfigNotifier(this.ref) : super(null);

  Future<void> loadConfig() async {
    final apiService = ref.read(apiServiceProvider);
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
