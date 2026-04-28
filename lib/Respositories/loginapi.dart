import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:Shopsy/models/loginmodel.dart';

class AuthService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<LoginResponse?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/user/login");
    final body = jsonEncode({
      "username": username,
      "password": password,
    });

    log("🚀 Request URL: $url");
    log("📦 Request Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      log("📥 Status Code: ${response.statusCode}");
      log("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return LoginResponse.fromJson(jsonData);
      } else {
        log("❌ Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("🚨 Exception during login: $e");
      return null;
    }
  }
}
