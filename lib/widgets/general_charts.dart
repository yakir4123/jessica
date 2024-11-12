import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/portfolio_weights_provider.dart';
import 'package:jessica/widgets/portfolio_chart_widget.dart';

class GeneralCharts extends ConsumerWidget {
  const GeneralCharts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsyncValue = ref.watch(portfolioWeightsProvider);
    return portfolioAsyncValue.when(
        data: (Map<num, Map<String, dynamic>> data) {
      Map<num, Map<String, dynamic>> symbolizeDf =
          PortfolioWeightsService.preProcessStrategyAllocationSeries(data);
      return PortfolioChartWidget(symbolizeDf: symbolizeDf);
    }, error: (Object error, StackTrace stackTrace) {
      return Center(child: Text('Error: $error'));
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }
}
