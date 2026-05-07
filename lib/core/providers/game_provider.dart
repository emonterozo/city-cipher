import 'package:flutter_riverpod/legacy.dart';

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
  (ref) => GameNotifier(),
);

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(const GameState());

  void setGame(GameState newState) {
    state = newState;
  }

  void addPoints(int points) {
    state = state.copyWith(earnedPoints: state.earnedPoints + points);
  }

  void setLevel(int level) {
    state = state.copyWith(currentLevel: level);
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
