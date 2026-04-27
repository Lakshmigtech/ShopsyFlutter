import 'dart:convert';
import 'package:Shopsy/models/productmodel.dart';

class OrderModel {
  final String orderId;
  final List<OrderItem> items;
  final double totalAmount;
  final String address;
  final DateTime dateTime;
  final String status;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.dateTime,
    this.status = "Confirmed",
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((x) => x.toJson()).toList(),
      'totalAmount': totalAmount,
      'address': address,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      items: List<OrderItem>.from(
          json['items']?.map((x) => OrderItem.fromJson(x)) ?? []),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      address: json['address'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'] ?? "Confirmed",
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
