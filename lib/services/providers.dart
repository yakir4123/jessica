import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_service.dart';

final dataServiceProvider =
    StateNotifierProvider<DataService, Map<String, dynamic>>((ref) {
  final dataService = DataService();
  ref.onDispose(() {
    dataService.dispose();
  });
  return dataService;
});
