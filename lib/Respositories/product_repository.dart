import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/productmodel.dart';

class ApiService {
  static const String url =
      "https://kolzsticks.github.io/Free-Ecommerce-Products-Api/main/products.json";

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }
}
