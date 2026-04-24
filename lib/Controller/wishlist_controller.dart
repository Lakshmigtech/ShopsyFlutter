import 'package:Shopsy/models/productmodel.dart';
import 'package:get/get.dart';

class WishlistController extends GetxController {
  final wishlistItems = <Product>[].obs;

  void toggleFavorite(Product product) {
    if (product.isFavorite.value) {
      product.isFavorite.value = false;
      wishlistItems.removeWhere((item) => item.id == product.id);
    } else {
      product.isFavorite.value = true;
      wishlistItems.add(product);
    }
  }

  bool isFavorite(Product product) {
    return wishlistItems.any((item) => item.id == product.id);
  }

  void removeFromWishlist(Product product) {
    product.isFavorite.value = false;
    wishlistItems.removeWhere((item) => item.id == product.id);
  }
}
