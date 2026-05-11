import 'package:Shopsy/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.clearAll(),
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Clear All",
          )
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  "No notifications yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];

            return Container(
              color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead 
                      ? Colors.grey.shade200 
                      : Colors.blue.shade100,
                  child: Icon(
                    notification.isRead ? Icons.notifications_none : Icons.notifications_active, 
                    color: notification.isRead ? Colors.grey : Colors.blue
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification.message, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(notification.dateTime),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                onTap: () => controller.markAsRead(index),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addNotification(
            "Sample Notification", 
            "This is a test notification generated locally."
          );
        },
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}
