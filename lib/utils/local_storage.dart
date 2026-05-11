import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveLogin({
    required String token,
    required int userId,
    required String username,
    String? firstName,
    String? lastName,
    String? email,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);
    if (firstName != null) await prefs.setString('firstName', firstName);
    if (lastName != null) await prefs.setString('lastName', lastName);
    if (email != null) await prefs.setString('email', email);
    if (imageUrl != null) {
      await prefs.setString('imageUrl', imageUrl);
    }
  }

  static Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image');
  }

  static Future<Map<String, String?>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'firstName': prefs.getString('firstName'),
      'lastName': prefs.getString('lastName'),
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
    };
  }

  static Future<String?> getImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('imageUrl');
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
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('email');
    await prefs.remove('profile_image');
    await prefs.remove('imageUrl');
  }
}
