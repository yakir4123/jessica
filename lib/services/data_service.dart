import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DataService extends StateNotifier<Map<String, dynamic>> {
  final WebSocketChannel _channel;
  Map<String, dynamic> decodedMessage = {};
  String selectedKey = "LiveStrategy:Binance Perpetual Futures:SOL-USDT:15m";

  DataService()
      : _channel = WebSocketChannel.connect(
          Uri.parse(
              "ws://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}/ws"),
        ),
        super({}) {
    _channel.stream.listen((message) {
      final decodedMessage = json.decode(message) as Map<String, dynamic>;
      this.decodedMessage = decodedMessage;
      state = Map<String, dynamic>.from(decodedMessage[selectedKey] ?? {});
    });
  }

  void selectKey(String key) {
    selectedKey = key;
    state = Map<String, dynamic>.from(decodedMessage[key] ?? {});
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
