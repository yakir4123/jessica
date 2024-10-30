import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OrdersPage extends ConsumerWidget {
  final Map<String, Color> _colorMap = {
    "buy": Colors.orange,
    "sell": Colors.yellow,
    "take_profit": Colors.green,
    "stop_loss": Colors.red,
    "average_entry": Colors.blue,
    "current_price": Colors.white,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataServiceProvider);
    if (data == null) {
      return const Center(
        child: Text('No orders available'),
      );
    }
    List<RouteWithOrdersModel> routes = data.routesParams;

    if (routes.isEmpty) {
      return const Center(
        child: Text('No orders available'),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: routes.map((route) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center, // Centers the title horizontally
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  route.symbol, // Display the title based on route.symbol
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Optional styling
                ),
              ),
            ),
            ordersPlotWidget(context, route, data.botParams.updateTime),
            // The plot widget
          ],
        );
      }).toList(),
    );
  }

  Widget ordersPlotWidget(
      BuildContext context, RouteWithOrdersModel route, double updateTime) {
    RouteOrdersModel routesOrders = route.routeOrders;
    List<StrategyOrderModel> sortedTOrders =
        routesOrders.orders.where((order) => order.timestamp != 0).toList();
    sortedTOrders.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Find the minimum and maximum prices
    double minPrice = sortedTOrders.isNotEmpty
        ? sortedTOrders
            .map((order) => order.price)
            .reduce((a, b) => a < b ? a : b)
        : 0.0;
    minPrice = min(routesOrders.currentPrice, minPrice);
    double maxPrice = sortedTOrders.isNotEmpty
        ? sortedTOrders
            .map((order) => order.price)
            .reduce((a, b) => a > b ? a : b)
        : 1.0;
    maxPrice = max(routesOrders.currentPrice, maxPrice);
    minPrice = minPrice - 0.05 * (maxPrice - minPrice);
    maxPrice = maxPrice + 0.05 * (maxPrice - minPrice);

    List<IndexedOrder> indexedOrders =
        sortedTOrders.asMap().entries.map((entry) {
      return IndexedOrder(entry.key, entry.value);
    }).toList();
    List<ChartSeries<StrategyOrderModel, num>> series =
        sortedTOrders.asMap().entries.map((entry) {
      int index = entry.key;
      StrategyOrderModel order = entry.value;
      double size = _getSize(order.qty, order.price);
      return ScatterSeries<StrategyOrderModel, num>(
          dataSource: [order],
          xValueMapper: (StrategyOrderModel o, _) => index,
          yValueMapper: (StrategyOrderModel o, _) => o.price,
          pointColorMapper: (StrategyOrderModel o, _) => _getColor(o),
          markerSettings: MarkerSettings(
            height: size,
            width: size,
              shape: order.alignState == AlignState.align ? DataMarkerType.circle : DataMarkerType.rectangle
          ),
          onPointTap: (ChartPointDetails point) {
            _showOrderDetails(context, order);
          });
    }).toList();

    int currTimestampIndex = 0;
    if (indexedOrders.isNotEmpty) {
      try {
        currTimestampIndex = indexedOrders
            .firstWhere((entry) => entry.order.strategyId == 'route')
            .index;
      } catch (e) {
        // in case there are only entry orders and its not in position
        currTimestampIndex = -1; // before index = 0
      }
    }
    if (sortedTOrders.isNotEmpty) {
      series.add(ScatterSeries<StrategyOrderModel, num>(
        dataSource: [sortedTOrders[0]],
        // fake an order for typing..
        xValueMapper: (StrategyOrderModel o, _) => currTimestampIndex,
        yValueMapper: (StrategyOrderModel o, _) => routesOrders.currentPrice,
        pointColorMapper: (StrategyOrderModel o, _) => Colors.grey,
        markerSettings: const MarkerSettings(
          height: 10,
          width: 10,
        ),
      ));
    }

    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: false),
      series: series,
      primaryXAxis: NumericAxis(
        minimum: -1.5,
        maximum: sortedTOrders.length.toDouble(),
        majorGridLines: const MajorGridLines(width: 0),
        isVisible: false,
      ),
      primaryYAxis: NumericAxis(
        minimum: minPrice,
        maximum: maxPrice,
      ),
    );
  }

  Color _getColor(StrategyOrderModel order) {
    double opacity = order.isMimic ? 1 : 0.5;

    if (order.isExecuted) {
      return Colors.blue.withOpacity(opacity);
    }

    switch (order.type) {
      case OrderType.buy:
        return Colors.orange.withOpacity(opacity);
      case OrderType.sell:
        return Colors.yellow.withOpacity(opacity);
      case OrderType.take_profit:
        return Colors.green.withOpacity(opacity);
      case OrderType.stop_loss:
        return Colors.red.withOpacity(opacity);
      default:
        return Colors.grey.withOpacity(opacity);
    }
  }

  double _getSize(double qty, double price) {
    double value = qty * price;
    // scale dollar allocation (0 -> 25)
    // scale dollar allocation (5000 -> 100)
    return (value / 5000) * (100 - 15) + 15;
  }

  void _showOrderDetails(BuildContext context, StrategyOrderModel order) {
    String title = order.strategyId;
    List<String> splittedStrategyId = order.strategyId.split("--");
    if (splittedStrategyId.length >= 3) {
      title = splittedStrategyId[2]; // Symbol
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text({
            'Strategy': order.strategyId,
            'qty': order.qty,
            'ratioQty': order.ratioQty,
            'price': order.price,
            'timestamp':  DateTime.fromMillisecondsSinceEpoch(order.timestamp.toInt()),
            'isMimic': order.isMimic,
            'alignState': order.alignState.name,
            'type': order.type,
            'isExecuted': order.isExecuted,
          }.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n')),
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
}

class IndexedOrder {
  IndexedOrder(this.index, this.order);

  final int index;
  final StrategyOrderModel order;
}
