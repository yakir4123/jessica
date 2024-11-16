import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColumnWidthsNotifier extends StateNotifier<List<double>> {
  ColumnWidthsNotifier() : super(List.filled(7, 1.0)); // Initialize with 7 columns, all width 1.0

  void incrementWidth(int index) {
    if (index >= 0 && index < state.length) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) state[i] + 0.1 else state[i],
      ];
    }
  }

  void decrementWidth(int index) {
    if (index >= 0 && index < state.length && state[index] > 0.1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) state[i] - 0.1 else state[i],
      ];
    }
  }
}

// Provider for the column widths
final logsTableColumnWidthsProvider =
StateNotifierProvider<ColumnWidthsNotifier, List<double>>(
        (ref) => ColumnWidthsNotifier());