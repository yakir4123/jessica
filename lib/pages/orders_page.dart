import 'package:flutter/material.dart';
import 'package:jessica/widgets/order_card.dart';

class OrdersPage extends StatelessWidget {
  final Map<String, dynamic> data;

  OrdersPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> ordersData = {};
    try {
      ordersData = Map<String, dynamic>.from(data["orders"]);
    } catch (e) {
      // Handle error if needed
    }

    List<Widget> orderWidgets = ordersData.entries.map((entry) {
      String key = entry.key;
      if (key == 'current-price') { // just hotfix
        return OrderCard(
          title: key,
          orderList: [{"price": entry.value, "qty": 0, "dollar": 0}],
        );
      }
      List<dynamic> orderList = List<dynamic>.from(entry.value);
      orderList.sort((a, b) => (a["price"] ?? 0).compareTo(b["price"] ?? 0));

      return OrderCard(
        title: key,
        orderList: orderList,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ordersData.isEmpty
          ? const Center(
              child: Text(
                'No orders available',
              ),
            )
          : ListView(children: orderWidgets),
    );
  }
}
