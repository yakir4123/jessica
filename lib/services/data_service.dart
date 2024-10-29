import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DataService extends StateNotifier<MinutelyOutputModel?>{
  final WebSocketChannel _channel;

  DataService(this._channel) : super(null) {
    _initialize();
  }

  void _initialize() {
    // Listen to the WebSocket stream
    _channel.stream.listen((data) {
      try {
        // Step 2: Decode JSON string to a Map
        final Map<String, dynamic> jsonData = json.decode(data);

        // Step 3: Convert Map to MinutelyOutputModel
        final model = MinutelyOutputModel.fromJson(jsonData);

        // Step 4: Update state with the new model
        state = model;
      } catch (e) {
        print("Error parsing WebSocket data: $e");
        // Optionally set state to null if parsing fails
        state = null;
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

}
