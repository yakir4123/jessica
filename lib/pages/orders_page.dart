import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  Map<String, bool> _selectedSeries = {};

  // Define the color map for each key
  final Map<String, Color> _colorMap = {
    "buy-orders": Colors.orange,
    "sell-orders": Colors.yellow,
    "take-profit-orders": Colors.green,
    "stop-loss-orders": Colors.red,
    "average-entry": Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
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

      if (_selectedSeries[key] == false) {
        return; // Skip if the series is not selected
      }

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
        color: _colorMap[key] ??
            Colors.grey, // Use color from the map or default to grey
        name: key,
        markerSettings: MarkerSettings(
          isVisible: true,
          color: _colorMap[key] ??
              Colors.grey, // Use color from the map or default to grey
        ),
        onPointTap: (ChartPointDetails point) {
          _showOrderDetails(context, point.pointIndex ?? 0,
              point.seriesIndex ?? 0, orderData, key);
        },
      ));

      seriesIndex++;
    });

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: series.isNotEmpty
                ? SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(enable: false),
                    series: series,
                    primaryXAxis: NumericAxis(
                      minimum:
                          minX - 1, // Start a little before the first point
                      maximum: maxX + 1, // End a little after the last point
                    ),
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value}',
                      minimum: minY - (0.1 * (maxY - minY)),
                      // Start a little below the lowest point
                      maximum: maxY +
                          (0.1 *
                              (maxY -
                                  minY)), // End a little above the highest point
                    ),
                  )
                : const Center(
                    child: Text('Nothing to see'),
                  ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: ordersData.keys
              .where((key) => key != 'current-price')
              .map((key) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                            50, 30), // Reduce the size of the buttons
                        backgroundColor: _selectedSeries[key] == false
                            ? Colors.grey
                            : _colorMap[key] ?? Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedSeries[key] =
                              !(_selectedSeries[key] ?? true);
                        });
                      },
                      child: Text(
                          key.replaceAll("-", " ").replaceAll("orders", "")),
                    ),
                  ))
              .toList(),
        ),
      ],
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

  @override
  void initState() {
    super.initState();
    // Initialize _selectedSeries with true for all keys
    final data = ref.read(dataServiceProvider);

    Map<String, dynamic> ordersData = {};
    try {
      ordersData = Map<String, dynamic>.from(data["orders"]);
    } catch (e) {
      // Handle error if needed
    }
    setState(() {
      ordersData.keys.where((key) => key != 'current-price').forEach((key) {
        _selectedSeries[key] = true;
      });
    });
  }
}

class _OrderData {
  _OrderData(this.index, this.price, this.quantity, this.size);

  final int index;
  final double price;
  final double quantity;
  final double size;
}
