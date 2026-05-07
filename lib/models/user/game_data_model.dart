class GameData {
  final String id;
  final int earnedPoints;
  final int currentLevel;
  final List<String> currentLevelWordsFound;
  final int currentHearts;
  final String lastActivityDate;
  final int dailyAdsWatched;
  final int levelsCompletedToday;
  final DateTime lastHeartUpdate;

  GameData({
    required this.id,
    required this.earnedPoints,
    required this.currentLevel,
    required this.currentLevelWordsFound,
    required this.currentHearts,
    required this.lastActivityDate,
    required this.dailyAdsWatched,
    required this.levelsCompletedToday,
    required this.lastHeartUpdate,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      id: json['_id'] ?? '',
      earnedPoints: json['earned_points'] ?? 0,
      currentLevel: json['current_level'] ?? 0,
      currentLevelWordsFound:
          (json['current_level_words_found'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      currentHearts: json['current_hearts'] ?? 0,
      lastActivityDate: json['last_activity_date'] ?? '',
      dailyAdsWatched: json['daily_ads_watched'] ?? 0,
      levelsCompletedToday: json['levels_completed_today'] ?? 0,
      lastHeartUpdate:
          DateTime.tryParse(json['last_heart_update'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'earned_points': earnedPoints,
      'current_level': currentLevel,
      'current_level_words_found': currentLevelWordsFound,
      'current_hearts': currentHearts,
      'last_activity_date': lastActivityDate,
      'daily_ads_watched': dailyAdsWatched,
      'levels_completed_today': levelsCompletedToday,
      'last_heart_update': lastHeartUpdate.toIso8601String(),
    };
  }
}
