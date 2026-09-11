import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/utils/screen_utils.dart';
import 'package:Shopsy/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends GetView<AuthController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 5.sp,
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
            size: 6.w,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Form(
          key: controller.editProfileFormKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Obx(() => CircleAvatar(
                          radius: 15.w,
                          backgroundColor: AppColors.primary,
                          backgroundImage: controller.profileImage.value != null
                              ? FileImage(controller.profileImage.value!)
                              : null,
                          child: controller.profileImage.value == null
                              ? Icon(
                                  Icons.person,
                                  size: 15.w,
                                  color: AppColors.textWhite,
                                )
                              : null,
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.textWhite,
                            size: 5.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              _buildTextField(
                controller: controller.editFirstNameController,
                label: "First Name",
                icon: Icons.person_outline,
                validator: (value) => ValidationUtils.validateRequired(value, "First Name"),
              ),
              SizedBox(height: 2.5.h),
              _buildTextField(
                controller: controller.editLastNameController,
                label: "Last Name",
                icon: Icons.person_outline,
                validator: (value) => ValidationUtils.validateRequired(value, "Last Name"),
              ),
              SizedBox(height: 2.5.h),
              _buildTextField(
                controller: controller.editEmailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: ValidationUtils.validateEmail,
              ),
              SizedBox(height: 5.h),
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
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
                                fontSize: 4.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: 4.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 3.5.sp),
        prefixIcon: Icon(icon, size: 6.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
