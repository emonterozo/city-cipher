import '../../core/enums/app_enums.dart';

class RankConfig {
  final String id;
  final Rank rank;
  final int minLevel;
  final int maxLevel;
  final int rewardPerLevel;
  final int maxHearts;
  final int heartRegenMins;
  final int hintCost;
  final int adFrequency;
  final int hintPerLevelLimit;

  RankConfig({
    required this.id,
    required this.rank,
    required this.minLevel,
    required this.maxLevel,
    required this.rewardPerLevel,
    required this.maxHearts,
    required this.heartRegenMins,
    required this.hintCost,
    required this.adFrequency,
    required this.hintPerLevelLimit,
  });

  factory RankConfig.fromJson(Map<String, dynamic> json) {
    return RankConfig(
      id: json['_id'] ?? '',
      rank: Rank.fromString(json['rank'] ?? ''),
      minLevel: json['min_level'] ?? 0,
      maxLevel: json['max_level'] ?? 0,
      rewardPerLevel: json['reward_per_level'] ?? 0,
      maxHearts: json['max_hearts'] ?? 0,
      heartRegenMins: json['heart_regen_mins'] ?? 0,
      hintCost: json['hint_cost'] ?? 0,
      adFrequency: json['ad_frequency'] ?? 0,
      hintPerLevelLimit: json['hint_per_level_limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rank': rank.value,
      'min_level': minLevel,
      'max_level': maxLevel,
      'reward_per_level': rewardPerLevel,
      'max_hearts': maxHearts,
      'heart_regen_mins': heartRegenMins,
      'hint_cost': hintCost,
      'ad_frequency': adFrequency,
      'hint_per_level_limit': hintPerLevelLimit,
    };
  }
}

class GlobalSettings {
  final int pointsToPesoRatio;
  final int startingPoints;
  final int totalLevels;

  GlobalSettings({
    required this.pointsToPesoRatio,
    required this.startingPoints,
    required this.totalLevels,
  });

  factory GlobalSettings.fromJson(Map<String, dynamic> json) {
    return GlobalSettings(
      pointsToPesoRatio: json['points_to_peso_ratio'] ?? 0,
      startingPoints: json['starting_points'] ?? 0,
      totalLevels: json['total_levels'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points_to_peso_ratio': pointsToPesoRatio,
      'starting_points': startingPoints,
      'totalLevels': totalLevels,
    };
  }
}

class GameConfig {
  final String id;
  final String configVersion;
  final bool isActive;
  final List<RankConfig> ranks;
  final GlobalSettings globalSettings;

  GameConfig({
    required this.id,
    required this.configVersion,
    required this.isActive,
    required this.ranks,
    required this.globalSettings,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      id: json['_id'] ?? '',
      configVersion: json['config_version'] ?? '',
      isActive: json['is_active'] ?? false,
      ranks: (json['ranks'] as List<dynamic>? ?? [])
          .map((e) => RankConfig.fromJson(e))
          .toList(),
      globalSettings: GlobalSettings.fromJson(json['global_settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'config_version': configVersion,
      'is_active': isActive,
      'ranks': ranks.map((e) => e.toJson()).toList(),
      'global_settings': globalSettings.toJson(),
    };
  }

  RankConfig? getRankByLevel(int level) {
    for (final r in ranks) {
      final max = r.maxLevel == -1 ? double.infinity : r.maxLevel;

      if (level >= r.minLevel && level <= max) {
        return r;
      }
    }
    return null;
  }

  int? getHintCost(Rank rank) {
    for (final r in ranks) {
      if (r.rank == rank) return r.hintCost;
    }
    return null;
  }
}
