import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Define a class to interact with the server
class PortfolioWeightsService {
  final String _baseUrl =
      "http://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}";

  Future<Map<num, Map<String, dynamic>>> fetchPortfolioWeights() async {
    final String url = '$_baseUrl/portfolio-weights';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<num, Map<String, dynamic>> portfolioAllocationSeries = {
          for (var key in data.keys) double.parse(key): data[key]
        };
        return portfolioAllocationSeries;
      } else {
        print(
            'Failed to load portfolio weights. Status code: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      print('Error fetching portfolio weights: $error');
      return {};
    }
  }

  static Map<String, dynamic> getLatestAllocation(Map<num, Map<String, dynamic>> seriesDf) {
    if (seriesDf.isEmpty) return {};
      num highestKey = seriesDf.keys.reduce((a, b) => a > b ? a : b);
      return seriesDf[highestKey] ?? {};
  }

  static Map<num,  Map<String, dynamic>> preProcessStrategyAllocationSeries(Map<num, Map<String, dynamic>> seriesDf) {
    return seriesDf.map((key, value) {
      return MapEntry(key, preProcessStrategyAllocation(value));
    });
  }

  static Map<String, num> preProcessStrategyAllocation(Map<String, dynamic> df) {
    Set<String> symbols = df.keys
        .map((k) {
          List<String> parts = k.split('--');
          return parts.length > 2 ? parts[2] : '';
        })
        .where((s) => s.isNotEmpty)
        .toSet();

    // Initialize a map to hold the summed values for each symbol
    Map<String, num> symbolValues = {for (var s in symbols) s: 0};

    // Step 2: Sum the values for each symbol
    for (String col in df.keys) {
      for (String s in symbols) {
        if (col.contains(s)) {
          num dfValue = df[col]!; // df[col] cannot be null
          num currentSum = symbolValues[s]!; // symbolValues[s] cannot be null
          symbolValues[s] = currentSum + dfValue;
        }
      }
    }

    // symbolValues now contains the summed values per symbol
    return symbolValues;
  }
}

// Create a provider for PortfolioWeightsService
final portfolioWeightsServiceProvider =
    Provider<PortfolioWeightsService>((ref) {
  return PortfolioWeightsService();
});

// Create a FutureProvider for fetching portfolio weights
final portfolioWeightsProvider =
    FutureProvider<Map<num, Map<String, dynamic>>>((ref) async {
  final service = ref.watch(portfolioWeightsServiceProvider);
  return await service.fetchPortfolioWeights();
});
