import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/auth/auth_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _storage = const FlutterSecureStorage();

  Future<void> setAuth({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    // save to secure storage
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);

    // update state
    state = AuthState(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> loadAuth() async {
    final userId = await _storage.read(key: 'userId');
    final accessToken = await _storage.read(key: 'accessToken');
    final refreshToken = await _storage.read(key: 'refreshToken');

    state = AuthState(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }
}
