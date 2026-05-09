import 'dart:convert';
import 'package:city_cipher/core/enums/app_enums.dart';
import 'package:city_cipher/models/user/game_data_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/providers/auth_provider.dart';
import '../models/game/game_level_response.dart';
import '../models/gameConfig/game_config_response.dart';
import '../models/promotion/promotion_response.dart';
import '../models/reward/reward_response.dart';
import '../models/store/store_response.dart';
import '../models/user/registration_response.dart';

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class ApiService {
  final Ref ref;

  ApiService(this.ref);

  final String baseUrl = "https://72bc-136-158-61-7.ngrok-free.app";
  final String key = "7bEeSUU1GjGEGXENyvOVl+pD46zdipW/nCXLNnokC10=";

  Map<String, String> get _headers {
    final token = ref.read(authProvider).accessToken;
    print(token);
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "x-api-key": key,
      "authorization": "Bearer $token",
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

  Future<VerifyOtpResponse> verifyOtp(
    String userId,
    String otp,
    OtpType type,
  ) async {
    final url = Uri.parse("$baseUrl/api/users/verify");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"user_id": userId, "otp": otp, "type": type.value}),
    );

    final jsonData = jsonDecode(response.body);

    return VerifyOtpResponse.fromJson(jsonData);
  }

  Future<LoginResponse> login(String mobileNumber, String password) async {
    final url = Uri.parse("$baseUrl/api/users/login");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"mobile_number": mobileNumber, "password": password}),
    );

    final jsonData = jsonDecode(response.body);

    return LoginResponse.fromJson(jsonData);
  }

  Future<OtpResponse> forgotPassword(String mobileNumber) async {
    final url = Uri.parse("$baseUrl/api/users/forgot");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"mobile_number": mobileNumber}),
    );

    final jsonData = jsonDecode(response.body);

    return OtpResponse.fromJson(jsonData);
  }

  Future<ResetPasswordResponse> resetPassword(
    String userId,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/users/reset");

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"user_id": userId, "password": password}),
    );

    final jsonData = jsonDecode(response.body);

    return ResetPasswordResponse.fromJson(jsonData);
  }

  Future<GameConfigResponse> getGameConfigs({
    int limit = 1,
    String configVersion = "1.0.0",
    bool isActive = true,
  }) async {
    final queryParams = {
      "limit": limit.toString(),
      "config_version": configVersion,
      "is_active": isActive.toString(),
    };

    final uri = Uri.parse(
      "$baseUrl/api/game-configs",
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return GameConfigResponse.fromJson(jsonData);
  }

  Future<GameDataResponse> getUserGameData() async {
    final uri = Uri.parse("$baseUrl/api/game/me");

    var response = await http.get(uri, headers: _headers);

    if (response.statusCode == 401) {
      final newToken = await refreshToken();
      print(newToken);

      if (newToken == null) {
        throw Exception("Session expired");
      }

      response = await http.get(
        uri,
        headers: {..._headers, "authorization": "Bearer $newToken"},
      );
    }

    final jsonData = jsonDecode(response.body);

    return GameDataResponse.fromJson(jsonData);
  }

  Future<String?> refreshToken() async {
    final refreshToken = ref.read(authProvider).refreshToken;

    final uri = Uri.parse("$baseUrl/api/auth/refresh");

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({"refresh_token": refreshToken}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final newAccessToken = data["access_token"];

      final auth = ref.read(authProvider);

      ref
          .read(authProvider.notifier)
          .setAuth(
            userId: auth.userId!,
            accessToken: newAccessToken,
            refreshToken: refreshToken!,
          );

      return newAccessToken;
    }

    return null;
  }

  Future<GameLevelResponse> getGameLevels({
    int currentLevel = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      "current_level": currentLevel.toString(),
      "limit": limit.toString(),
    };

    final uri = Uri.parse(
      "$baseUrl/api/game/levels",
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    final jsonData = jsonDecode(response.body);

    return GameLevelResponse.fromJson(jsonData);
  }

  Future<ApiResponse> updateUserGameData(Map<String, dynamic> body) async {
    final uri = Uri.parse("$baseUrl/api/game/me");

    var response = await http.patch(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final newToken = await refreshToken();

      if (newToken == null) {
        throw Exception("Session expired");
      }

      response = await http.get(
        uri,
        headers: {..._headers, "authorization": "Bearer $newToken"},
      );
    }

    final jsonData = jsonDecode(response.body);

    return ApiResponse.fromJson(jsonData);
  }
}
