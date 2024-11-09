import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:jessica/services/portfolio_weights_provider.dart';

class PortfolioChartWidget extends StatelessWidget {
  final Map<num, Map<String, dynamic>> symbolizeDf;

  const PortfolioChartWidget({super.key, required this.symbolizeDf});

  @override
  Widget build(BuildContext context) {
    List<_ChartData> lineChartData = _generateLineChartData(symbolizeDf);
    List<_PieData> pieChartData = _generatePieChartData(symbolizeDf);

    List<String> strategyIds =
        {for (var item in lineChartData) item.symbol}.toList();

    return SizedBox(
      height: 700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pie Chart
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(color: Colors.white),
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              series: <CircularSeries>[
                PieSeries<_PieData, String>(
                    dataSource: pieChartData,
                    xValueMapper: (_PieData data, _) => data.symbol,
                    yValueMapper: (_PieData data, _) => data.value,
                    pointColorMapper: (_PieData data, _) =>
                        _getColor(data.symbol)),
              ],
              tooltipBehavior:
                  TooltipBehavior(enable: true), // Tooltip on hover
            ),
          ),
          const SizedBox(height: 16.0), // Spacing between charts
          SfCartesianChart(
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            primaryXAxis: DateTimeAxis(),
            // Ensures DateTime values are expected on the X-axis
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 1,
            ),
            series: <ChartSeries>[
              for (String strategyId in strategyIds)
                StackedAreaSeries<_ChartData, DateTime>(
                    dataSource: lineChartData
                        .where((data) => data.symbol == strategyId)
                        .toList(),
                    xValueMapper: (_ChartData data, _) => data.timestamp,
                    yValueMapper: (_ChartData data, _) => data.weight,
                    pointColorMapper: (_ChartData data, _) =>
                        _getColor(data.symbol)),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          )
          // Stacked Area Chart
        ],
      ),
    );
  }

  // Generate line chart data from symbolize_df
  List<_ChartData> _generateLineChartData(Map<num, Map<String, dynamic>> data) {
    List<_ChartData> chartDataList = [];

    data.forEach((timestamp, strategyMap) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
      strategyMap.forEach((symbol, weight) {
        chartDataList.add(_ChartData(dateTime, symbol, weight.toDouble()));
      });
    });

    return chartDataList;
  }

  // Generate pie chart data from symbolize_df
  List<_PieData> _generatePieChartData(
      Map<num, Map<String, dynamic>> allocationSeries) {
    List<_PieData> pieData = [];
    Map<String, dynamic> latestAllocation =
        PortfolioWeightsService.getLatestAllocation(allocationSeries);
    for (var entry in latestAllocation.entries) {
      pieData.add(_PieData(entry.key, entry.value.toDouble()));
    }
    return pieData;
  }

  // Function to generate random colors
  Color _getColor(String symbol) {
    final Random random = Random();
    return {
      'TRX-USDT': Colors.red,
      'UNI-USDT': Colors.pinkAccent,
      'SAND-USDT': Colors.yellow,
      'LINK-USDT': Colors.deepPurple,
      'HBAR-USDT': Colors.black26,
      'GRT-USDT': Colors.deepPurpleAccent,
      'ETH-USDT': Colors.blueGrey,
      'DOT-USDT': Colors.pink,
      'DOGE-USDT': Colors.brown,
      'CHZ-USDT': Colors.redAccent,
      'DASH-USDT': Colors.lightBlueAccent,

    }[symbol] ?? Color.fromARGB(
      255,
      random.nextInt(256), // Random red value
      random.nextInt(256), // Random green value
      random.nextInt(256), // Random blue value
    );
  }
}

// Chart Data Model
class _ChartData {
  final DateTime timestamp;
  final String symbol;
  final double weight;

  _ChartData(this.timestamp, this.symbol, this.weight);
}

// Pie Chart Data Model
class _PieData {
  _PieData(this.symbol, this.value);

  final String symbol;
  final double value;
}
