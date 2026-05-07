import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/controller/productcontroller.dart';
import 'package:Shopsy/controller/splash_controller.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/controller/payment_controller.dart';
import 'package:Shopsy/controller/notification_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(ProductController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(AddressController(), permanent: true);
    Get.put(OrderController(), permanent: true);
    Get.put(PaymentController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.lazyPut(() => SplashController());
  }
}
