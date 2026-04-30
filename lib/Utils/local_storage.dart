import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveLogin({
    required String token,
    required int userId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    // Only remove user session related data, keeping other settings (like addresses/orders)
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
  }
}
