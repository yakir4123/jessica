import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'data_service.dart';

// Create a provider for DataService
final dataServiceProvider =
    StateNotifierProvider<DataService, MinutelyOutputModel?>((ref) {
  final channel = WebSocketChannel.connect(
    Uri.parse(
        "ws://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}/minutely_updates"),
  );
  final dataService = DataService(channel);
  ref.onDispose(() {
    dataService.dispose();
  });
  return dataService;
});

final selectedSymbolProvider =
    StateProvider<String?>((ref) => null);

final selectedStrategyProvider =
    StateProvider<String?>((ref) => null);
