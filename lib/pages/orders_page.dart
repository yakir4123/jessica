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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                route.symbol, // Display the title based on route.symbol
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

  // ordersData.forEach((key, value) {
  //   if (_selectedSeries[key] == false) {
  //     return; // Skip if the series is not selected
  //   }
  //   List<_OrderData> orderData = [];
  //   late List<dynamic> orderList;
  //   if (key == 'current-price') {
  //     orderList = List<dynamic>.from([
  //       {"price": value, "qty": 1, "dollars": 1}
  //     ]);
  //   } else {
  //     orderList = List<dynamic>.from(value);
  //   }
  //
  //   double medianSize = _calculateMedianSize(orderList, key);
  //   double baseSize = 15.0;
  //
  //   for (int i = 0; i < orderList.length; i++) {
  //     var order = orderList[i];
  //     double size = (order["qty"] / medianSize) * baseSize;
  //     orderData.add(_OrderData(i + 1, order["price"].toDouble(),
  //         order["qty"].toDouble(), size.toDouble()));
  //
  //     // Update min/max for axis range adjustments
  //     if (i + 1 < minX) minX = i + 1;
  //     if (i + 1 > maxX) maxX = i + 1;
  //     if (order["price"] < minY) minY = order["price"];
  //     if (order["price"] > maxY) maxY = order["price"];
  //   }
  //
  //   if (orderData.isNotEmpty) {
  //     series.add(BubbleSeries<_OrderData, num>(
  //       dataSource: orderData,
  //       xValueMapper: (_OrderData order, _) => order.index,
  //       yValueMapper: (_OrderData order, _) => order.price,
  //       sizeValueMapper: (_OrderData order, _) => order.size,
  //       color: _colorMap[key] ?? Colors.grey,
  //       // Use color from the map or default to grey
  //       name: key,
  //       markerSettings: MarkerSettings(
  //         isVisible: true,
  //         color: _colorMap[key] ??
  //             Colors.grey, // Use color from the map or default to grey
  //       ),
  //       onPointTap: (ChartPointDetails point) {
  //         _showOrderDetails(context, point.pointIndex ?? 0,
  //             point.seriesIndex ?? 0, orderData, key);
  //       },
  //     ));
  //
  //     seriesIndex++;
  //   }
  // });

  // if (series.isEmpty) {
  //   return Column(
  //     children: [
  //       const Expanded(
  //         child: Center(
  //           child: Text('Nothing to see'),
  //         ),
  //       ),
  //       Wrap(
  //         alignment: WrapAlignment.center,
  //         children: ordersData.keys
  //             .where((key) => key != 'current-price')
  //             .map((key) => Padding(
  //                   padding: const EdgeInsets.all(4.0),
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       minimumSize: const Size(
  //                           50, 30), // Reduce the size of the buttons
  //                       backgroundColor: _selectedSeries[key] == false
  //                           ? Colors.grey
  //                           : _colorMap[key] ?? Colors.grey,
  //                     ),
  //                     onPressed: () {
  //                       setState(() {
  //                         _selectedSeries[key] =
  //                             !(_selectedSeries[key] ?? true);
  //                       });
  //                     },
  //                     child: Text(
  //                         key.replaceAll("-", " ").replaceAll("orders", "")),
  //                   ),
  //                 ))
  //             .toList(),
  //       ),
  //     ],
  //   );
  // }
  //
  // return Column(
  //   children: [
  //     Expanded(
  //       child: Padding(
  //         padding: const EdgeInsets.all(5.0),
  //         child: SfCartesianChart(
  //           tooltipBehavior: TooltipBehavior(enable: false),
  //           series: series,
  //           primaryXAxis: NumericAxis(
  //             minimum: minX.isFinite
  //                 ? minX - 1
  //                 : 0, // Start a little before the first point
  //             maximum: maxX.isFinite
  //                 ? maxX + 1
  //                 : 1, // End a little after the last point
  //           ),
  //           primaryYAxis: NumericAxis(
  //             labelFormat: '{value}',
  //             minimum: minY.isFinite ? minY - (0.1 * (maxY - minY)) : 0,
  //             // Start a little below the lowest point
  //             maximum: maxY.isFinite ? maxY + (0.1 * (maxY - minY)) : 1,
  //             // End a little above the highest point
  //           ),
  //         ),
  //       ),
  //     ),
  //     Wrap(
  //       alignment: WrapAlignment.center,
  //       children: ordersData.keys
  //           .where((key) => key != 'current-price')
  //           .map((key) => Padding(
  //                 padding: const EdgeInsets.all(4.0),
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     minimumSize: const Size(
  //                         50, 30), // Reduce the size of the buttons
  //                     backgroundColor: _selectedSeries[key] == false
  //                         ? Colors.grey
  //                         : _colorMap[key] ?? Colors.grey,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       _selectedSeries[key] =
  //                           !(_selectedSeries[key] ?? true);
  //                     });
  //                   },
  //                   child: Text(
  //                       key.replaceAll("-", " ").replaceAll("orders", "")),
  //                 ),
  //               ))
  //           .toList(),
  //     ),
  //   ],
  // );
  // }

  void _showOrderDetails(BuildContext context, StrategyOrderModel order) {
    String symbol = order.strategyId.split("--")[2];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(symbol),
          content: Text({
            'Strategy': order.strategyId,
            'qty': order.qty,
            'ratioQty': order.ratioQty,
            'price': order.price,
            'timestamp': order.timestamp,
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
