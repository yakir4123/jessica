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
        height: 100,
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
            itemHeight: 110.0,
            alignment: Alignment.center,
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
            underline: const Divider(
              color: Colors.transparent,
            ),
            items: strategies.entries.map(
              (entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 94,
                          child: Center(
                            child: Text(
                              entry.key,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const Divider(), // Divider between items
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
