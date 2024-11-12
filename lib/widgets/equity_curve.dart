import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jessica/services/providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/equity_curves_provider.dart';

class EquityCurvePlot extends ConsumerWidget {
  const EquityCurvePlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _equityCurvesProvider = ref.watch(equityCurvesProvider);
    final strategyId = ref.watch(selectedStrategyProvider);
    if (strategyId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _equityCurvesProvider.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (equityCurvesMap) {
        if (equityCurvesMap == null || equityCurvesMap.isEmpty) {
          return const Center(child: Text('No data available from server.'));
        }
        final equityCurve = equityCurvesMap[strategyId];
        if (equityCurve == null || equityCurve.values.isEmpty) {
          return const Center(
              child: Text('No data available for this strategy.'));
        }
        final dataPoints = equityCurve.values
            .asMap()
            .entries
            .map((entry) => ChartData(x: entry.key, y: entry.value))
            .toList();

        double minY = equityCurve.values.reduce((a, b) => a < b ? a : b);
        double maxY = equityCurve.values.reduce((a, b) => a > b ? a : b);
        double YAxisSize = (maxY - minY);
        minY = YAxisSize == 0 ? 0.9 : minY - 0.1 * YAxisSize;
        maxY = YAxisSize == 0 ? 1.1 : maxY + 0.1 * YAxisSize;
        return Column(children: [
          Text(
            'Equity Value',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                title: AxisTitle(text: 'Time'),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
              ),
              primaryYAxis: NumericAxis(
                minimum: minY,
                maximum: maxY,
                interval: YAxisSize == 0 ? 0.1 : (maxY - minY) / 6,
              ),
              series: <LineSeries<ChartData, String>>[
                LineSeries<ChartData, String>(
                  dataSource: dataPoints,
                  xValueMapper: (ChartData data, _) =>
                      getDateMinusDays(dataPoints.length - data.x - 1),
                  yValueMapper: (ChartData data, _) => data.y,
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary, // Line color as text color
                ),
              ],
            ),
          )
        ]);
      },
    );
  }

  String getDateMinusDays(int i) {
    DateTime today = DateTime.now();
    DateTime targetDate = today.subtract(Duration(days: i));
    String formattedDate = DateFormat('dd/MM').format(targetDate);
    return formattedDate;
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData({required this.x, required this.y});
}
