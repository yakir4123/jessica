import 'package:intl/intl.dart';
import 'package:jessica/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/widgets/attribute_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StrategyCardsParams extends ConsumerWidget {
  const StrategyCardsParams({super.key});

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
    final cardData =
        createCardsData(route.schedulerParams.strategies[selectedStrategy]!);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0, // Space between cards horizontally
        runSpacing: 8.0, // Space between cards vertically when wrapping
        children: cardData.entries.map((entry) {
          return AttributeCard(
            name: entry.key,
            value: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Map<String, String> createCardsData(MiniStrategyParamsModel params) {
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
      } else {
        flatMap[newKey] = '${list[i]}';
      }
    }

    return flatMap;
  }

  String formatDouble(double value) {
    if (value == 0.0) return "0";
    String valueStr = value.toString();
    int firstSignificantDigitIndex = valueStr.indexOf(RegExp(r'[1-9]'), valueStr.indexOf('.') + 1);

    int decimalPlaces = (firstSignificantDigitIndex - valueStr.indexOf('.')).clamp(1, 20) + 2;

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
