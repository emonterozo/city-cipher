import 'package:city_cipher/models/reward/reward_model.dart';

class UserReward {
  final String id;
  final String status;
  final DateTime? expiredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Reward reward;

  UserReward({
    required this.id,
    required this.status,
    required this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.reward,
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    return UserReward(
      id: json['_id'] ?? '',
      status: json['status'] ?? '',
      expiredAt: DateTime.tryParse(json['expired_at'] ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      reward: Reward.fromJson(json['reward_id']),
    );
  }

  factory UserReward.empty() {
    return UserReward(
      id: '',
      status: '',
      expiredAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reward: Reward.empty(),
    );
  }
}
