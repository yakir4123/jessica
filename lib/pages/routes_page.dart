import 'package:jessica/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/widgets/equity_curve.dart';
import 'package:jessica/widgets/general_card.dart';
import 'package:jessica/widgets/strategy_cards_params/strategy_cards_params.dart';
import 'package:jessica/widgets/strategy_dropdown.dart';
import 'package:jessica/widgets/strategy_orders_table.dart';

class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSymbol = ref.watch(selectedSymbolProvider);

    return Scaffold(
        appBar: createAppBar(context, ref, selectedSymbol),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              final double availableWidth = constraints.maxWidth;
              return SingleChildScrollView(
                  child: SizedBox(
                      height: 1000,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: (selectedSymbol == null)
                            ? []
                            : [
                                buildPrecisionRow(ref, selectedSymbol),
                                // Conditionally add Row 1
                                const SizedBox(height: 16),
                                const StrategyDropdown(),
                                const SizedBox(height: 16),
                                const StrategyOrdersTable(),
                                const SizedBox(height: 16),
                                StrategyCardsParams(
                                    availableWidth: availableWidth),
                                const SizedBox(height: 16),
                                const EquityCurvePlot(),
                              ],
                      )));
            })));
  }

  AppBar createAppBar(
      BuildContext context, WidgetRef ref, String? selectedSymbol) {
    final routes = ref.watch(dataServiceProvider)?.routesParams;

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
          items: routes?.map((RouteWithOrdersModel route) {
            return DropdownMenuItem<String>(
              value: route.symbol,
              child: Text(route.symbol),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Function to build the Qty and Price Precision row
  Widget buildPrecisionRow(WidgetRef ref, String selectedSymbol) {
    final routes = ref.watch(dataServiceProvider)?.routesParams;
    final selectedRoute = getRouteFromSymbol(routes, selectedSymbol)!;
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GeneralCard(
              title: 'Qty Precision',
              subtitle: selectedRoute.schedulerParams.qtyPrecision.toString(),
              newLine: false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GeneralCard(
              title: 'Price Precision',
              subtitle: selectedRoute.schedulerParams.pricePrecision.toString(),
              newLine: false,
            ),
          ),
        ],
      ),
    );
  }
}
