import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'api_service_provider.dart';

class GameState {
  final int earnedPoints;
  final int currentLevel;
  final List<String> currentLevelWordsFound;
  final int currentHearts;
  final DateTime? lastHeartUpdate;
  final String lastActivityDate;
  final int dailyAdsWatched;
  final int levelsCompletedToday;

  const GameState({
    this.earnedPoints = 0,
    this.currentLevel = 1,
    this.currentLevelWordsFound = const [],
    this.currentHearts = 5,
    this.lastHeartUpdate,
    this.lastActivityDate = "",
    this.dailyAdsWatched = 0,
    this.levelsCompletedToday = 0,
  });

  GameState copyWith({
    int? earnedPoints,
    int? currentLevel,
    List<String>? currentLevelWordsFound,
    int? currentHearts,
    DateTime? lastHeartUpdate,
    String? lastActivityDate,
    int? dailyAdsWatched,
    int? levelsCompletedToday,
  }) {
    return GameState(
      earnedPoints: earnedPoints ?? this.earnedPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelWordsFound:
          currentLevelWordsFound ?? this.currentLevelWordsFound,
      currentHearts: currentHearts ?? this.currentHearts,
      lastHeartUpdate: lastHeartUpdate ?? this.lastHeartUpdate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      dailyAdsWatched: dailyAdsWatched ?? this.dailyAdsWatched,
      levelsCompletedToday: levelsCompletedToday ?? this.levelsCompletedToday,
    );
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(ref),
);

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;
  GameNotifier(this.ref) : super(const GameState());

  Future<void> loadGameData() async {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getUserGameData();

    state = GameState(
      earnedPoints: response.data.earnedPoints,
      currentLevel: response.data.currentLevel,
      currentLevelWordsFound: response.data.currentLevelWordsFound,
      currentHearts: response.data.currentHearts,
      lastHeartUpdate: response.data.lastHeartUpdate,
      lastActivityDate: response.data.lastActivityDate,
      dailyAdsWatched: response.data.dailyAdsWatched,
      levelsCompletedToday: response.data.levelsCompletedToday,
    );
  }

  void setGame(GameState newState) {
    state = newState;
  }

  void addPoints(int points) {
    state = state.copyWith(earnedPoints: state.earnedPoints + points);
  }

  void deductPoints(int points) {
    state = state.copyWith(earnedPoints: state.earnedPoints - points);
  }

  void increaseLevel() {
    state = state.copyWith(currentLevel: state.currentLevel + 1);
  }

  void addFoundWord(String word) {
    state = state.copyWith(
      currentLevelWordsFound: [...state.currentLevelWordsFound, word],
    );
  }

  void updateHearts(int hearts) {
    state = state.copyWith(currentHearts: hearts);
  }

  void resetLevelProgress() {
    state = state.copyWith(currentLevelWordsFound: []);
  }

  void clear() {
    state = const GameState();
  }
}
