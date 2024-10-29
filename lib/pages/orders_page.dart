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
            ordersPlotWidget(context, route, data.botParams.updateTime), // The plot widget
          ],
        );
      }).toList(),
    );
  }

  Widget ordersPlotWidget(BuildContext context, RouteWithOrdersModel route, double updateTime) {
    RouteOrdersModel routesOrders = route.routeOrders;
    List<StrategyOrderModel> sortedTOrders =
        routesOrders.orders.where((order) => order.timestamp != 0).toList();
    sortedTOrders.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Find the minimum and maximum prices
    double minPrice = sortedTOrders.isNotEmpty
        ? sortedTOrders.map((order) => order.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    minPrice = min(routesOrders.currentPrice, minPrice);
    double maxPrice = sortedTOrders.isNotEmpty
        ? sortedTOrders.map((order) => order.price).reduce((a, b) => a > b ? a : b)
        : 1.0;
    maxPrice = max(routesOrders.currentPrice, maxPrice);
    minPrice = minPrice - 0.05 * (maxPrice - minPrice);
    maxPrice = maxPrice + 0.05 * (maxPrice - minPrice);

    List<IndexedOrder> indexedOrders =
    sortedTOrders.asMap().entries.map((entry) {
      return IndexedOrder(entry.key, entry.value);
    }).toList();
    int currTimestampIndex = 0;
    if (indexedOrders.isNotEmpty) {
      try {
        currTimestampIndex = indexedOrders.firstWhere((entry) => entry.order.strategyId == 'route').index;
      } catch (e) {
        // in case there are only entry orders and its not in position
        currTimestampIndex = -1; // before index = 0
      }
    }
    List<ChartSeries<ChartData, num>> series = [
    BubbleSeries<ChartData, num>(
        dataSource: [ChartData(currTimestampIndex, routesOrders.currentPrice, 1)],
        xValueMapper: (ChartData cData, _) => cData.index,
        yValueMapper: (ChartData cData, _) => cData.price,
        sizeValueMapper: (ChartData cData, _) => cData.size,
        color: (_colorMap["current_price"] ?? Colors.grey).withOpacity(0.33)
    )
    ];
      for (var type in OrderType.values){
        series.add(addBubbleSeries(indexedOrders, type, true, false, _colorMap["average_entry"] ?? Colors.grey));
        for (var isMimic in [true, false]) {
          series.add(addBubbleSeries(indexedOrders, type, false, isMimic,
              _colorMap[type.name] ?? Colors.grey));
        }
    }

    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      series: series,
      primaryXAxis: NumericAxis(
        minimum: -1.5,
        maximum: sortedTOrders.length.toDouble(),
      ),
      primaryYAxis: NumericAxis(
        minimum: minPrice,
        maximum: maxPrice,
      ),
    );
  }


  BubbleSeries<ChartData, num> addBubbleSeries(List<IndexedOrder> indexedOrders, OrderType type, bool isExecuted, bool isMimic, Color color) {
    List<IndexedOrder> ordersOfType = indexedOrders
        .where((entry) => entry.order.isExecuted == isExecuted && entry.order.type == type && entry.order.isMimic == isMimic)
        .toList();
    List<ChartData> dataPoints = ordersOfType.map((entry) => ChartData(entry.index, entry.order.price, entry.order.qty)).toList();

    return BubbleSeries<ChartData, num>(
        dataSource: dataPoints,
        xValueMapper: (ChartData cData, _) => cData.index,
        yValueMapper: (ChartData cData, _) => cData.price,
        sizeValueMapper: (ChartData cData, _) => cData.size,
        color: color.withOpacity(isMimic ? 0.2 : 0.75)
    );
  }

  Color bubbleColor(StrategyOrderModel orderModel) {
    if (orderModel.isExecuted) {
      return _colorMap["average_entry"]
              ?.withOpacity(orderModel.isMimic ? 0.5 : 0.75) ??
          Colors.blue;
    }
    return _colorMap[orderModel.type.name]
            ?.withOpacity(orderModel.isMimic ? 0.5 : 0.75) ??
        Colors.grey;
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

  // void _showOrderDetails(BuildContext context, int pointIndex, int seriesIndex,
  //     List<_OrderData> orderData, String typeName) {
  //   final order = orderData[pointIndex];
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(typeName),
  //         content: Text(
  //             'Index: ${order.x}\nPrice: ${order.y}\nQuantity: ${order.size}'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(
  //               'Close',
  //               style:
  //                   TextStyle(color: Theme.of(context).colorScheme.secondary),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
}

class IndexedOrder {
  IndexedOrder(this.index, this.order);

  final int index;
  final StrategyOrderModel order;
}

class ChartData {
  ChartData(this.index, this.price, this.size);

  final int index;
  final double price;
  final double size;
}
