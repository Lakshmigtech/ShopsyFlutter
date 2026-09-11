import 'dart:io';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/repositories/login_api.dart';
import 'package:Shopsy/utils/local_storage.dart';
import 'package:Shopsy/views/bottom_navigation/bottom_navigation.dart';
import 'package:Shopsy/views/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AuthController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final editProfileFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isHidden = true.obs;
  final username = 'Guest'.obs;
  final email = ''.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;
  final profileImageUrl = ''.obs;
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
    final String? imagePath = LocalStorage.getProfileImage();
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        
        // Reconstruct path from filename
        final String fileName = p.basename(imagePath);
        final File permanentFile = File(p.join(appDir.path, fileName));
        
        if (await permanentFile.exists()) {
          profileImage.value = permanentFile;
        } else {
          // Migration/Fallback: If it was an absolute path (e.g., old version or Android)
          final File absoluteFile = File(imagePath);
          if (p.isAbsolute(imagePath) && await absoluteFile.exists()) {
            // Copy it to permanent storage now so we don't lose it when tmp is cleared
            final String newPermanentPath = p.join(appDir.path, fileName);
            await absoluteFile.copy(newPermanentPath);
            profileImage.value = File(newPermanentPath);
            await LocalStorage.saveProfileImage(fileName);
          } else {
            // Path is invalid or file is gone
            profileImage.value = null;
            await LocalStorage.saveProfileImage('');
          }
        }
      } catch (e) {
        debugPrint("Error loading profile image: $e");
        profileImage.value = null;
      }
    }
    
    final imageUrl = await LocalStorage.getImageUrl();
    if (imageUrl != null) {
      profileImageUrl.value = imageUrl;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}";
        final String permanentPath = p.join(appDir.path, fileName);
        
        // Copy to permanent storage
        await File(pickedFile.path).copy(permanentPath);
        
        profileImage.value = File(permanentPath);
        // Save just the filename to be container-agnostic (important for iOS)
        await LocalStorage.saveProfileImage(fileName);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', 
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void togglePasswordVisibility() {
    isHidden.value = !isHidden.value;
  }

  Future<bool> restoreSession() async {
    final details = await LocalStorage.getUserDetails();
    final imageUrl = await LocalStorage.getImageUrl();
    
    token.value = details['token'];
    username.value = details['username'] ?? 'Guest';
    firstName.value = details['firstName'] ?? '';
    lastName.value = details['lastName'] ?? '';
    email.value = details['email'] ?? '';
    profileImageUrl.value = imageUrl ?? '';

    if (username.value != 'Guest') {
      usernameController.text = username.value;
    }
    
    // Populate edit controllers if data exists
    if (firstName.value.isNotEmpty) editFirstNameController.text = firstName.value;
    if (lastName.value.isNotEmpty) editLastNameController.text = lastName.value;
    if (email.value.isNotEmpty) editEmailController.text = email.value;

    return token.value != null && token.value!.isNotEmpty;
  }

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    final enteredUsername = usernameController.text.trim();
    final enteredPassword = passwordController.text;

    try {
      isLoading.value = true;

      final result = await LoginApi.login(
        username: enteredUsername,
        password: enteredPassword,
      );

      if (result != null && result.accessToken.isNotEmpty) {
        await LocalStorage.saveLogin(
          token: result.accessToken,
          userId: result.id,
          username: result.username,
          firstName: result.firstName,
          lastName: result.lastName,
          email: result.email,
          imageUrl: result.image,
        );

        token.value = result.accessToken;
        username.value = result.username;
        firstName.value = result.firstName;
        lastName.value = result.lastName;
        email.value = result.email;
        profileImageUrl.value = result.image;

        // Populate edit controllers
        editFirstNameController.text = result.firstName;
        editLastNameController.text = result.lastName;
        editEmailController.text = result.email;

        passwordController.clear();
        isHidden.value = true;
        Get.find<NavigationController>().reset();

        Get.snackbar('Success', 'Login successful',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.backgroundSuccess,
            colorText: AppColors.textWhite);

        Get.offAll(() => const MainNavigation());
      } else {
        Get.snackbar('Error', 'Invalid credentials',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.backgroundAlert,
          colorText:AppColors.textWhite);
    } finally {
      isLoading.value = false;
    }
  }

  void prepareEditProfile() {
    editFirstNameController.text = firstName.value;
    editLastNameController.text = lastName.value;
    editEmailController.text = email.value;
  }

  Future<void> updateProfile() async {
    if (!(editProfileFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    // Simulate API call or update locally
    await Future.delayed(const Duration(seconds: 1));
    
    firstName.value = editFirstNameController.text;
    lastName.value = editLastNameController.text;
    email.value = editEmailController.text;
    
    // Update local storage
    final currentToken = await LocalStorage.getToken();
    if (currentToken != null) {
      await LocalStorage.saveLogin(
        token: currentToken,
        userId: 0, 
        username: username.value,
        firstName: firstName.value,
        lastName: lastName.value,
        email: email.value,
        imageUrl: profileImageUrl.value,
      );
    }
    
    isLoading.value = false;
    Get.back();
    Get.snackbar('Success', 'Profile updated locally', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> logout() async {
    await LoginApi.logout(token.value);
    await LocalStorage.clear();
    
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearCart();
    }

    token.value = null;
    username.value = 'Guest';
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    profileImageUrl.value = '';
    profileImage.value = null;

    usernameController.clear();
    passwordController.clear();
    isHidden.value = true;

    Get.find<NavigationController>().reset();
    Get.offAll(() => const LoginScreen());
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
