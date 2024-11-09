import 'package:flutter/material.dart';
import 'package:jessica/services/providers.dart';
import 'package:jessica/widgets/general_card.dart';
import 'package:jessica/widgets/general_charts.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneralParamsPage extends ConsumerWidget {
  GeneralParamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MinutelyOutputModel? data = ref.watch(dataServiceProvider);

    final botStateModel = data?.botParams ??
        BotStateModel(
          balance: 0.0,
          todayPnl: 0.0,
          updateTime: 0,
          availableMargin: 0.0,
        );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: 1050,
          child: Column(
            children: [
              SizedBox(
                height: 350,
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
                      subtitle: DateTime.fromMillisecondsSinceEpoch(
                              botStateModel.updateTime.toInt())
                          .toString(),
                    ),
                    GeneralCard(
                      title: "today-pnl",
                      subtitle: botStateModel.todayPnl.toStringAsFixed(1),
                    ),
                    GeneralCard(
                      title: "balance",
                      subtitle: botStateModel.balance.toStringAsFixed(1),
                    ),
                    GeneralCard(
                      title: "available-margin",
                      subtitle:
                          botStateModel.availableMargin.toStringAsFixed(1),
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
}
