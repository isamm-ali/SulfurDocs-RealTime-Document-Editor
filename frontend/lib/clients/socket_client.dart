import 'package:flutter/foundation.dart';
import 'package:frontend/config/environment.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;
  static String get host => Environment.apiUrl;
  SocketClient._internal() {
    socket = io.io(host, <String, dynamic>{
      'autoConnect': false,
      'transports': ['polling', 'websocket'],
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket!.onConnect((_) {
      debugPrint('SOCKET CONNECTED: ${socket!.id}');
    });

    socket!.onDisconnect((reason) {
      debugPrint('SOCKET DISCONNECTED: $reason');
    });

    socket!.onConnectError((error) {
      debugPrint('SOCKET CONNECT ERROR: $error');
    });

    socket!.onError((error) {
      debugPrint('SOCKET ERROR: $error');
    });

    socket!.onReconnectAttempt((attempt) {
      debugPrint('SOCKET RECONNECT ATTEMPT: $attempt');
    });

    socket!.on("joinError", (data) {
      debugPrint('SOCKET JOIN ERROR: $data');
    });
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
