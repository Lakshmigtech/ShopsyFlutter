import 'package:Shopsy/Controller/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.put(SignupController());

    return Scaffold(
      // 1. Fix: Ensure the white area at the bottom is covered by the gradient
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        // 2. Fix: Ensure the container fills the entire screen
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5b9df9), Color(0xffb57ad6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              // 3. Fix: Allow padding at the bottom so content doesn't touch the edge
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// NAME FIELD
                  TextField(
                    controller: controller.nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// EMAIL
                  TextField(
                    controller: controller.emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Email Address",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PHONE NUMBER
                  TextField(
                    controller: controller.phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  Obx(
                    () => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.isPasswordHidden.value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CONFIRM PASSWORD
                  Obx(
                    () => TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.isPasswordHidden.value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SIGNUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.signup,
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LOGIN TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
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
        ),
      ),
    );
  }
}
