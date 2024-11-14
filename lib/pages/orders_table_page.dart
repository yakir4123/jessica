import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/providers.dart';

class OrdersTablePage extends ConsumerWidget {
  const OrdersTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataServiceProvider);
    if (data == null) {
      return const Center(
        child: Text('No orders available'),
      );
    }

    final selectedSymbol = ref.watch(selectedSymbolProvider);

    return Scaffold(
      appBar: createAppBar(context, ref, selectedSymbol, data.routesParams),
      body:
      createRotatedOrdersTable(context, selectedSymbol, data.routesParams),
    );
  }

  AppBar createAppBar(BuildContext context, WidgetRef ref,
      String? selectedSymbol, List<RouteWithOrdersModel> routes) {
    return AppBar(
      title: DropdownButtonHideUnderline(
        // Hide the underline to match app bar style
        child: DropdownButton<String>(
          hint: Text(
            selectedSymbol ?? 'Select a symbol',
            style: const TextStyle(
                color: Colors.white), // Set text color to match app bar
          ),
          value: selectedSymbol,
          dropdownColor: Theme
              .of(context)
              .primaryColor,
          // Match app bar background color
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          // Set icon color
          onChanged: (String? newSymbol) {
            ref
                .read(selectedStrategyProvider.notifier)
                .state = null;
            ref
                .read(selectedSymbolProvider.notifier)
                .state = newSymbol;
          },
          items: routes.map((RouteWithOrdersModel route) {
            return DropdownMenuItem<String>(
              value: route.symbol,
              child: Text(route.symbol),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget createRotatedOrdersTable(BuildContext context, String? selectedSymbol,
      List<RouteWithOrdersModel> routes) {
    if (selectedSymbol == null) {
      return const Center();
    }
    List<StrategyOrderModel> orders = routes
        .firstWhere((route) => route.symbol == selectedSymbol)
        .routeOrders
        .orders;

    return Center(
      child: RotatedBox(
        quarterTurns: 1,
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            // Rounds the edges of the container
            border: Border.all(
              color: Theme
                  .of(context)
                  .cardColor,
              width: 2.0, // Set border width
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery
                    .of(context)
                    .size
                    .height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(1),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Theme
                            .of(context)
                            .cardColor,
                      ),
                      verticalInside: BorderSide(
                        color: Theme
                            .of(context)
                            .cardColor,
                      ),
                    ),
                    children: [
                      TableRow(
                        children: [
                          headerCell('Strategy ID'),
                          headerCell('Qty'),
                          headerCell('Ratio Qty'),
                          headerCell('Price'),
                          headerCell('Timestamp'),
                          headerCell('Is Mimic'),
                          headerCell('Align State'),
                          headerCell('Type'),
                          headerCell('Is Executed'),
                        ],
                      ),
                      ...orders.map((order) => TableRow(
                        children: [
                          dataCell(order.strategyId.toString()),
                          dataCell(order.qty.toString()),
                          dataCell(order.ratioQty.toString()),
                          dataCell(order.price.toString()),
                          dataCell(order.timestamp.toString()),
                          dataCell(order.isMimic ? 'Yes' : 'No'),
                          dataCell(order.alignState.toString()),
                          dataCell(order.type.toString()),
                          dataCell(order.isExecuted ? 'Yes' : 'No'),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget dataCell(String data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        data,
        textAlign: TextAlign.center,
      ),
    );
  }
}
