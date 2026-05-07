import 'dart:io';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Respositories/loginapi.dart';
import 'package:Shopsy/Utils/local_storage.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:Shopsy/views/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final isHidden = true.obs;
  final username = 'Guest'.obs;
  final email = ''.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;
  final profileImage = Rxn<File>();
  final token = RxnString();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Edit Profile Controllers
  late TextEditingController editFirstNameController;
  late TextEditingController editLastNameController;
  late TextEditingController editEmailController;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    editFirstNameController = TextEditingController();
    editLastNameController = TextEditingController();
    editEmailController = TextEditingController();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final imagePath = await LocalStorage.getProfileImage();
    if (imagePath != null && imagePath.isNotEmpty) {
      profileImage.value = File(imagePath);
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      await LocalStorage.saveProfileImage(pickedFile.path);
    }
  }

  void togglePasswordVisibility() {
    isHidden.value = !isHidden.value;
  }

  Future<bool> restoreSession() async {
    final storedToken = await LocalStorage.getToken();
    final storedUsername = await LocalStorage.getUsername();

    token.value = storedToken;
    username.value =
    (storedUsername?.trim().isNotEmpty ?? false) ? storedUsername!.trim() : 'Guest';

    if (storedUsername != null && storedUsername.trim().isNotEmpty) {
      usernameController.text = storedUsername.trim();
    }

    return storedToken != null && storedToken.isNotEmpty;
  }

  Future<void> login() async {
    final enteredUsername = usernameController.text.trim();
    final enteredPassword = passwordController.text;

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      Get.snackbar('Error', 'Please enter all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final result = await AuthService.login(
        username: enteredUsername,
        password: enteredPassword,
      );

      if (result != null && result.accessToken.isNotEmpty) {
        await LocalStorage.saveLogin(
          token: result.accessToken,
          userId: result.id,
          username: result.username,
        );

        token.value = result.accessToken;
        username.value = result.username;
        firstName.value = result.firstName;
        lastName.value = result.lastName;
        email.value = result.email;

        // Populate edit controllers
        editFirstNameController.text = result.firstName;
        editLastNameController.text = result.lastName;
        editEmailController.text = result.email;

        passwordController.clear();
        isHidden.value = true;

        Get.find<NavigationController>().reset();

        Get.snackbar('Success', 'Login successful',
            snackPosition: SnackPosition.BOTTOM);

        Get.offAll(() => const MainNavigation());
      } else {
        Get.snackbar('Error', 'Invalid credentials',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (editFirstNameController.text.isEmpty || editLastNameController.text.isEmpty || editEmailController.text.isEmpty) {
      Get.snackbar('Error', 'Fields cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    firstName.value = editFirstNameController.text;
    lastName.value = editLastNameController.text;
    email.value = editEmailController.text;
    
    isLoading.value = false;
    Get.back();
    Get.snackbar('Success', 'Profile updated locally', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> simplelogin() async {
    Get.offAll(() => const MainNavigation());
  }

  Future<void> logout() async {
    await LocalStorage.clear();

    token.value = null;
    username.value = 'Guest';
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    profileImage.value = null;

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
    editFirstNameController.dispose();
    editLastNameController.dispose();
    editEmailController.dispose();
    super.onClose();
  }
}
