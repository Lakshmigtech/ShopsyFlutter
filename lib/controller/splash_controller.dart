import 'dart:async';

import 'package:Shopsy/Controller/auth_controller.dart';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:Shopsy/views/Authentication/login.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final isCheckingSession = true.obs;
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    _routeUser();
  }

  void _routeUser() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () async {
      final authController = Get.find<AuthController>();
      final navigationController = Get.find<NavigationController>();
      final hasSession = await authController.restoreSession();

      if (isClosed) {
        return;
      }

      navigationController.reset();
      isCheckingSession.value = false;

      if (hasSession) {
        Get.offAll(() => const MainNavigation());
        return;
      }

      Get.offAll(() => const LoginPage());
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
