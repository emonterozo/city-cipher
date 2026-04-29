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