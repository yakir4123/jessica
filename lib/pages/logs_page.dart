import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/logs_table_provider.dart';
import 'package:jessica/services/providers.dart';

class LogsTablePage extends ConsumerWidget {
  const LogsTablePage({super.key});

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
      body: createBody(context, ref, selectedSymbol),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //pass
        },
        child:  Transform.rotate(
          angle: 90 * (3.141592653589793 / 180), // Convert 90 degrees to radians
          child: const Icon(Icons.search),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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

  Widget createBody(BuildContext context, WidgetRef ref,
      String? selectedSymbol) {
    if (selectedSymbol == null) {
      return const Center();
    }

    final columnWidths = ref.watch(logsTableColumnWidthsProvider);
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
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    // Center-align vertically
                    columnWidths: {
                      for (int i = 0; i < columnWidths.length; i++)
                        i: FlexColumnWidth(columnWidths[i]),
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
                      bottom: BorderSide(
                        color: Theme
                            .of(context)
                            .cardColor,
                      ),
                    ),
                    children: [
                      TableRow(
                        children: [
                          headerCell(context, ref, 'System Time', 0),
                          headerCell(context, ref, 'Timestamp', 1),
                          headerCell(context, ref, 'Exchange', 2),
                          headerCell(context, ref, 'Symbol', 3),
                          headerCell(context, ref, 'module', 4),
                          headerCell(context, ref, 'msg', 5),
                          headerCell(context, ref, 'extra', 6),
                        ],
                      ),
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

  Widget headerCell(BuildContext context, WidgetRef ref, String label,
      int index) {
    return GestureDetector(
      onDoubleTap: () {
        ref.read(logsTableColumnWidthsProvider.notifier).incrementWidth(index);
      },
      onLongPress: () {
        ref.read(logsTableColumnWidthsProvider.notifier).decrementWidth(index);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}

