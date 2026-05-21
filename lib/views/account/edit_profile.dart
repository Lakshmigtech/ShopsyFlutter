import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends GetView<AuthController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: AppColors.black)),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Obx(() => CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.blue100,
                        backgroundImage: controller.profileImage.value != null
                            ? FileImage(controller.profileImage.value!)
                            : null,
                        child: controller.profileImage.value == null
                            ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                            : null,
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildTextField(
              controller: controller.editFirstNameController,
              label: "First Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.editLastNameController,
              label: "Last Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.editEmailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateProfile(),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : const Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
