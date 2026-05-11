import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/views/tabbar/productlist.dart';
import 'package:Shopsy/views/tabbar/cart.dart';
import 'package:Shopsy/views/tabbar/home.dart';
import 'package:Shopsy/views/account/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  NavigationController get controller => Get.find<NavigationController>();

  static const List<Widget> pages = [
    HomePage(),
    ProductScreen(),
    CartScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: controller.changeIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
