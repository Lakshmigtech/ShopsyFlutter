import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  Widget paymentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDefault = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 15),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          /// DEFAULT BADGE
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Default",
                style: TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// APPBAR
      appBar: AppBar(
        title: const Text("Payment Methods"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// MAIN CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                paymentTile(
                  icon: Icons.credit_card,
                  title: "Visa Card",
                  subtitle: "**** 4589",
                  isDefault: true,
                ),

                const Divider(),

                paymentTile(
                  icon: Icons.qr_code,
                  title: "Google Pay",
                  subtitle: "lakshmi@upi",
                ),

                const Divider(),

                paymentTile(
                  icon: Icons.money,
                  title: "Cash on Delivery",
                  subtitle: "Pay at your doorstep",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ADD PAYMENT METHOD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    "Add Payment Method",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
