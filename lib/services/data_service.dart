import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/mock_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DataService extends StateNotifier<Map<String, dynamic>>
    with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  Map<String, dynamic> decodedMessage = {};
  String selectedKey = "LiveStrategy:Binance Perpetual Futures:AVAX-USDT";

  DataService() : super({}) {
    WidgetsBinding.instance.addObserver(this);
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(
            "ws://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}/ws"),
      );

      print('WebSocket stream started');
      _channel!.stream.listen(
        (message) {
          final decodedMessage = json.decode(message) as Map<String, dynamic>;
          this.decodedMessage = decodedMessage;
          if (decodedMessage.containsKey(selectedKey)) {
            state = Map<String, dynamic>.from(decodedMessage[selectedKey]);
          } else {
            state = {};
          }
        },
        onDone: () {
          print('WebSocket stream ended');
        },
        onError: (error) {
          print('WebSocket stream error: $error');
        },
      );
    } catch (_) {
      state = mockData;
    }
  }

  void selectKey(String key) {
    selectedKey = key;
    if (decodedMessage.containsKey(key)) {
      state = Map<String, dynamic>.from(decodedMessage[key]);
    } else {
      state = {};
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Disposing DataService');
    _channel?.sink.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('App resumed, reconnecting to WebSocket');
      _connectWebSocket();
    } else if (state == AppLifecycleState.paused) {
      print('App paused, closing WebSocket connection');
      _channel?.sink.close();
    }
  }
}
