import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:jessica/services/providers.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataServiceProvider);
    Map<String, dynamic> ordersData = {};
    try {
      ordersData = Map<String, dynamic>.from(data["orders"]);
    } catch (e) {
      // Handle error if needed
    }

    if (ordersData.isEmpty) {
      return const Center(
        child: Text('No orders available'),
      );
    }

    List<ChartSeries<_OrderData, num>> series = [];
    int seriesIndex = 0;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    ordersData.forEach((key, value) {
      if (key == 'current-price') return;

      List<_OrderData> orderData = [];
      List<dynamic> orderList = List<dynamic>.from(value);

      double medianSize = _calculateMedianSize(orderList, key);
      double baseSize = 15.0;

      for (int i = 0; i < orderList.length; i++) {
        var order = orderList[i];
        double size = (order["qty"] / medianSize) * baseSize;
        orderData.add(_OrderData(i + 1, order["price"], order["qty"], size));

        // Update min/max for axis range adjustments
        if (i + 1 < minX) minX = i + 1;
        if (i + 1 > maxX) maxX = i + 1;
        if (order["price"] < minY) minY = order["price"];
        if (order["price"] > maxY) maxY = order["price"];
      }

      series.add(BubbleSeries<_OrderData, num>(
        dataSource: orderData,
        xValueMapper: (_OrderData order, _) => order.index,
        yValueMapper: (_OrderData order, _) => order.price,
        sizeValueMapper: (_OrderData order, _) => order.size,
        color: _getColor(seriesIndex),
        name: key,
        markerSettings: MarkerSettings(
          isVisible: true,
          color: _getColor(seriesIndex),
        ),
        onPointTap: (ChartPointDetails point) {
          _showOrderDetails(context, point.pointIndex ?? 0,
              point.seriesIndex ?? 0, orderData, key);
        },
      ));

      seriesIndex++;
    });

    // Adjusting the axis range
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SfCartesianChart(
        legend: Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: false),
        series: series,
        primaryXAxis: NumericAxis(
          minimum: minX - 1, // Start a little before the first point
          maximum: maxX + 1, // End a little after the last point
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '{value}',
          minimum: minY -
              (0.1 * (maxY - minY)), // Start a little below the lowest point
          maximum: maxY +
              (0.1 * (maxY - minY)), // End a little above the highest point
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, int pointIndex, int seriesIndex,
      List<_OrderData> orderData, String typeName) {
    final order = orderData[pointIndex];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(typeName),
          content: Text(
              'Index: ${order.index}\nPrice: ${order.price}\nQuantity: ${order.quantity}'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  double _calculateMedianSize(List<dynamic> orderList, String key) {
    if (key == 'buy') {
      var sizes = orderList.map((order) => order["qty"]).toList();
      sizes.sort();
      int middle = sizes.length ~/ 2;
      if (sizes.length % 2 == 0) {
        return (sizes[middle - 1] + sizes[middle]) / 2.0;
      } else {
        return sizes[middle].toDouble();
      }
    }
    return 1.0; // Default value if key is not 'buy'
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return Colors.yellow;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.white70;
      default:
        return Colors.red;
    }
  }
}

class _OrderData {
  _OrderData(this.index, this.price, this.quantity, this.size);
  final int index;
  final double price;
  final double quantity;
  final double size;
}
