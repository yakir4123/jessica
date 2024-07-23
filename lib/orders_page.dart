import 'package:flutter/material.dart';
import 'custom_theme_extension.dart';


class OrdersPage extends StatelessWidget {
  final Map<String, dynamic> data;

  OrdersPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> orders_data = {};
    try {
      orders_data = data["orders"];
    } catch(e) {}
    List<Widget> keysWidgets = [];

    orders_data.forEach((key, value) {
      value.sort((a, b) {
        num priceA = a["price"] ?? 0;
        num priceB = b["price"] ?? 0;
        return priceA.compareTo(priceB);
      });
      keysWidgets.add(
        Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ExpansionTile(
            title: Text(key),
            children: (value as List).map<Widget>((tuple) {
              if (tuple.length == 3) {
                String qty = tuple["qty"].toString();
                String price = tuple["price"].toString();
                String dollar = tuple["dollars"].toString();
                return ListTile(
                  subtitle: Text("qty: $qty\nprice: $price\ndollar: $dollar",
                    style: Theme.of(context).listTileLeading,
                  ),
                );
              }
              return SizedBox.shrink();
            }).toList(),
          ),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: keysWidgets,
      ),
    );
  }
}