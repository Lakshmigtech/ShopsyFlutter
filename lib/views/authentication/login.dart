import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/views/authentication/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5b9df9), Color(0xffb57ad6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          "Welcome Shopsy",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: controller.usernameController,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: const TextStyle(color: AppColors.textWhite),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: controller.isHidden.value,
                            style: const TextStyle(color:AppColors.textWhite),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color:AppColors.textWhite),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textWhite,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(
                            () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.login(),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: AppColors.loader,
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textWhite),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const SignUpScreen());
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
