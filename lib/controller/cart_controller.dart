import 'dart:convert';
import 'package:Shopsy/models/productmodel.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;
  static const String _storageKey = 'cart_items';

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_storageKey);
    if (itemsJson != null) {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      cartItems.value = decoded.map((item) => CartItem.fromJson(item)).toList();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(cartItems.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addToCart(Product product) async {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(product: product));
    }
    
    await saveCart();

    Get.snackbar(
      'Success',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void increaseQuantity(int index) async {
    cartItems[index].quantity++;
    cartItems.refresh();
    await saveCart();
  }

  void decreaseQuantity(int index) async {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
    } else {
      cartItems.removeAt(index);
    }
    await saveCart();
  }

  void removeFromCart(int index) async {
    cartItems.removeAt(index);
    await saveCart();
  }

  void clearCart() async {
    cartItems.clear();
    await saveCart();
  }

  int get itemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
}
