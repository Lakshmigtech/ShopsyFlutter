import 'package:Shopsy/Controller/address_controller.dart';
import 'package:Shopsy/Controller/auth_controller.dart';
import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Controller/order_controller.dart';
import 'package:Shopsy/Controller/productcontroller.dart';
import 'package:Shopsy/Controller/splash_controller.dart';
import 'package:Shopsy/Controller/wishlist_controller.dart';
import 'package:Shopsy/Controller/payment_controller.dart';
import 'package:Shopsy/Controller/notification_controller.dart';
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
