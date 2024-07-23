import 'package:flutter/material.dart';
import 'order_text.dart'; // Import the OrderText widget

class OrderCard extends StatelessWidget {
  final String title;
  final List<dynamic> orderList;

  const OrderCard({
    super.key,
    required this.title,
    required this.orderList,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          children: orderList.map<Widget>((tuple) {
            if (tuple.length == 3) {
              String qty = tuple["qty"].toString();
              String price = tuple["price"].toString();
              String dollar = tuple["dollars"].toString();

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OrderText(text: "qty: $qty"),
                    OrderText(text: "price: $price"),
                    OrderText(text: "dollar: $dollar"),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ),
      ),
    );
  }
}
