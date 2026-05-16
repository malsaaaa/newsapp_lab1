import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

class NotificationModel {
  final String type;
  final String message;
  final String? articleTitle;
  final DateTime timestamp;

  NotificationModel({
    required this.type,
    required this.message,
    this.articleTitle,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      type: json['type'] ?? 'unknown',
      message: json['message'] ?? '',
      articleTitle: json['articleTitle'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class NotificationService {
  static IO.Socket? _socket;
  static final List<NotificationModel> _notifications = [];
  static final List<Function(NotificationModel)> _listeners = [];

  static bool get isConnected => _socket?.connected ?? false;

  /// Initialize WebSocket connection
  static Future<void> initialize() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    try {
      final backendUrl = AppConfig.backendUrl.replaceAll('/api', '');

      _socket = IO.io(backendUrl, <String, dynamic>{
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 5,
        'transports': ['websocket', 'polling'],
      });

      // Connection event
      _socket!.on('connect', (_) {
        print('✅ WebSocket connected');
        _joinNotifications();
      });

      // Article update event
      _socket!.on('article-update', (data) {
        print('📰 New articles: $data');
        final notification = NotificationModel(
          type: 'article',
          message: data['message'] ?? 'New articles available',
          timestamp: DateTime.now(),
        );
        _addNotification(notification);
      });

      // Bookmark update event
      _socket!.on('bookmark-update', (data) {
        print('🔖 Bookmark update: $data');
        final notification = NotificationModel(
          type: 'bookmark',
          message: data['message'] ?? 'Bookmark updated',
          articleTitle: data['articleTitle'],
          timestamp: DateTime.now(),
        );
        _addNotification(notification);
      });

      // Disconnect event
      _socket!.on('disconnect', (_) {
        print('❌ WebSocket disconnected');
      });

      // Error event
      _socket!.on('error', (error) {
        print('⚠️ WebSocket error: $error');
      });

      // Connect error event
      _socket!.on('connect_error', (error) {
        print('⚠️ Connection error: $error');
      });
    } catch (e) {
      print('❌ Error initializing WebSocket: $e');
    }
  }

  /// Join notification room for current user
  static void _joinNotifications({String? userId}) {
    if (_socket == null || !_socket!.connected) return;

    if (userId != null) {
      _socket!.emit('join-notifications', userId);
    }
  }

  /// Join user's notification room (call after login)
  static void joinUserNotifications(String userId) {
    _joinNotifications(userId: userId);
  }

  /// Add notification and notify listeners
  static void _addNotification(NotificationModel notification) {
    _notifications.add(notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeAt(0);
    }

    // Notify all listeners
    for (var listener in _listeners) {
      listener(notification);
    }
  }

  /// Subscribe to notifications
  static void subscribe(Function(NotificationModel) callback) {
    _listeners.add(callback);
  }

  /// Unsubscribe from notifications
  static void unsubscribe(Function(NotificationModel) callback) {
    _listeners.remove(callback);
  }

  /// Get all notifications
  static List<NotificationModel> getNotifications() => List.from(_notifications);

  /// Clear notifications
  static void clearNotifications() {
    _notifications.clear();
  }

  /// Clear specific notification
  static void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
    }
  }

  /// Disconnect WebSocket
  static void disconnect() {
    _socket?.disconnect();
  }

  /// Reconnect WebSocket
  static void reconnect() {
    _socket?.connect();
  }
}
