// Define a provider to track the selected strategy
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/utils.dart';

class StrategyDropdown extends ConsumerWidget {
  const StrategyDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSymbol = ref.watch(selectedSymbolProvider);
    final routes = ref.watch(dataServiceProvider)?.routesParams;
    final route = getRouteFromSymbol(routes, selectedSymbol!)!;
    final strategies = route.schedulerParams.strategies;
    final selectedStrategyKey = ref.watch(selectedStrategyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Theme.of(context).cardColor,
            textTheme: TextTheme(
              titleMedium: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(
              selectedStrategyKey ?? 'Select a strategy',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            value: selectedStrategyKey,
            onChanged: (String? newKey) {
              ref.read(selectedStrategyProvider.notifier).state = newKey;
            },
            items: strategies.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
