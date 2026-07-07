import 'package:flutter/material.dart';
import 'package:Shopsy/models/product_model.dart';
import 'package:Shopsy/repositories/product_api.dart';
import 'package:get/get.dart';

enum SortOption { popularity, priceLowToHigh, priceHighToLow }

class ProductController extends GetxController {
  final List<Product> _allFetchedProducts = [];
  final productList = <Product>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();
  
  // Pagination state
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Filter & Search state
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final selectedSortOption = SortOption.popularity.obs;
  
  // Advanced Filter state
  final minPrice = 0.0.obs;
  final maxPrice = 5000.0.obs; 
  final maxPriceLimit = 5000.0.obs; // Absolute limit for UI
  final selectedRating = 0.obs; // 0 means any rating

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
    
    // Sync text controller with observable
    searchController.addListener(() {
      if (searchQuery.value != searchController.text) {
        updateSearchQuery(searchController.text);
      }
    });

    // Setup scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMoreProducts();
      }
    });
  }

  Future<void> fetchProducts({bool force = false}) async {
    if (isLoading.value || (!force && _allFetchedProducts.isNotEmpty)) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      _currentPage = 1;
      hasMore.value = true;

      final products = await ProductApi.fetchProducts();
      _allFetchedProducts.assignAll(products);
      
      _updatePriceLimits(products);
      _applyFiltersAndPagination();
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreProducts() {
    if (isMoreLoading.value || !hasMore.value || isLoading.value) return;

    isMoreLoading.value = true;
    
    // Simulate network delay for pagination feel
    Future.delayed(const Duration(milliseconds: 500), () {
      _currentPage++;
      _applyFiltersAndPagination();
      isMoreLoading.value = false;
    });
  }

  void _applyFiltersAndPagination() {
    final filtered = _getFilteredAndSortedList();
    
    int endIndex = _currentPage * _itemsPerPage;

    if (endIndex >= filtered.length) {
      endIndex = filtered.length;
      hasMore.value = false;
    } else {
      hasMore.value = true;
    }

    final paginatedItems = filtered.sublist(0, endIndex);
    productList.assignAll(paginatedItems);
  }

  List<Product> _getFilteredAndSortedList() {
    final category = selectedCategory.value.toLowerCase();
    final query = searchQuery.value.trim().toLowerCase();

    List<Product> filtered = _allFetchedProducts.where((product) {
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

  void _updatePriceLimits(List<Product> products) {
    if (products.isNotEmpty) {
      double maxFound = 0;
      for (var p in products) {
        double price = p.priceCents / 100;
        if (price > maxFound) maxFound = price;
      }
      
      double limit = (maxFound / 100).ceil() * 100.0;
      if (limit < 100) limit = 5000.0; 
      
      maxPriceLimit.value = limit;
      if (maxPrice.value == 5000.0 || maxPrice.value > limit) {
        maxPrice.value = limit;
      }
    }
  }

  void selectCategory(String category) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      _resetPaginationAndApply();
    }
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
    if (searchController.text != value) {
      searchController.text = value;
    }
    _resetPaginationAndApply();
  }

  void updateSortOption(SortOption option) {
    selectedSortOption.value = option;
    _resetPaginationAndApply();
  }
  
  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
    _resetPaginationAndApply();
  }

  void updateRating(int rating) {
    selectedRating.value = rating;
    _resetPaginationAndApply();
  }

  void resetFilters() {
    selectedCategory.value = 'All';
    minPrice.value = 0.0;
    maxPrice.value = maxPriceLimit.value;
    selectedRating.value = 0;
    searchQuery.value = '';
    searchController.clear();
    _resetPaginationAndApply();
  }

  void _resetPaginationAndApply() {
    _currentPage = 1;
    hasMore.value = true;
    _applyFiltersAndPagination();
  }

  List<Product> get filteredAndSortedProducts => productList;

  // Added sections for Home Page
  List<Product> get dealsOfDay => _allFetchedProducts.take(4).toList();
  List<Product> get recommendedProducts => _allFetchedProducts.length > 4 
      ? _allFetchedProducts.skip(4).toList() 
      : [];

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
