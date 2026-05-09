import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/user/game_data_model.dart';
import 'api_service_provider.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameData?>(
  (ref) => GameNotifier(ref),
);

class GameNotifier extends StateNotifier<GameData?> {
  final Ref ref;

  GameNotifier(this.ref) : super(null);

  Future<void> loadGameData() async {
    final apiService = ref.read(apiServiceProvider);

    final response = await apiService.getUserGameData();

    state = response.data;
  }

  void setGame(GameData newState) {
    state = newState;
  }

  Future<void> updateInterstitialAd(int level) async {
    if (state == null) return;

    final newState = state!.copyWith(interstitialAdsShownLevel: level);

    state = newState;

    await ref.read(apiServiceProvider).updateUserGameData({
      "interstitial_ads_shown_level": newState.interstitialAdsShownLevel,
    });
  }

  Future<void> completedLevel(int points) async {
    if (state == null) return;

    final newState = state!.copyWith(
      earnedPoints: state!.earnedPoints + points,
      currentLevel: state!.currentLevel + 1,
      currentLevelWordsFound: [],
      hintedOffsets: [],
      levelHintsUsed: 0,
    );

    state = newState;

    await ref.read(apiServiceProvider).updateUserGameData({
      "earned_points": newState.earnedPoints,
      "current_level": newState.currentLevel,
      "current_level_words_found": [],
      "hinted_cells": [],
      "level_hints_used": 0,
    });
  }

  Future<void> storeLevelPrefilled(List<Offset> offset) async {
    if (state == null) return;

    final newState = state!.copyWith(hintedOffsets: offset);

    state = newState;

    ref.read(apiServiceProvider).updateUserGameData({
      "hinted_cells": offset
          .map((e) => {"x": e.dx.toInt(), "y": e.dy.toInt()})
          .toList(),
    });
  }

  Future<void> useHint(int points, Offset offset) async {
    if (state == null) return;

    final updatedHints = [
      ...state!.hintedOffsets,
      Offset(offset.dx.toInt().toDouble(), offset.dy.toInt().toDouble()),
    ];

    final newState = state!.copyWith(
      earnedPoints: state!.earnedPoints - points,
      hintedOffsets: updatedHints,
      levelHintsUsed: state!.levelHintsUsed + 1,
    );

    state = newState;

    ref.read(apiServiceProvider).updateUserGameData({
      "earned_points": newState.earnedPoints,
      "hinted_cells": updatedHints
          .map((e) => {"x": e.dx.toInt(), "y": e.dy.toInt()})
          .toList(),
      "level_hints_used": newState.levelHintsUsed,
      "is_free_hint": points == 0,
    });
  }

  Future<void> addFoundWord(String word) async {
    if (state == null) return;

    if (state!.currentLevelWordsFound.contains(word)) return;

    final updatedWords = [...state!.currentLevelWordsFound, word];

    final newState = state!.copyWith(currentLevelWordsFound: updatedWords);

    state = newState;

    await ref.read(apiServiceProvider).updateUserGameData({
      "current_level_words_found": updatedWords,
    });
  }

  Future<void> updateHearts(int hearts) async {
    if (state == null) return;

    final newState = state!.copyWith(currentHearts: hearts);

    state = newState;

    await ref.read(apiServiceProvider).updateUserGameData({
      "current_hearts": hearts,
    });
  }

  void clear() {
    state = null;
  }
}
