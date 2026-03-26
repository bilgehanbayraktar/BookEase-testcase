import 'user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;
  final AuthUser user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresAt: json['expiresAt'] as String,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}
