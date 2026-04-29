import '../shared/meta_model.dart';
import 'promotion_model.dart';

class PromotionResponse {
  final bool success;
  final Meta meta;
  final List<Promotion> data;

  PromotionResponse({
    required this.success,
    required this.meta,
    required this.data,
  });

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      success: json['success'] ?? false,
      meta: Meta.fromJson(json['meta'] ?? {}),
      data: (json['data'] as List).map((e) => Promotion.fromJson(e)).toList(),
    );
  }
}
