/// OAuth token pair from `POST /auth/oauth/{provider}/token` or `/auth/refresh`.
class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String userId;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      userId: json['userId']?.toString() ?? '',
    );
  }
}
