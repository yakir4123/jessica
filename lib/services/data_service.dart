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
    _channel.stream.listen((data) {
      try {
        final Map<String, dynamic> jsonData = json.decode(data);
        final model = MinutelyOutputModel.fromJson(jsonData);
        state = model;
      } catch (e) {
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
