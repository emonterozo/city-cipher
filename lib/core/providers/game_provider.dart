import 'package:city_cipher/models/user/game_data_response.dart';
import 'package:city_cipher/services/api_service.dart';
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

  Future<GameDataResponse> loadGameData() async {
    final apiService = ref.read(apiServiceProvider);

    final response = await apiService.getUserGameData();

    if (response.statusCode == 401) {
      return GameDataResponse.sessionExpired();
    }

    if (response.success) {
      state = response.data;
      return response;
    } else {
      state = null;
      return GameDataResponse(success: false, message: "Something went wrong");
    }
  }

  void setGame(GameData newState) {
    state = newState;
  }

  Future<ApiResponse> _retryUpdate(Map<String, dynamic> data) async {
    const maxRetries = 5;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await ref
            .read(apiServiceProvider)
            .updateUserGameData(data);

        if (response.statusCode == 401) {
          return response;
        }

        if (response.success) {
          return response;
        }

        if (attempt == maxRetries - 1) {
          return response;
        }
      } catch (e) {
        if (attempt == maxRetries - 1) {
          return ApiResponse(success: false, message: e.toString());
        }
      }

      await Future.delayed(Duration(seconds: 1 * (attempt + 1)));
    }

    return ApiResponse(success: false, message: "Failed after retries");
  }

  Future<ApiResponse> updateInterstitialAd(int level) async {
    if (state == null) {
      return ApiResponse(success: false, message: "No state");
    }

    final newState = state!.copyWith(interstitialAdsShownLevel: level);

    state = newState;

    final response = await _retryUpdate({
      "interstitial_ads_shown_level": newState.interstitialAdsShownLevel,
    });
    return response;
  }

  Future<ApiResponse> completedLevel(int points, int hearts) async {
    if (state == null) {
      return ApiResponse(success: false, message: "No state");
    }

    final newState = state!.copyWith(
      earnedPoints: state!.earnedPoints + points,
      currentLevel: state!.currentLevel + 1,
      currentLevelWordsFound: [],
      hintedOffsets: [],
      levelHintsUsed: 0,
      currentHearts: hearts,
    );

    state = newState;

    final response = await _retryUpdate({
      "earned_points": newState.earnedPoints,
      "current_level": newState.currentLevel,
      "current_level_words_found": [],
      "hinted_cells": [],
      "level_hints_used": 0,
      "current_hearts": hearts,
    });
    return response;
  }

  Future<ApiResponse> storeLevelPrefilled(List<Offset> offset) async {
    if (state == null) {
      return ApiResponse(success: false, message: "No state");
    }

    final newState = state!.copyWith(hintedOffsets: offset);

    state = newState;

    final response = await _retryUpdate({
      "hinted_cells": offset
          .map((e) => {"x": e.dx.toInt(), "y": e.dy.toInt()})
          .toList(),
    });
    return response;
  }

  Future<ApiResponse> useHint(int points, Offset offset) async {
    if (state == null) {
      return ApiResponse(success: false, message: "No state");
    }

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

    final response = await _retryUpdate({
      "earned_points": newState.earnedPoints,
      "hinted_cells": updatedHints
          .map((e) => {"x": e.dx.toInt(), "y": e.dy.toInt()})
          .toList(),
      "level_hints_used": newState.levelHintsUsed,
      "is_free_hint": points == 0,
    });

    return response;
  }

  Future<ApiResponse> addFoundWord(String word) async {
    if (state == null) {
      return ApiResponse(success: false, message: "No state");
    }

    if (state!.currentLevelWordsFound.contains(word)) {
      return ApiResponse(success: true, message: "Already found");
    }

    final updatedWords = [...state!.currentLevelWordsFound, word];

    final newState = state!.copyWith(currentLevelWordsFound: updatedWords);

    state = newState;

    final response = await _retryUpdate({
      "current_level_words_found": updatedWords,
    });
    return response;
  }

  void clear() {
    state = null;
  }
}
