import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/audit_logs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColumnWidthsNotifier extends StateNotifier<List<double>> {
  ColumnWidthsNotifier()
      : super(List.filled(7, 1.0)); // Initialize with 7 columns, all width 1.0

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

class AuditLogsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AuditLogsNotifier() : super(const AsyncValue.loading());

  Future<void> requestLogs(List<AuditColumnSettings> columnSettings) async {
    final String baseUrl =
        "http://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}";
    final String url = '$baseUrl/logs';

    try {
      // Convert the list of AuditColumnSettings to JSON
      final body = columnSettings.map((e) => e.toJson()).toList();

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Parse the response as a list of AuditLogResponse
        final List<dynamic> jsonResponse = json.decode(response.body);
        final List<Map<String, dynamic>> logs =
            jsonResponse.map((json) => json as Map<String, dynamic>).toList();

        // Update the state with the parsed response
        state = AsyncValue.data(logs);
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      // Update the state with the error
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider for the column widths
final logsTableColumnWidthsProvider =
    StateNotifierProvider<ColumnWidthsNotifier, List<double>>(
        (ref) => ColumnWidthsNotifier());

// Provider for the PostRequestNotifier
final auditLogsNotifierProvider = StateNotifierProvider<AuditLogsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => AuditLogsNotifier(),
);

// StateNotifier to manage the list of cards
class ColumnsSettingsNotifier extends StateNotifier<List<AuditColumnSettings>> {
  ColumnsSettingsNotifier() : super([]){
    loadSettings(); // Automatically load logs when initialized
  }
  static const String _sharedPrefsKey = 'ColumnsSettingsNotifier';

  void addQuery(AuditColumnSettings query) {
    state = [...state, query]; // Add new log to the list
    saveSettings();
  }

  void removeQuery(int index) {
    if (index >= 0 && index < state.length) {
      // Safely remove the item at the specified index
      state = List.from(state)..removeAt(index);
    }
    saveSettings();
  }

  void updateQuery(int index, AuditColumnSettings updatedEntry) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedEntry else state[i],
    ];
    saveSettings();
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert list of `AuditColumnSettings` to JSON string
    final String jsonList = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_sharedPrefsKey, jsonList);
  }

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonList = prefs.getString(_sharedPrefsKey);
    if (jsonList != null) {
      // Convert JSON string back to list of `AuditColumnSettings`
      final List<dynamic> decodedList = jsonDecode(jsonList);
      state = decodedList
          .map((e) => AuditColumnSettings.fromJson(e))
          .toList()
          .cast<AuditColumnSettings>();
    }
  }
}

final logsProvider =
    StateNotifierProvider<ColumnsSettingsNotifier, List<AuditColumnSettings>>(
  (ref) => ColumnsSettingsNotifier(),
);
