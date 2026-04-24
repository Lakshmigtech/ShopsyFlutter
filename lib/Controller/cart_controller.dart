import 'package:Shopsy/models/productmodel.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;

  void addToCart(Product product) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      cartItems[index].quantity.value++;
    } else {
      cartItems.add(CartItem(product: product));
    }

    Get.snackbar(
      'Success',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void increaseQuantity(int index) {
    cartItems[index].quantity.value++;
  }

  void decreaseQuantity(int index) {
    if (cartItems[index].quantity.value > 1) {
      cartItems[index].quantity.value--;
      return;
    }

    cartItems.removeAt(index);
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  int get itemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
}
