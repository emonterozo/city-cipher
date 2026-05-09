import 'package:flutter/material.dart';

class GameData {
  final String id;
  final int earnedPoints;
  final int currentLevel;
  final List<String> currentLevelWordsFound;
  final List<Offset> hintedOffsets;
  final int currentHearts;
  final DateTime lastHeartUpdate;
  final int levelHintsUsed;
  final int adBonusUsedCount;
  final int interstitialAdsShownLevel;

  GameData({
    required this.id,
    required this.earnedPoints,
    required this.currentLevel,
    required this.currentLevelWordsFound,
    required this.hintedOffsets,
    required this.currentHearts,
    required this.lastHeartUpdate,
    required this.levelHintsUsed,
    required this.adBonusUsedCount,
    required this.interstitialAdsShownLevel,
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
      hintedOffsets: (json['hinted_cells'] as List<dynamic>? ?? [])
          .map(
            (e) => Offset((e['x'] ?? 0).toDouble(), (e['y'] ?? 0).toDouble()),
          )
          .toList(),
      currentHearts: json['current_hearts'] ?? 0,
      lastHeartUpdate:
          DateTime.tryParse(json['last_heart_update'] ?? '') ?? DateTime.now(),
      levelHintsUsed: json['level_hints_used'] ?? 0,
      adBonusUsedCount: json['ad_bonus_used_count'] ?? 0,
      interstitialAdsShownLevel: json['interstitial_ads_shown_level'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'earned_points': earnedPoints,
      'current_level': currentLevel,
      'current_level_words_found': currentLevelWordsFound,
      'hinted_cells': hintedOffsets.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      'current_hearts': currentHearts,
      'last_heart_update': lastHeartUpdate.toIso8601String(),
      'level_hints_used': levelHintsUsed,
      'ad_bonus_used_count': adBonusUsedCount,
      'interstitial_ads_shown_level': interstitialAdsShownLevel,
    };
  }

  GameData copyWith({
    String? id,
    int? earnedPoints,
    int? currentLevel,
    List<String>? currentLevelWordsFound,
    List<Offset>? hintedOffsets,
    int? currentHearts,
    DateTime? lastHeartUpdate,
    int? levelHintsUsed,
    int? dailyLevelsPlayed,
    int? adBonusUsedCount,
    DateTime? lastDailyReset,
    int? interstitialAdsShownLevel,
  }) {
    return GameData(
      id: id ?? this.id,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelWordsFound:
          currentLevelWordsFound ?? this.currentLevelWordsFound,
      hintedOffsets: hintedOffsets ?? this.hintedOffsets,
      currentHearts: currentHearts ?? this.currentHearts,
      lastHeartUpdate: lastHeartUpdate ?? this.lastHeartUpdate,
      levelHintsUsed: levelHintsUsed ?? this.levelHintsUsed,
      adBonusUsedCount: adBonusUsedCount ?? this.adBonusUsedCount,
      interstitialAdsShownLevel:
          interstitialAdsShownLevel ?? this.interstitialAdsShownLevel,
    );
  }
}
