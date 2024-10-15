import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/services/portfolio_weights_provider.dart';
import 'package:jessica/widgets/portfolio_chart_widget.dart';

class GeneralCharts extends ConsumerWidget {
  GeneralCharts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsyncValue = ref.watch(portfolioWeightsProvider);
    return portfolioAsyncValue.when(data: (Map<String, dynamic> data) {
      Map<String, num> symbolize_df = PortfolioWeightsService.preProcess(data);
      return PortfolioChartWidget(symbolize_df: symbolize_df);
    }, error: (Object error, StackTrace stackTrace) {
      return Center(child: Text('Error: $error'));
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }
}
