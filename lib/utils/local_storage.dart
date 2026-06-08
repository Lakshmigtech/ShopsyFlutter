import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveLogin({
    required String token,
    required int userId,
    required String username,
    String? firstName,
    String? lastName,
    String? email,
    String? imageUrl,
  }) async {
    await _prefs.setString('token', token);
    await _prefs.setInt('userId', userId);
    await _prefs.setString('username', username);
    if (firstName != null) await _prefs.setString('firstName', firstName);
    if (lastName != null) await _prefs.setString('lastName', lastName);
    if (email != null) await _prefs.setString('email', email);
    if (imageUrl != null) {
      await _prefs.setString('imageUrl', imageUrl);
    }
  }

  static Future<void> saveProfileImage(String path) async {
    await _prefs.setString('profile_image', path);
  }

  static String? getProfileImage() {
    return _prefs.getString('profile_image');
  }

  static Map<String, String?> getUserDetails() {
    return {
      'username': _prefs.getString('username'),
      'firstName': _prefs.getString('firstName'),
      'lastName': _prefs.getString('lastName'),
      'email': _prefs.getString('email'),
      'token': _prefs.getString('token'),
    };
  }

  static String? getImageUrl() {
    return _prefs.getString('imageUrl');
  }

  static String? getUsername() {
    return _prefs.getString('username');
  }

  static String? getToken() {
    return _prefs.getString('token');
  }

  static Future<void> clear() async {
    await _prefs.remove('token');
    await _prefs.remove('userId');
    await _prefs.remove('username');
    await _prefs.remove('firstName');
    await _prefs.remove('lastName');
    await _prefs.remove('email');
    await _prefs.remove('profile_image');
    await _prefs.remove('imageUrl');
  }
}
