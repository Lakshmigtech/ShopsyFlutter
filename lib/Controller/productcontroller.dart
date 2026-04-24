import 'package:Shopsy/models/productmodel.dart';
import 'package:get/get.dart';
import '../Respositories/product_repository.dart';

enum SortOption { popularity, priceLowToHigh, priceHighToLow }

class ProductController extends GetxController {
  final productList = <Product>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  
  // Filter & Search state
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final selectedSortOption = SortOption.popularity.obs;
  
  // Advanced Filter state
  final minPrice = 0.0.obs;
  final maxPrice = 10000.0.obs; // Default high value
  final selectedRating = 0.obs; // 0 means any rating

  List<String> get categories => const [
    'All',
    'Home',
    'Fashion',
    'Electronics',
    'Beauty',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({bool force = false}) async {
    if (isLoading.value || (!force && productList.isNotEmpty)) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      final products = await ApiService.fetchProducts();
      productList.assignAll(products);
      
      // Update max price based on actual products if list is not empty
      if (products.isNotEmpty) {
        double maxFound = 0;
        for (var p in products) {
          if (p.priceCents / 100 > maxFound) maxFound = p.priceCents / 100;
        }
        maxPrice.value = (maxFound / 100).ceil() * 100.0 + 100; // Round up
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  void updateSortOption(SortOption option) {
    selectedSortOption.value = option;
  }
  
  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
  }

  void updateRating(int rating) {
    selectedRating.value = rating;
  }

  void resetFilters() {
    selectedCategory.value = 'All';
    minPrice.value = 0.0;
    // Re-calculate max price or set to a safe default
    if (productList.isNotEmpty) {
       double maxFound = 0;
        for (var p in productList) {
          if (p.priceCents / 100 > maxFound) maxFound = p.priceCents / 100;
        }
        maxPrice.value = maxFound;
    } else {
      maxPrice.value = 10000.0;
    }
    selectedRating.value = 0;
    searchQuery.value = '';
  }

  List<Product> get filteredAndSortedProducts {
    final category = selectedCategory.value.toLowerCase();
    final query = searchQuery.value.trim().toLowerCase();

    List<Product> filtered = productList.where((product) {
      final productPrice = product.priceCents / 100;
      
      final matchesCategory =
          category == 'all' ||
          product.category.toLowerCase().contains(category);
      
      final matchesSearch = query.isEmpty || [
        product.name,
        product.category,
        product.subCategory,
        product.description,
        ...product.keywords,
      ].join(' ').toLowerCase().contains(query);

      final matchesPrice = productPrice >= minPrice.value && productPrice <= maxPrice.value;
      
      final matchesRating = selectedRating.value == 0 || product.rating.stars >= selectedRating.value;

      return matchesCategory && matchesSearch && matchesPrice && matchesRating;
    }).toList();

    // Apply sorting
    switch (selectedSortOption.value) {
      case SortOption.popularity:
        filtered.sort((a, b) => b.rating.count.compareTo(a.rating.count));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.priceCents.compareTo(b.priceCents));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.priceCents.compareTo(a.priceCents));
        break;
    }

    return filtered;
  }
}
