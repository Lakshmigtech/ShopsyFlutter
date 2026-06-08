import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends GetView<AuthController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.textWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textBlack,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Obx(() => CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundColor: AppColors.primary,
                        backgroundImage: controller.profileImage.value != null
                            ? FileImage(controller.profileImage.value!)
                            : null,
                        child: controller.profileImage.value == null
                            ? Icon(
                                Icons.person,
                                size: screenWidth * 0.15,
                                color: AppColors.primary,
                              )
                            : null,
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: AppColors.textWhite,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            _buildTextField(
              controller: controller.editFirstNameController,
              label: "First Name",
              icon: Icons.person_outline,
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.025),
            _buildTextField(
              controller: controller.editLastNameController,
              label: "Last Name",
              icon: Icons.person_outline,
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.025),
            _buildTextField(
              controller: controller.editEmailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.05),
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateProfile(),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: AppColors.textWhite)
                        : Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: screenWidth * 0.04,
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
    required double screenWidth,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: screenWidth * 0.04),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        prefixIcon: Icon(icon, size: screenWidth * 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
