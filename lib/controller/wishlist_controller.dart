import 'dart:convert';
import 'package:Shopsy/models/productmodel.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistController extends GetxController {
  final wishlistItems = <Product>[].obs;
  static const String _storageKey = 'wishlist_items';

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_storageKey);
    if (itemsJson != null) {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      wishlistItems.value = decoded.map((item) => Product.fromJson(item)).toList();
    }
  }

  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(wishlistItems.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void toggleFavorite(Product product) async {
    int index = wishlistItems.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      wishlistItems.removeAt(index);
    } else {
      wishlistItems.add(product);
    }
    await saveWishlist();
  }

  bool isFavorite(Product product) {
    return wishlistItems.any((item) => item.id == product.id);
  }

  void removeFromWishlist(Product product) async {
    wishlistItems.removeWhere((item) => item.id == product.id);
    await saveWishlist();
  }
}
