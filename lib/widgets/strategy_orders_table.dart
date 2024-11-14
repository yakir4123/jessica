import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/utils.dart';

class StrategyOrdersTable extends ConsumerWidget {
  const StrategyOrdersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(dataServiceProvider)?.routesParams;
    final selectedSymbol = ref.watch(selectedSymbolProvider);
    final selectedStrategy = ref.watch(selectedStrategyProvider);
    if (selectedStrategy == null) {
      return const Text('');
    }
    final route = getRouteFromSymbol(routes, selectedSymbol!)!;
    final miniStrategy = route.schedulerParams.strategies[selectedStrategy];
    if (miniStrategy == null) {
      return const Text('');
    }
    final OrdersListModel buy = miniStrategy.buy;
    final OrdersListModel sell = miniStrategy.sell;
    final OrdersListModel takeProfit = miniStrategy.takeProfit;
    final OrdersListModel stopLoss = miniStrategy.stopLoss;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            // Rounds the edges of the container
            border: Border.all(
              color: Theme.of(context).cardColor,
              width: 2.0, // Set border width
            ),
          ),
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Theme.of(context).cardColor,
              ),
              verticalInside: BorderSide(
                color: Theme.of(context).cardColor,
              ),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              // Add header row
              TableRow(
                children: [
                  _buildTableCell(context, 'Type', isHeader: true),
                  _buildTableCell(context, 'Ratio Qty', isHeader: true),
                  _buildTableCell(context, 'Price', isHeader: true),
                ],
              ),
              ...buy.map(
                  (orderModel) => buildOrderRow(context, 'buy', orderModel)),
              ...sell.map(
                  (orderModel) => buildOrderRow(context, 'sell', orderModel)),
              ...takeProfit.map((orderModel) =>
                  buildOrderRow(context, 'take-profit', orderModel)),
              ...stopLoss.map((orderModel) =>
                  buildOrderRow(context, 'stop-loss', orderModel)),
            ],
          )),
    );
  }

  TableRow buildOrderRow(
      BuildContext context, String type, OrderModel orderModel) {
    return TableRow(
      children: [
        _buildTableCell(context, type),
        _buildTableCell(context, '${orderModel.qty}'),
        _buildTableCell(context, '${orderModel.price}'),
      ],
    );
  }

  Widget _buildTableCell(BuildContext context, String text,
      {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: isHeader
            ? (Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold))
            : Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
