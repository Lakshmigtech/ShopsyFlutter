import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading(true);
      // Simulate API call or call a repository
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
        "Success",
        "Account created successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back(); // Go back to login
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
