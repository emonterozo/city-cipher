import 'dart:convert';
import 'package:city_cipher/core/enums/app_enums.dart';
import 'package:http/http.dart' as http;

import '../models/promotion/promotion_response.dart';
import '../models/reward/reward_response.dart';
import '../models/store/store_response.dart';
import '../models/user/registration_response.dart';

class ApiService {
  final String baseUrl = "https://9c88-136-158-61-7.ngrok-free.app";
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

  Future<RegistrationResponse> userRegistration(
    String firstName,
    String lastName,
    String mobileNumber,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/users/register");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "mobile_number": mobileNumber,
        "password": password,
      }),
    );

    final jsonData = jsonDecode(response.body);

    return RegistrationResponse.fromJson(jsonData);
  }

  Future<OtpResponse> sendOtp(String userId, OtpType type) async {
    final url = Uri.parse("$baseUrl/api/users/otp");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"user_id": userId, "type": type.value}),
    );

    final jsonData = jsonDecode(response.body);

    return OtpResponse.fromJson(jsonData);
  }

  Future<VerifyOtpResponse> verifyOtp(String userId, String otp, OtpType type) async {
    final url = Uri.parse("$baseUrl/api/users/verify");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"user_id": userId, "otp": otp, "type": type.value}),
    );

    final jsonData = jsonDecode(response.body);

    return VerifyOtpResponse.fromJson(jsonData);
  }
}
