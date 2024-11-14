import 'package:intl/intl.dart';
import 'package:jessica/services/portfolio_weights_provider.dart';
import 'package:jessica/utils.dart';
import 'package:flutter/material.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/widgets/attribute_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StrategyCardsParams extends ConsumerWidget {
  final double availableWidth;

  const StrategyCardsParams({super.key, required this.availableWidth});

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

    final portfolioAsyncValue = ref.watch(portfolioWeightsProvider);
    final cardData = createCardsData(
        route.schedulerParams.strategies[selectedStrategy]!,
        route.schedulerParams.balanceAllocator.allocations[selectedStrategy]);
    List<AttributeCard> sortedEntries =
        arrangeWidgets(cardData.entries.map((entry) {
      return AttributeCard(
        name: entry.key,
        value: entry.value,
      );
    }).toList());

    portfolioAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (portfolioWeights) {
        // Add additional AttributeCard widgets from the fetched portfolio weights
        if (portfolioWeights.keys.isEmpty) {
          return;
        }
        num maxKey = portfolioWeights.keys.reduce((a, b) => a > b ? a : b);
        final weight = portfolioWeights[maxKey]![selectedStrategy];

        sortedEntries.add(AttributeCard(
          name: 'portfolio-weight',
          value: formatDouble(weight),
        )
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0, // Space between cards horizontally
        runSpacing: 8.0, // Space between cards vertically when wrapping
        children: sortedEntries,
      ),
    );
  }

  List<AttributeCard> arrangeWidgets(List<AttributeCard> widgets) {
    List<AttributeCard> sortedWidgets = List.from(widgets);
    sortedWidgets.sort((a, b) => b.compareTo(a));
    List<_Line> lines = [];

    for (AttributeCard widget in sortedWidgets) {
      bool placed = false;

      // Try to place the widget in the best-fitting line
      _Line? bestLine;
      double minSpaceLeft = double.infinity;

      for (_Line line in lines) {
        double spaceLeft = line.remainingSpace - widget.estimatedWidthOfCard();
        if (spaceLeft >= 0 && spaceLeft < minSpaceLeft) {
          minSpaceLeft = spaceLeft;
          bestLine = line;
        }
      }

      if (bestLine != null) {
        bestLine.widgets.add(widget);
        bestLine.remainingSpace -= widget.estimatedWidthOfCard();
        placed = true;
      }

      if (!placed) {
        _Line newLine = _Line(availableWidth);
        newLine.widgets.add(widget);
        newLine.remainingSpace -= widget.estimatedWidthOfCard();
        lines.add(newLine);
      }
    }

    // Flatten the lines into a single ordered list of widgets
    List<AttributeCard> orderedWidgets = [];
    for (_Line line in lines) {
      orderedWidgets.addAll(line.widgets);
    }

    return orderedWidgets;
  }

  Map<String, String> createCardsData(
      MiniStrategyParamsModel params, BalanceAllocationEntryModel? allocation) {
    final dataFormat = DateFormat('yyyy-MM-dd HH:mm');
    Map<String, String> res = {};
    if (params.position.allOrders.isNotEmpty) {
      res['in-position'] = '';
    }
    if (params.expiration > 0) {
      res['position-expire-at'] = dataFormat.format(
          DateTime.fromMillisecondsSinceEpoch(params.expiration.toInt()));
    }
    if (params.entryExpiration > 0 &&
        (params.buy.isNotEmpty || params.sell.isNotEmpty)) {
      res['entry-expire-at'] = dataFormat.format(
          DateTime.fromMillisecondsSinceEpoch(params.entryExpiration.toInt()));
    }
    for (var entry in params.extraData.entries) {
      res.addAll(createCardsDataFromExtra(entry));
    }
    if (allocation == null) {
      return res;
    }
    res.addAll(flattenList('orders', params.position.allOrders));
    res['qty allocated'] = formatDouble(allocation.qtyAllocation);
    res['dollar allocated'] = formatDouble(allocation.dollarAllocation);
    res['used allocation'] = formatDouble(allocation.usedAllocated);
    res['reserved allocation'] = formatDouble(allocation.reservedAllocation);
    res['free allocation'] = formatDouble(allocation.freeAllocation);
    return res;
  }

  Map<String, String> createCardsDataFromExtra(
      MapEntry<String, dynamic> extraData) {
    Map<String, String> result = {};

    if (extraData.value is Map) {
      result.addAll(flattenMap(extraData.key, extraData.value as Map));
    } else if (extraData.value is List) {
      // If the value is a list, use the helper to flatten with indexing
      result.addAll(flattenList(extraData.key, extraData.value as List));
    } else if (extraData.value is double) {
      result[extraData.key] = formatDouble(extraData.value);
    } else {
      // If the value is not a Map, add it directly
      result[extraData.key] = '${extraData.value}';
    }
    return result;
  }

  Map<String, String> flattenMap(String prefix, Map<dynamic, dynamic> map) {
    Map<String, String> flatMap = {};

    map.forEach((key, value) {
      String newKey = '$prefix.$key';

      if (value is Map) {
        flatMap.addAll(flattenMap(newKey, value));
      } else if (value is List) {
        flatMap.addAll(flattenList(newKey, value));
      } else if (value is double) {
        flatMap[newKey] = formatDouble(value);
      } else {
        flatMap[newKey] = '$value';
      }
    });

    return flatMap;
  }

  Map<String, String> flattenList(String prefix, List<dynamic> list) {
    Map<String, String> flatMap = {};

    for (int i = 0; i < list.length; i++) {
      String newKey = '$prefix.$i'; // Use index as part of the key

      if (list[i] is Map) {
        flatMap.addAll(flattenMap(newKey, list[i]));
      } else if (list[i] is List) {
        flatMap.addAll(flattenList(newKey, list[i]));
      } else if (list[i] is double) {
        flatMap[newKey] = formatDouble(list[i]);
      } else if (list[i] is OrderModel){
        flatMap['$newKey.qty'] = formatDouble(list[i].qty);
        flatMap['$newKey.price'] = formatDouble(list[i].price);
      } else {
        flatMap[newKey] = '${list[i]}';
      }
    }

    return flatMap;
  }

  String formatDouble(double value) {
    if (value == 0.0) return "0";
    String valueStr = value.toString();
    int firstSignificantDigitIndex =
        valueStr.indexOf(RegExp(r'[1-9]'), valueStr.indexOf('.') + 1);

    int decimalPlaces =
        (firstSignificantDigitIndex - valueStr.indexOf('.')).clamp(1, 20) + 2;

    String formattedValue = value.toStringAsFixed(decimalPlaces);
    while (formattedValue.contains('.') && formattedValue.endsWith('0')) {
      formattedValue = formattedValue.substring(0, formattedValue.length - 1);
    }
    if (formattedValue.endsWith('.')) {
      formattedValue = formattedValue.substring(0, formattedValue.length - 1);
    }
    return formattedValue;
  }
}

class _Line {
  double remainingSpace;
  List<AttributeCard> widgets;

  _Line(this.remainingSpace) : widgets = [];
}
