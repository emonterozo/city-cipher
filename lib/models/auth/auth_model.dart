class AuthState {
  final String? userId;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({this.userId, this.accessToken, this.refreshToken});

  bool get isAuthenticated => accessToken != null;
}
