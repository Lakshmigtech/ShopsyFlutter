import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/controller/product_controller.dart';
import 'package:Shopsy/controller/splash_controller.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/controller/payment_controller.dart';
import 'package:Shopsy/controller/notification_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Global Controllers - Remain permanent
    Get.put(AuthController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(NotificationController(), permanent: true);

    // Feature-specific Controllers - Use lazyPut for better memory management
    Get.lazyPut(() => ProductController(), fenix: true);
    Get.lazyPut(() => CartController(), fenix: true);
    Get.lazyPut(() => WishlistController(), fenix: true);
    Get.lazyPut(() => AddressController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);
    Get.lazyPut(() => PaymentController(), fenix: true);
    Get.lazyPut(() => SplashController());
  }
}
