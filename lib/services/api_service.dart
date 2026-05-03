import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/promotion/promotion_response.dart';
import '../models/reward/reward_response.dart';
import '../models/store/store_response.dart';

class ApiService {
  final String baseUrl = "https://fd61-136-158-61-7.ngrok-free.app";
  final String key = "7bEeSUU1GjGEGXENyvOVl+pD46zdipW/nCXLNnokC10=";

  Map<String, String> get _headers {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "x-api-key": key,
    };
  }

  Future<PromotionResponse> getPromotions() async {
    final url = Uri.parse(
      "$baseUrl/api/promotions?is_active=true&field=label,title,banner,url",
    );

    final response = await http.get(url, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return PromotionResponse.fromJson(jsonData);
  }

  Future<StoreResponse> getStores({
    int page = 1,
    int limit = 10,
    String fields = "name,logo",
    bool isActive = true,
    String sort = "sort_order",
    String order = "asc",
    String? search,
  }) async {
    final queryParams = {
      "page": page.toString(),
      "limit": limit.toString(),
      "fields": fields,
      "is_active": isActive.toString(),
      "sort": sort,
      "order": order,
      if (search != null && search.isNotEmpty) "search": search,
    };

    final uri = Uri.parse(
      "$baseUrl/api/stores",
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return StoreResponse.fromJson(jsonData);
  }

  Future<StoreDetailsResponse> getStoreDetails(String id) async {
    final url = Uri.parse("$baseUrl/api/stores/$id");

    final response = await http.get(url, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return StoreDetailsResponse.fromJson(jsonData);
  }

  Future<RewardResponse> getStoreRewards({
    int page = 1,
    int limit = 10,
    String fields = "title, points_cost",
    bool isActive = true,
    String sort = "sort_order",
    String order = "asc",
    String? storeId,
  }) async {
    final queryParams = {
      "page": page.toString(),
      "limit": limit.toString(),
      "fields": fields,
      "is_active": isActive.toString(),
      "sort": sort,
      "order": order,
      if (storeId != null && storeId.isNotEmpty) "storeId": storeId,
    };

    final uri = Uri.parse(
      "$baseUrl/api/rewards",
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return RewardResponse.fromJson(jsonData);
  }

  Future<RewardDetailsResponse> getRewardDetails(String id) async {
    final url = Uri.parse("$baseUrl/api/rewards/$id");

    final response = await http.get(url, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return RewardDetailsResponse.fromJson(jsonData);
  }
}
