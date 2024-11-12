import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jessica/models/equity_curves.dart';

// Define a class to interact with the server
class EquityCurvesService {
  List<EquityCurvesModel>? cache;
  Map<String, EquityCurvesModel>? hashedCache;
  DateTime cacheTimestamp = DateTime(1970);

  final String _baseUrl =
      "http://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}";

  Future<List<EquityCurvesModel>> fetchEquityCurves() async {
    if (cache != null &&
        (DateTime.now().difference(cacheTimestamp) <
            const Duration(minutes: 10))) {
      return cache!;
    }

    final String url = '$_baseUrl/equity-curves';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);

        // Map each JSON object to an EquityCurvesModel instance
        List<EquityCurvesModel> equityCurves = jsonList
            .map((json) => EquityCurvesModel.fromJson(json as Map<String, dynamic>))
            .toList();
        cache = equityCurves;
        cacheTimestamp = DateTime.now();
        _processCache();
        return equityCurves;
      } else {
        print(
            'Failed to load portfolio weights. Status code: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching portfolio weights: $error');
      return [];
    }
  }

  List<double>? getEquityCurve(String strategyId) {
    if (hashedCache == null) {
      return null;
    }
    return hashedCache![strategyId]?.values;
  }

  void _processCache() {
    // Check if cache is null or empty, return null if so
    if (cache == null || cache!.isEmpty) return;

    // Convert the list to a map with strategyId as the key
    hashedCache = {
      for (var equityCurve in cache!) equityCurve.strategyId: equityCurve
    };
  }
}

final equityCurvesServiceProvider = Provider<EquityCurvesService>((ref) {
  return EquityCurvesService();
});

final equityCurvesProvider =
    FutureProvider<Map<String, EquityCurvesModel>?>((ref) async {
  final service = ref.watch(equityCurvesServiceProvider);
  await service.fetchEquityCurves();
  return service.hashedCache;
});
