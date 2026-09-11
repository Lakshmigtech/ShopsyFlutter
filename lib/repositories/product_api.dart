import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductApi {
  // Use raw.githubusercontent.com for more reliable direct JSON access
  static const String url =
      "https://raw.githubusercontent.com/kolzsticks/Free-Ecommerce-Products-Api/main/products.json";

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        
        List<dynamic> productList = [];
        
        if (decodedData is List) {
          productList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('products')) {
          productList = decodedData['products'];
        } else if (decodedData is Map) {
          // Fallback: if it's a map but doesn't have 'products', look for any list
          productList = decodedData.values.firstWhere((v) => v is List, orElse: () => []) as List;
        }

        // Log the raw product list for debugging
        log("Fetched Raw Product List: ${json.encode(productList)}");

        if (productList.isEmpty) return [];

        final products = productList.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        
        // Print individual product details for easy verification in logs
        print("---------- PRODUCT LOG START ----------");
        print("Total Products: ${products.length}");
        for (var i = 0; i < products.length; i++) {
          final p = products[i];
          print("[$i] ID: ${p.id} | Name: ${p.name} | Price: ₹${p.price}");
        }
        print("---------- PRODUCT LOG END ----------");

        return products;
      } else {
        throw _handleError(response.statusCode);
      }
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Please try again.";
    } on FormatException {
      throw "Invalid data format received from server.";
    } catch (e) {
      throw "Failed to load products: $e";
    }
  }

  static String _handleError(int statusCode) {
    switch (statusCode) {
      case 404:
        return "Products not found (404).";
      case 500:
        return "Internal Server Error (500). Please try again later.";
      case 503:
        return "Service Unavailable. Server might be down.";
      default:
        return "Failed to load products. Error: $statusCode";
    }
  }
}
