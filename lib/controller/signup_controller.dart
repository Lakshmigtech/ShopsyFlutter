import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/utils/validation_utils.dart';

class SignupController extends GetxController {
  final signupFormKey = GlobalKey<FormState>();
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
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
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
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      Get.back(); // Go back to login
    } catch (e) {
      Get.snackbar(
        "Error", 
        e.toString(), 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
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
