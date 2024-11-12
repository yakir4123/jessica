import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/widgets/positive_button.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OrdersPage extends ConsumerWidget {
  final void Function() navigateToRoutesPage;

  const OrdersPage({required this.navigateToRoutesPage, super.key});

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
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold), // Optional styling
                ),
              ),
            ),
            ordersPlotWidget(context, ref, route, data.botParams.updateTime),
            // The plot widget
          ],
        );
      }).toList(),
    );
  }

  Widget ordersPlotWidget(BuildContext context, WidgetRef ref,
      RouteWithOrdersModel route, double updateTime) {
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

    List<IndexedOrder> indexedOrders = [];
    int timestampIndex = 0;
    double prevTimestamp = -1;
    for (var entry in sortedTOrders.asMap().entries) {
      if (entry.value.timestamp != prevTimestamp) {
        prevTimestamp = entry.value.timestamp;
        timestampIndex += 1;
      }
      indexedOrders.add(IndexedOrder(timestampIndex, entry.value));
    }

    List<ChartSeries<StrategyOrderModel, num>> series =
        partiallyFilledOrders(context, indexedOrders);
    series
        .addAll(filledOrders(context, ref, indexedOrders, maxPrice, minPrice));
    series.add(currentPrice(context, indexedOrders, routesOrders.currentPrice));

    Map<double, String> xLabels = getXLabels(indexedOrders);
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: false),
      series: series,
      primaryXAxis: NumericAxis(
        minimum: -1,
        maximum: timestampIndex.toDouble() + 1,
        majorGridLines: const MajorGridLines(width: 0),
        interval: 1,
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          // Custom logic to choose labels
          if (xLabels.containsKey(args.value)) {
            // Show only even labels, for example
            return ChartAxisLabel(xLabels[args.value]!, const TextStyle());
          } else {
            // Skip odd labels by returning an empty string
            return ChartAxisLabel('', const TextStyle());
          }
        },
      ),
      primaryYAxis: NumericAxis(
        minimum: minPrice,
        maximum: maxPrice,
      ),
    );
  }

  List<ChartSeries<StrategyOrderModel, num>> partiallyFilledOrders(
      BuildContext context, List<IndexedOrder> indexedOrders) {
    return indexedOrders
        .where((entry) => entry.order.ratioQty != 1)
        .map((entry) {
      int index = entry.index;
      StrategyOrderModel order = entry.order;
      double size = _getSize(order.qty, order.price);
      Color color = _getColor(order);
      DataMarkerType shape = _getShape(order);
      return ScatterSeries<StrategyOrderModel, num>(
          dataSource: [order],
          xValueMapper: (StrategyOrderModel o, _) => index,
          yValueMapper: (StrategyOrderModel o, _) => o.price,
          pointColorMapper: (StrategyOrderModel o, _) =>
              color.withOpacity(0.33),
          markerSettings: MarkerSettings(
            height: size,
            width: size,
            shape: shape,
          ));
    }).toList();
  }

  List<ChartSeries<StrategyOrderModel, num>> filledOrders(
      BuildContext context,
      WidgetRef ref,
      List<IndexedOrder> indexedOrders,
      double maxPrice,
      double minPrice) {
    return indexedOrders.map((entry) {
      int index = entry.index;
      StrategyOrderModel order = entry.order;
      double size = _getSize(order.qty, order.price);
      DataMarkerType shape = _getShape(order);
      return ScatterSeries<StrategyOrderModel, num>(
          dataSource: [order],
          xValueMapper: (StrategyOrderModel o, _) => index,
          yValueMapper: (StrategyOrderModel o, _) =>
              o.price -
              size * (1 - order.ratioQty) / 2 * (maxPrice - minPrice) / 276,
          pointColorMapper: (StrategyOrderModel o, _) => _getColor(o),
          markerSettings: MarkerSettings(
              height: size * order.ratioQty, width: size, shape: shape),
          onPointTap: (ChartPointDetails point) {
            _showOrderDetails(context, ref, order);
          });
    }).toList();
  }

  ChartSeries<StrategyOrderModel, num> currentPrice(
      BuildContext context, List<IndexedOrder> indexedOrders, double price) {
    int currTimestampIndex = 0;
    if (indexedOrders.isNotEmpty) {
      try {
        currTimestampIndex = indexedOrders
            .firstWhere((entry) => entry.order.strategyId == 'route')
            .index;
      } catch (e) {
        // in case there are only entry orders and its not in position
        currTimestampIndex = 0; // before index = 0
      }
    }
    return ScatterSeries<StrategyOrderModel, num>(
      dataSource: [
        StrategyOrderModel(
            strategyId: "",
            qty: 0,
            ratioQty: 0,
            price: 0,
            timestamp: 0,
            isMimic: false,
            alignState: AlignState.align,
            type: OrderType.buy,
            isExecuted: true)
      ],
      // fake an order for typing..
      xValueMapper: (StrategyOrderModel o, _) => currTimestampIndex,
      yValueMapper: (StrategyOrderModel o, _) => price,
      pointColorMapper: (StrategyOrderModel o, _) => Colors.grey,
      markerSettings: const MarkerSettings(
        height: 10,
        width: 10,
      ),
    );
  }

  Map<double, String> getXLabels(List<IndexedOrder> indexedOrders) {
    Map<double, String> mapIndexes = {};

    int positionIndex = -1;
    for (var entry in indexedOrders) {
      if (entry.order.strategyId == 'route') {
        positionIndex = entry.index;
      }
      mapIndexes[entry.index.toDouble()] =
          entry.date(); // Overwrites if x already exists
    }
    if (positionIndex == -1) {
      positionIndex = 0;
      mapIndexes[0] = DateFormat('HH:mm\ndd/MM').format(DateTime.now());
    }

    int modulo = 1 + indexedOrders.length ~/ 5;

    return Map.fromEntries(mapIndexes.entries
        .where((entry) => (entry.key - positionIndex) % modulo == 0));
  }

  DataMarkerType _getShape(StrategyOrderModel order) {
    if (order.alignState != AlignState.align) {
      return DataMarkerType.diamond;
    }
    if (order.isMimic) {
      return DataMarkerType.circle;
    }
    return DataMarkerType.rectangle;
  }

  Color _getColor(StrategyOrderModel order) {
    double opacity = 1;

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

  void _showOrderDetails(
      BuildContext context, WidgetRef ref, StrategyOrderModel order) {
    String title = order.strategyId;
    List<String> splittedStrategyId = order.strategyId.split("--");
    if (splittedStrategyId.length >= 3) {
      title = splittedStrategyId[2]; // Symbol
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title)), // Title on the left
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close the dialog when 'X' is pressed
                },
              ),
            ],
          ),
          content: Text({
            'Strategy': order.strategyId,
            'qty': order.qty,
            'ratioQty': order.ratioQty,
            'price': order.price,
            'Dollars': order.price * order.qty,
            'timestamp':
                DateTime.fromMillisecondsSinceEpoch(order.timestamp.toInt()),
            'isMimic': order.isMimic,
            'alignState': order.alignState.name,
            'type': order.type,
            'isExecuted': order.isExecuted,
          }.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n')),
          actions: <Widget>[
            PositiveButton(
              text: 'Go to',
              onPressed: () {
                goToRoutesPage(context, ref, order.strategyId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void goToRoutesPage(BuildContext context, WidgetRef ref, String strategyId) {
    final symbol = strategyId.split('--')[2];
    ref.read(selectedSymbolProvider.notifier).state = symbol;
    ref.read(selectedStrategyProvider.notifier).state = strategyId;

    (context as Element).markNeedsBuild(); // Trigger a rebuild if necessary
    navigateToRoutesPage();
  }
}

class IndexedOrder {
  IndexedOrder(this.index, this.order);

  final int index;
  final StrategyOrderModel order;

  String date() {
    return DateFormat('HH:mm\ndd/MM')
        .format(DateTime.fromMillisecondsSinceEpoch(order.timestamp.toInt()));
  }
}
