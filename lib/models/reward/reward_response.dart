import 'package:city_cipher/models/reward/user_reward_details_model.dart';
import 'package:city_cipher/models/reward/user_reward_model.dart';
import 'package:city_cipher/services/api_service.dart';

import '../shared/meta_model.dart';
import 'reward_model.dart';

class RewardResponse {
  final bool success;
  final Meta meta;
  final List<Reward> data;

  RewardResponse({
    required this.success,
    required this.meta,
    required this.data,
  });

  factory RewardResponse.fromJson(Map<String, dynamic> json) {
    return RewardResponse(
      success: json['success'] ?? false,
      meta: Meta.fromJson(json['meta'] ?? {}),
      data: (json['data'] as List? ?? [])
          .map((e) => Reward.fromJson(e))
          .toList(),
    );
  }
}

class RewardDetailsResponse {
  final bool success;
  final Reward data;

  RewardDetailsResponse({required this.success, required this.data});

  factory RewardDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RewardDetailsResponse(
      success: json['success'] ?? false,
      data: Reward.fromJson(json['data'] ?? {}),
    );
  }
}

class UserRewardResponse extends ApiResponse {
  final Meta meta;
  final List<UserReward> data;

  UserRewardResponse({
    super.statusCode,
    required super.success,
    required super.message,
    required this.meta,
    required this.data,
  });

  factory UserRewardResponse.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return UserRewardResponse(
      statusCode: statusCode,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      meta: Meta.fromJson(json['meta'] ?? {}),
      data: (json['data'] as List? ?? [])
          .map((e) => UserReward.fromJson(e))
          .toList(),
    );
  }

  factory UserRewardResponse.sessionExpired() {
    return UserRewardResponse(
      statusCode: 401,
      success: false,
      message: "Session expired",
      meta: Meta.empty(),
      data: [],
    );
  }
}

class UserRewardDetailsResponse extends ApiResponse {
  final UserRewardDetails data;

  UserRewardDetailsResponse({
    super.statusCode,
    required super.success,
    required super.message,
    required this.data,
  });

  factory UserRewardDetailsResponse.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    final raw = Map<String, dynamic>.from(json['data'] ?? {});

    final rewardJson = Map<String, dynamic>.from(raw['reward_id'] ?? {});

    final storeJson = Map<String, dynamic>.from(rewardJson['store_id'] ?? {});

    final mappedData = {...raw, 'reward': rewardJson, 'store': storeJson};

    return UserRewardDetailsResponse(
      statusCode: statusCode,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserRewardDetails.fromJson(mappedData),
    );
  }

  factory UserRewardDetailsResponse.sessionExpired() {
    return UserRewardDetailsResponse(
      statusCode: 401,
      success: false,
      message: "Session expired",
      data: UserRewardDetails.empty(),
    );
  }
}
