import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/widgets/general_card.dart';
import 'package:jessica/widgets/general_charts.dart';

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
      child: SingleChildScrollView(
        child: SizedBox(
          height: 1000,
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing:
                        16.0, // Horizontal spacing between grid items
                    mainAxisSpacing:
                        16.0, // Vertical spacing between grid items
                    childAspectRatio:
                        6 / 4, // Ratio of width to height for each grid item
                  ),
                  children: [
                    GeneralCard(
                      title: "update-time",
                      subtitle: formatItem("update-time"),
                    ),
                    Card(
                      elevation: 4, // Adds shadow to the card
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                      margin: EdgeInsets.zero, // Remove margin from card
                      child: Padding(
                        padding: const EdgeInsets.all(
                            12.0), // Padding inside the card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "today-pnl",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                ),
                                Text(
                                  formatItem("today-pnl"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "pnl",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                ),
                                Text(
                                  formatItem("pnl"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    GeneralCard(
                      title: "balance",
                      subtitle: formatItem("balance"),
                    ),
                    GeneralCard(
                      title: "available-margin",
                      subtitle: formatItem("available-margin"),
                    ),
                  ],
                ),
              ),
              GeneralCharts(),
            ],
          ),
        ),
      ),
    );
  }

  String formatItem(String key) {
    if (key == "update-time") {
      return DateTime.fromMillisecondsSinceEpoch(
              globalParamsData["update-time"].toInt())
          .toString();
    }
    return globalParamsData[key].toStringAsFixed(1);
  }
}
