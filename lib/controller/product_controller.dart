import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product_model.dart';
import '../models/sort_option.dart';
import '../utils/product_ui_helper.dart';
import '../repositories/product_api.dart';

class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 5000.0.obs;
  final RxDouble maxPriceLimit = 5000.0.obs;
  final RxInt selectedRating = 0.obs;
  final Rx<SortOption> selectedSortOption = SortOption.popularity.obs;

  // Search related
  final TextEditingController searchController = TextEditingController();
  final RxInt currentHintIndex = 0.obs;
  final List<String> searchHints = ProductUIHelper.searchHints;
  Timer? _hintTimer;

  @override
  void onInit() {
    super.onInit();
    _startHintTimer();
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    _hintTimer?.cancel();
    super.onClose();
  }

  void _startHintTimer() {
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      currentHintIndex.value = (currentHintIndex.value + 1) % searchHints.length;
    });
  }

  List<Product> get filteredAndSortedProducts {
    return ProductUIHelper.filterAndSortProducts(
      products: products,
      category: selectedCategory.value,
      query: searchQuery.value,
      minPrice: minPrice.value,
      maxPrice: maxPrice.value,
      selectedRating: selectedRating.value,
      sortOption: selectedSortOption.value,
    );
  }

  // Exposed list of all products for the Home Page
  List<Product> get allProducts => products;
  
  // Alias for search results in UI
  List<Product> get productList => filteredAndSortedProducts;

  List<Product> get dealsOfDay => products.take(4).toList();
  List<Product> get recommendedProducts => products.length > 6 
      ? products.sublist(products.length - 6).reversed.toList() 
      : products.reversed.toList();

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
  }

  void updateRating(int rating) {
    selectedRating.value = rating;
  }

  void updateSortOption(SortOption option) {
    selectedSortOption.value = option;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void resetFilters() {
    selectedCategory.value = 'All';
    minPrice.value = 0;
    maxPrice.value = maxPriceLimit.value;
    selectedRating.value = 0;
    selectedSortOption.value = SortOption.popularity;
    searchQuery.value = '';
    searchController.clear();
  }

  Future<void> fetchProducts({bool force = false}) async {
    if (products.isNotEmpty && !force) return;
    
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final fetchedProducts = await ProductApi.fetchProducts();
      
      if (fetchedProducts.isEmpty) {
        // Fallback to mock data if API is empty
        products.assignAll(_getMockProducts());
      } else {
        products.assignAll(fetchedProducts);
      }
      
      // Automatically adjust price limit based on fetched products
      if (products.isNotEmpty) {
        double highestPrice = products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
        maxPriceLimit.value = highestPrice > 0 ? highestPrice : 5000.0;
        maxPrice.value = maxPriceLimit.value;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Error fetching products: $e");
      // Load mock data on error so the app is still usable
      if (products.isEmpty) {
        products.assignAll(_getMockProducts());
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: 'mock-1',
        name: 'Wireless Bluetooth Headphones',
        image: 'https://images.pexels.com/photos/3394651/pexels-photo-3394651.jpeg',
        priceCents: 4500,
        category: 'Electronics',
        subCategory: 'Audio',
        description: 'High-quality wireless headphones with noise cancellation.',
        rating: Rating(stars: 4.5, count: 250),
        keywords: ['headphones', 'wireless', 'audio'],
      ),
      Product(
        id: 'mock-2',
        name: 'Running Sports Shoes',
        image: 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
        priceCents: 3200,
        category: 'Fashion',
        subCategory: 'Footwear',
        description: 'Comfortable running shoes for daily exercise.',
        rating: Rating(stars: 4.2, count: 180),
        keywords: ['shoes', 'running', 'sports'],
      ),
      Product(
        id: 'mock-3',
        name: 'Smart Watch Series 5',
        image: 'https://images.pexels.com/photos/437037/pexels-photo-437037.jpeg',
        priceCents: 12000,
        category: 'Electronics',
        subCategory: 'Wearables',
        description: 'Track your health and notifications with this smart watch.',
        rating: Rating(stars: 4.8, count: 500),
        keywords: ['watch', 'smartwatch', 'wearable'],
      ),
      Product(
        id: 'mock-4',
        name: 'Cotton Casual T-Shirt',
        image: 'https://images.pexels.com/photos/4066290/pexels-photo-4066290.jpeg',
        priceCents: 999,
        category: 'Fashion',
        subCategory: 'Clothing',
        description: '100% cotton casual t-shirt for summer.',
        rating: Rating(stars: 4.0, count: 320),
        keywords: ['tshirt', 'cotton', 'casual'],
      ),
      Product(
        id: 'mock-5',
        name: 'Ceramic Coffee Mug',
        image: 'https://images.pexels.com/photos/1566308/pexels-photo-1566308.jpeg',
        priceCents: 499,
        category: 'Home',
        subCategory: 'Kitchen',
        description: 'Beautiful ceramic mug for your morning coffee.',
        rating: Rating(stars: 4.6, count: 150),
        keywords: ['mug', 'coffee', 'home'],
      ),
      Product(
        id: 'mock-6',
        name: 'Mechanical Gaming Keyboard',
        image: 'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg',
        priceCents: 5500,
        category: 'Electronics',
        subCategory: 'Computer Accessories',
        description: 'RGB mechanical keyboard for the best gaming experience.',
        rating: Rating(stars: 4.7, count: 420),
        keywords: ['keyboard', 'gaming', 'rgb'],
      ),
    ];
  }
}
