import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../constants/api_endpoints.dart';
import '../api_service/token_meneger.dart';

class NotificationSocketService {
  NotificationSocketService._();

  static final NotificationSocketService instance =
      NotificationSocketService._();

  final StreamController<NotificationSocketEvent> _eventsController =
      StreamController<NotificationSocketEvent>.broadcast();

  io.Socket? _socket;
  bool _connecting = false;

  Stream<NotificationSocketEvent> get events => _eventsController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true || _connecting) return;
    _connecting = true;
    try {
      final token = await TokenManager.getToken();
      final uid = await _resolveUserId();

      final socket = io.io(
        ApiEndpoints.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders(
              token != null && token.trim().isNotEmpty
                  ? <String, dynamic>{'Authorization': 'Bearer $token'}
                  : <String, dynamic>{},
            )
            .build(),
      );

      socket.onConnect((_) {
        if (uid.isNotEmpty) {
          socket.emit('joinNotifications', <String, dynamic>{'userId': uid});
          socket.emit('joinChatRoom', uid);
        } else {
          socket.emit('joinNotifications');
        }
        socket.emit('joinAlerts');
        _eventsController.add(
          const NotificationSocketEvent(
            type: NotificationSocketEventType.connected,
          ),
        );
      });

      socket.onDisconnect((_) {
        _eventsController.add(
          const NotificationSocketEvent(
            type: NotificationSocketEventType.disconnected,
          ),
        );
      });

      socket.onConnectError((_) {
        _eventsController.add(
          const NotificationSocketEvent(
            type: NotificationSocketEventType.disconnected,
          ),
        );
      });
      socket.onError((_) {
        _eventsController.add(
          const NotificationSocketEvent(
            type: NotificationSocketEventType.disconnected,
          ),
        );
      });

      socket.on('notification:new', (data) {
        _eventsController.add(
          NotificationSocketEvent(
            type: NotificationSocketEventType.created,
            payload: _toMap(data),
          ),
        );
      });
      socket.on('notification:updated', (data) {
        _eventsController.add(
          NotificationSocketEvent(
            type: NotificationSocketEventType.updated,
            payload: _toMap(data),
          ),
        );
      });
      socket.on('notification:deleted', (data) {
        _eventsController.add(
          NotificationSocketEvent(
            type: NotificationSocketEventType.deleted,
            payload: _toMap(data),
          ),
        );
      });

      socket.connect();
      _socket = socket;
    } catch (_) {
      _eventsController.add(
        const NotificationSocketEvent(
          type: NotificationSocketEventType.disconnected,
        ),
      );
    } finally {
      _connecting = false;
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Future<String> _resolveUserId() async {
    final fromStorage = (await TokenManager.getUid())?.trim() ?? '';
    if (fromStorage.isNotEmpty) return fromStorage;
    final fromToken = (await TokenManager.getUidFromToken())?.trim() ?? '';
    return fromToken;
  }

  Map<String, dynamic>? _toMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}

enum NotificationSocketEventType {
  connected,
  disconnected,
  created,
  updated,
  deleted,
}

class NotificationSocketEvent {
  const NotificationSocketEvent({required this.type, this.payload});

  final NotificationSocketEventType type;
  final Map<String, dynamic>? payload;
}
