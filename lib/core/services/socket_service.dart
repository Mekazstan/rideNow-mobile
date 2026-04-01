import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';

class SocketService {
  io.Socket? _socket;
  String? _token;
  bool _isConnected = false;

  final _eventController = StreamController<SocketEvent>.broadcast();
  Stream<SocketEvent> get eventStream => _eventController.stream;

  bool get isConnected => _isConnected;

  void setToken(String token) {
    _token = token;
    _reconnect();
  }

  void connect() {
    if (_socket != null && _socket!.connected) return;

    debugPrint('🔌 Initializing Socket connection to ${ApiConstants.baseUrl}');

    _socket = io.io(
      ApiConstants.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': _token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(5000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('✅ Socket connected successfully');
      _eventController.add(SocketEvent(type: 'connected', data: null));
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('❌ Socket disconnected');
      _eventController.add(SocketEvent(type: 'disconnected', data: null));
    });

    _socket!.onConnectError((data) {
      debugPrint('⚠️ Socket connection error: $data');
      _eventController.add(SocketEvent(type: 'error', data: data));
    });

    // Handle generic events from backend
    _socket!.onAny((event, data) {
      debugPrint('📡 Socket Event Received: $event -> $data');
      _eventController.add(SocketEvent(type: event, data: data));
    });
  }

  void _reconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    connect();
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🚀 Emitting Socket Event: $event -> $data');
      _socket!.emit(event, data);
    } else {
      debugPrint('⚠️ Cannot emit event: Socket not connected');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}

class SocketEvent {
  final String type;
  final dynamic data;

  SocketEvent({required this.type, required this.data});
}
