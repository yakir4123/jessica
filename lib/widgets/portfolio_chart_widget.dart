import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:jessica/services/portfolio_weights_provider.dart';

class PortfolioChartWidget extends StatefulWidget {
  final Map<num, Map<String, dynamic>> symbolizeDf;

  const PortfolioChartWidget({super.key, required this.symbolizeDf});

  @override
  _PortfolioChartWidgetState createState() => _PortfolioChartWidgetState();
}

class _PortfolioChartWidgetState extends State<PortfolioChartWidget> {
  late List<_ChartData> lineChartData;
  late List<_PieData> pieChartData;
  late List<String> symbols;
  late Map<String, bool> selectedSymbols;

  @override
  void initState() {
    super.initState();
    lineChartData = _generateLineChartData(widget.symbolizeDf);
    pieChartData = _generatePieChartData(widget.symbolizeDf);
    symbols = {for (var item in lineChartData) item.symbol}.toList();

    // Initialize all symbols as visible
    selectedSymbols = {for (var symbol in symbols) symbol: true};
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pie Chart
          Expanded(
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<_PieData, String>(
                  dataSource: pieChartData
                      .where((data) => selectedSymbols[data.symbol]!)
                      .toList(),
                  xValueMapper: (_PieData data, _) => data.symbol,
                  yValueMapper: (_PieData data, _) => data.value,
                  pointColorMapper: (_PieData data, _) =>
                      _getColor(data.symbol),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          const SizedBox(height: 16.0), // Spacing between charts
          // Stacked Area Chart

          FittedBox(
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 1,
              ),
              series: <ChartSeries>[
                for (String symbol in symbols)
                  if (selectedSymbols[symbol]!)
                    StackedAreaSeries<_ChartData, DateTime>(
                      dataSource: lineChartData
                          .where((data) => data.symbol == symbol)
                          .toList(),
                      xValueMapper: (_ChartData data, _) => data.timestamp,
                      yValueMapper: (_ChartData data, _) => data.weight,
                      pointColorMapper: (_ChartData data, _) =>
                          _getColor(data.symbol),
                      color: _getColor(symbol),
                      name: symbol,
                    ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          const SizedBox(height: 16.0), // Spacing
          Wrap(
            alignment: WrapAlignment.center,
            children: symbols.map((symbol) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSymbols[symbol] = !selectedSymbols[symbol]!;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedSymbols[symbol]!
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: _getColor(symbol),
                    ),
                    const SizedBox(width: 4),
                    Text(symbol, style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            }).toList(),
          ),
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
        }[symbol] ??
        Color.fromARGB(
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
