import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Respositories/loginapi.dart';
import 'package:Shopsy/Utils/local_storage.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:Shopsy/views/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final isHidden = true.obs;
  final username = 'Guest'.obs;
  final token = RxnString();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void togglePasswordVisibility() {
    isHidden.value = !isHidden.value;
  }

  Future<bool> restoreSession() async {
    final storedToken = await LocalStorage.getToken();
    final storedUsername = await LocalStorage.getUsername();

    token.value = storedToken;
    username.value = (storedUsername?.trim().isNotEmpty ?? false)
        ? storedUsername!.trim()
        : 'Guest';

    if (storedUsername != null && storedUsername.trim().isNotEmpty) {
      usernameController.text = storedUsername.trim();
    }

    return storedToken != null && storedToken.isNotEmpty;
  }

  Future<void> login() async {
    final enteredUsername = usernameController.text.trim();
    final enteredPassword = passwordController.text;

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await AuthService.login(
        username: enteredUsername,
        password: enteredPassword,
      );

      if (result != null && result.detail.status == 'success') {
        await LocalStorage.saveLogin(
          token: result.detail.accessToken,
          userId: result.detail.userId,
          username: enteredUsername,
        );

        token.value = result.detail.accessToken;
        username.value = enteredUsername;
        passwordController.clear();
        isHidden.value = true;
        Get.find<NavigationController>().reset();

        Get.snackbar(
          'Success',
          result.detail.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAll(() => const MainNavigation());
        return;
      } else {
        Get.snackbar(
          'Error',
          'Login failed. Please check your credentials.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> simplelogin() async {
    Get.offAll(() => const MainNavigation());
  }

    Future<void> logout() async {
    await LocalStorage.clear();
    token.value = null;
    username.value = 'Guest';
    usernameController.clear();
    passwordController.clear();
    isHidden.value = true;
    Get.find<NavigationController>().reset();
    Get.offAll(() => const LoginPage());
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
