import '../reward/reward_model.dart';
import '../shared/meta_model.dart';
import 'store_model.dart';

class StoreResponse {
  final bool success;
  final Meta meta;
  final List<Store> data;

  StoreResponse({
    required this.success,
    required this.meta,
    required this.data,
  });

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      success: json['success'] ?? false,
      meta: Meta.fromJson(json['meta'] ?? {}),
      data: (json['data'] as List? ?? [])
          .map((e) => Store.fromJson(e))
          .toList(),
    );
  }
}

class StoreDetailsResponse {
  final bool success;
  final Store store;
  final List<Reward> rewards;
  final Meta meta;

  StoreDetailsResponse({
    required this.success,
    required this.store,
    required this.rewards,
    required this.meta,
  });

  factory StoreDetailsResponse.fromJson(Map<String, dynamic> json) {
    return StoreDetailsResponse(
      success: json['success'] ?? false,
      store: Store.fromJson(json['data']['store'] ?? {}),
      rewards: (json['data']['rewards'] as List? ?? [])
          .map((e) => Reward.fromJson(e))
          .toList(),
      meta: Meta.fromJson(json['data']['meta'] ?? {}),
    );
  }
}
