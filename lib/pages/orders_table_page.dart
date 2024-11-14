import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/widgets/bubble.dart';

OverlayEntry? _bubbleOverlayEntry;
Timer? _bubbleTimer;

class OrdersTablePage extends ConsumerWidget {
  final void Function() navigateToRoutesPage;

  const OrdersTablePage({super.key, required this.navigateToRoutesPage});

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
      body: createRotatedOrdersTable(
          context, ref, selectedSymbol, data.routesParams),
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
          dropdownColor: Theme.of(context).primaryColor,
          // Match app bar background color
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          // Set icon color
          onChanged: (String? newSymbol) {
            ref.read(selectedStrategyProvider.notifier).state = null;
            ref.read(selectedSymbolProvider.notifier).state = newSymbol;
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

  Widget createRotatedOrdersTable(BuildContext context, WidgetRef ref,
      String? selectedSymbol, List<RouteWithOrdersModel> routes) {
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
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            // Rounds the edges of the container
            border: Border.all(
              color: Theme.of(context).cardColor,
              width: 2.0, // Set border width
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    // Center-align vertically
                    columnWidths: const {
                      0: FlexColumnWidth(8),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(3),
                      4: FlexColumnWidth(3),
                      5: FlexColumnWidth(2),
                      6: FlexColumnWidth(2),
                      7: FlexColumnWidth(4),
                      8: FlexColumnWidth(2),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Theme.of(context).cardColor,
                      ),
                      verticalInside: BorderSide(
                        color: Theme.of(context).cardColor,
                      ),
                      bottom: BorderSide(
                        color: Theme.of(context).cardColor,
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
                      ...List.generate(orders.length, (index) {
                        final order = orders[index];
                        final isEvenRow = index.isEven;
                        return TableRow(
                          decoration: BoxDecoration(
                            color: isEvenRow
                                ? Theme.of(context)
                                    .highlightColor // Even row color
                                : Colors.transparent, // Default for odd rows
                          ),
                          children: [
                            dataCell(context, ref, order.strategyId, order.strategyId),
                            dataCell(context, ref, order.qty.toString(), order.strategyId),
                            dataCell(context, ref, order.ratioQty.toString(), order.strategyId),
                            dataCell(context, ref, order.price.toString(), order.strategyId),
                            dataCell(
                                context,
                                ref,
                                DateFormat('HH:mm dd/MM').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        order.timestamp.toInt())), order.strategyId),
                            dataCell(context, ref, order.isMimic ? '🤡' : '', order.strategyId),
                            dataCell(context, ref, order.alignState.name, order.strategyId),
                            dataCell(context, ref, order.type.name, order.strategyId),
                            dataCell(
                                context, ref, order.isExecuted ? 'Yes' : 'No', order.strategyId),
                          ],
                        );
                      }),
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

  Widget dataCell(BuildContext context, WidgetRef ref, String data, String strategyId) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          _showBubbleOverlay(context, ref, details.globalPosition, strategyId);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            data,
            textAlign: TextAlign.center,
          ),
        ));
  }

  void _showBubbleOverlay(
      BuildContext context, WidgetRef ref, Offset position, String strategyId) {
    _removeBubbleOverlay();
    final overlay = Overlay.of(context);
    _bubbleOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 60, // Position the bubble above the tap
        child: BubbleWidget(
          onTap: () => goToRoutesPage(context, ref, strategyId),
          icon: const Icon(
            Icons.arrow_downward, // Customize with any icon
            color: Colors.white,
          ),
        ),
      ),
    );

    overlay.insert(_bubbleOverlayEntry!);

    _bubbleTimer = Timer(const Duration(seconds: 5), () {
      _removeBubbleOverlay();
    });
  }

  void _removeBubbleOverlay() {
    _bubbleOverlayEntry?.remove();
    _bubbleOverlayEntry = null;
    _bubbleTimer?.cancel();
    _bubbleTimer = null;
  }

  void goToRoutesPage(BuildContext context, WidgetRef ref, String strategyId) {
    final symbol = strategyId.split('--')[2];
    ref.read(selectedSymbolProvider.notifier).state = symbol;
    ref.read(selectedStrategyProvider.notifier).state = strategyId;

    (context as Element).markNeedsBuild(); // Trigger a rebuild if necessary
    navigateToRoutesPage();
    _removeBubbleOverlay();
  }
}
