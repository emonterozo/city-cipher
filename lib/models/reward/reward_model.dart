import '../../core/enums/app_enums.dart';
import '../store/store_model.dart';

class RewardRule {
  final String id;
  final RewardRuleType type;
  final int value;

  RewardRule({required this.id, required this.type, required this.value});

  factory RewardRule.fromJson(Map<String, dynamic> json) {
    return RewardRule(
      id: json['_id'] ?? '',
      type: RewardRuleType.fromString(json['type'] ?? ''),
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'type': type.value, 'value': value};
  }
}

class Reward {
  final String id;
  final Store store;
  final String title;
  final String description;
  final int pointsCost;
  final int totalQuantity;
  final int redeemedQuantity;
  final int perUserLimit;
  final int claimValidDays;
  final DateTime startDate;
  final DateTime endDate;
  final List<RewardRule> rules;

  Reward({
    required this.id,
    required this.store,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.totalQuantity,
    required this.redeemedQuantity,
    required this.perUserLimit,
    required this.claimValidDays,
    required this.startDate,
    required this.endDate,
    required this.rules,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['_id'] ?? '',
      store: Store.fromJson(json['store_id'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pointsCost: json['points_cost'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
      redeemedQuantity: json['redeemed_quantity'] ?? 0,
      perUserLimit: json['per_user_limit'] ?? 0,
      claimValidDays: json['claim_valid_days'] ?? 0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      rules: (json['rules'] as List<dynamic>? ?? [])
          .map((e) => RewardRule.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'store_id': store.toJson(),
      'title': title,
      'description': description,
      'points_cost': pointsCost,
      'total_quantity': totalQuantity,
      'per_user_limit': perUserLimit,
      'claim_valid_days': claimValidDays,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'rules': rules.map((e) => e.toJson()).toList(),
    };
  }
}
