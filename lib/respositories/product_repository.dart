import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/productmodel.dart';

class ApiService {
  static const String url =
      "https://kolzsticks.github.io/Free-Ecommerce-Products-Api/main/products.json";

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
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
      throw "An unexpected error occurred: $e";
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
