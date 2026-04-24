import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Order Shipped",
      "message": "Your order #1234 has been shipped",
      "time": "2 min ago",
      "isRead": false,
      "icon": Icons.local_shipping,
    },
    {
      "title": "Big Sale!",
      "message": "Flat 50% off on fashion items",
      "time": "1 hour ago",
      "isRead": true,
      "icon": Icons.local_offer,
    },
    {
      "title": "Order Delivered",
      "message": "Your order #5678 has been delivered",
      "time": "Yesterday",
      "isRead": true,
      "icon": Icons.check_circle,
    },
  ];

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Container(
            color: item['isRead'] ? Colors.white : Colors.blue.shade50,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(item['icon'], color: Colors.blue),
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  fontWeight: item['isRead']
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              subtitle: Text(item['message']),
              trailing: Text(
                item['time'],
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                // Navigate to details
                debugPrint("Clicked ${item['title']}");
              },
            ),
          );
        },
      ),
    );
  }
}
