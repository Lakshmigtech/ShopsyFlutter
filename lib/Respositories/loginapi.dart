import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 15));

      log("📥 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return LoginResponse.fromJson(jsonData);
      } else {
        final errorMsg = _handleError(response.statusCode, response.body);
        throw errorMsg;
      }
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "Connection timed out. Please try again.";
    } on FormatException {
      throw "Invalid response format from server.";
    } catch (e) {
      log("🚨 Exception during login: $e");
      rethrow;
    }
  }

  static String _handleError(int statusCode, String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    } catch (_) {}

    switch (statusCode) {
      case 400: return "Bad Request. Please check your inputs.";
      case 401: return "Invalid username or password.";
      case 403: return "Access denied.";
      case 404: return "Server not found.";
      case 500: return "Internal Server Error. Try again later.";
      default: return "Something went wrong (Error $statusCode)";
    }
  }
}
