import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/widgets/general_card.dart';

class GeneralParamsPage extends ConsumerWidget {
  Map<String, dynamic> globalParamsData = {};

  GeneralParamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataServiceProvider);
    try {
      globalParamsData = data["general"];
    } catch (e) {
      // Handle error if needed
      globalParamsData = {
        "update-time": 0,
        "today-pnl": 0,
        "balance": 0,
        "available-margin": 0,
        "pnl": 0
      };
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 16.0, // Horizontal spacing between grid items
                mainAxisSpacing: 16.0, // Vertical spacing between grid items
                childAspectRatio:
                    6 / 4, // Ratio of width to height for each grid item
              ),
              itemCount: globalParamsData.length,
              itemBuilder: (context, index) {
                String key = globalParamsData.keys.elementAt(index);
                return GeneralCard(
                  title: key,
                  subtitle: formatItem(key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatItem(String key) {
    if (key == "update-time"){
      return DateTime.fromMillisecondsSinceEpoch(globalParamsData["update-time"].toInt()).toString();
    }
    return globalParamsData[key].toStringAsFixed(1);
  }
}
