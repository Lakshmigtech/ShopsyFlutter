class LoginResponse {
  final LoginDetail detail;

  LoginResponse({required this.detail});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(detail: LoginDetail.fromJson(json['detail']));
  }
}

class LoginDetail {
  final String status;
  final String message;
  final int userId;
  final String accessToken;
  final String refreshToken;

  LoginDetail({
    required this.status,
    required this.message,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginDetail.fromJson(Map<String, dynamic> json) {
    return LoginDetail(
      status: json['status'],
      message: json['message'],
      userId: json['user_id'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
