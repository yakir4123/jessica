import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:jessica/services/portfolio_weights_provider.dart';

class PortfolioChartWidget extends StatelessWidget {
  final Map<num, Map<String, dynamic>> symbolize_df;

  PortfolioChartWidget({required this.symbolize_df});

  @override
  Widget build(BuildContext context) {
    List<_ChartData> lineChartData = _generateLineChartData(symbolize_df);
    List<_PieData> pieChartData = _generatePieChartData(symbolize_df);

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
                  xValueMapper: (_PieData data, _) => data.category,
                  yValueMapper: (_PieData data, _) => data.value,

                  pointColorMapper: (_PieData data, _) =>
                      _getRandomColor(), // Random color for each pie slice
                ),
              ],
              tooltipBehavior:
              TooltipBehavior(enable: true), // Tooltip on hover
            ),
          ),
          const SizedBox(height: 16.0), // Spacing between charts
          // Stacked Area Chart
          SfCartesianChart(
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            primaryXAxis: NumericAxis(
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            primaryYAxis: NumericAxis(),
            series: <ChartSeries>[
              // Dynamic series creation from symbolize_df data
              StackedAreaSeries<_ChartData, double>(
                dataSource: lineChartData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                name: 'Series 1',
                color: _getRandomColor(), // Random color for the series
              ),
              StackedAreaSeries<_ChartData, double>(
                dataSource: lineChartData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y2,
                name: 'Series 2',
                color: _getRandomColor(), // Random color for the series
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true), // Tooltip on hover
          ),
        ],
      ),
    );
  }

  // Generate line chart data from symbolize_df
  List<_ChartData> _generateLineChartData(Map<num, Map<String, dynamic>> data) {
    List<_ChartData> chartData = [];
    // int index = 0;
    // for (var entry in data.entries) {
    //   chartData.add(_ChartData(index.toDouble(), entry.value.toDouble(),
    //       entry.value.toDouble() * 0.9)); // Simulate y2 as 90% of y
    //   index++;
    // }
    return chartData;
  }

  // Generate pie chart data from symbolize_df
  List<_PieData> _generatePieChartData(Map<num, Map<String, dynamic>> allocationSeries) {
    List<_PieData> pieData = [];
    Map<String, dynamic> latestAllocation = PortfolioWeightsService.getLatestAllocation(allocationSeries);
    for (var entry in latestAllocation.entries) {
      pieData.add(_PieData(entry.key, entry.value.toDouble()));
    }
    return pieData;
  }

  // Function to generate random colors
  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256), // Random red value
      random.nextInt(256), // Random green value
      random.nextInt(256), // Random blue value
    );
  }
}

// Chart Data Model
class _ChartData {
  _ChartData(this.x, this.y, this.y2);
  final double x;
  final double y;
  final double y2;
}

// Pie Chart Data Model
class _PieData {
  _PieData(this.category, this.value);
  final String category;
  final double value;
}
