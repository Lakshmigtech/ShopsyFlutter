import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/productcontroller.dart';
import 'package:Shopsy/views/TabBar/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'productdetail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  ProductController get productController => Get.find<ProductController>();
  CartController get cartController => Get.find<CartController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final products = productController.filteredAndSortedProducts;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Shopsy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.to(() => const CartScreen()),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart_outlined),
                          if (cartController.itemCount > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cartController.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    productController.updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: productController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              productController.updateSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _category(Icons.apps, 'All'),
                    _category(Icons.home, 'Home'),
                    _category(Icons.checkroom, 'Fashion'),
                    _category(Icons.laptop, 'Electronics'),
                    _category(Icons.brush, 'Beauty'),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/banner.jpg',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Deals of the Day',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      5,
                      (index) => Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Up to 60% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recommended for You',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (productController.isLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (productController.errorMessage.value != null)
                  Center(
                    child: Column(
                      children: [
                        Text(productController.errorMessage.value!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              productController.fetchProducts(force: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (products.isEmpty)
                  const Center(child: Text('No products match your filters'))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return GestureDetector(
                        onTap: () => Get.to(
                          () => const ProductDetailScreen(),
                          arguments: product,
                        ),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${(product.priceCents / 100).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _category(IconData icon, String title) {
    final isSelected = productController.selectedCategory.value == title;

    return GestureDetector(
      onTap: () => productController.selectCategory(title),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isSelected ? Colors.blue : Colors.blue.shade100,
            child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
