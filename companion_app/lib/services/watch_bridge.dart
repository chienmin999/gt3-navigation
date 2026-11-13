import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../models/watch_connection.dart';

/// Service giao tiếp với đồng hồ Huawei qua Platform Channel
/// Kết nối tới native code (Kotlin trên Android, Swift trên iOS)
/// sử dụng Huawei Wear Engine SDK
class WatchBridge extends ChangeNotifier {
  // Platform channels
  static const MethodChannel _channel =
      MethodChannel(AppConfig.wearEngineChannel);
  static const EventChannel _eventChannel =
      EventChannel(AppConfig.wearEngineEventChannel);

  WatchConnection _connection = const WatchConnection();
  StreamSubscription? _eventSubscription;

  WatchConnection get connection => _connection;
  bool get isConnected => _connection.isConnected;

  WatchBridge() {
    _listenToConnectionEvents();
  }

  /// Lắng nghe sự kiện thay đổi kết nối từ native
  void _listenToConnectionEvents() {
    _eventSubscription = _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as Map)
        .listen(
      (Map event) {
        final status = event['status'] as String?;
        final deviceName = event['deviceName'] as String?;

        switch (status) {
          case 'connected':
            _connection = _connection.copyWith(
              state: WatchConnectionState.connected,
              deviceName: deviceName,
            );
            break;
          case 'disconnected':
            _connection = _connection.copyWith(
              state: WatchConnectionState.disconnected,
            );
            break;
          case 'connecting':
            _connection = _connection.copyWith(
              state: WatchConnectionState.connecting,
            );
            break;
          default:
            _connection = _connection.copyWith(
              state: WatchConnectionState.error,
              errorMessage: 'Trạng thái không xác định: $status',
            );
        }
        notifyListeners();
      },
      onError: (error) {
        _connection = _connection.copyWith(
          state: WatchConnectionState.error,
          errorMessage: 'Lỗi event channel: $error',
        );
        notifyListeners();
      },
    );
  }

  /// Kết nối với đồng hồ
  Future<bool> connect() async {
    try {
      _connection = _connection.copyWith(
        state: WatchConnectionState.connecting,
      );
      notifyListeners();

      final result = await _channel.invokeMethod<bool>('connect');
      return result ?? false;
    } on PlatformException catch (e) {
      _connection = _connection.copyWith(
        state: WatchConnectionState.error,
        errorMessage: 'Lỗi kết nối: ${e.message}',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _connection = _connection.copyWith(
        state: WatchConnectionState.error,
        errorMessage: 'Lỗi không xác định: $e',
      );
      notifyListeners();
      return false;
    }
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      _connection = const WatchConnection(
        state: WatchConnectionState.disconnected,
      );
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('Lỗi ngắt kết nối: ${e.message}');
    }
  }

  /// Gửi cập nhật navigation sang đồng hồ
  /// [data] phải theo format JSON protocol (xem turn_instruction.toWatchJson)
  Future<bool> sendNavUpdate(Map<String, dynamic> data) async {
    if (!isConnected) {
      debugPrint('WatchBridge: Chưa kết nối, bỏ qua sendNavUpdate');
      return false;
    }

    try {
      final jsonStr = json.encode(data);
      final result = await _channel.invokeMethod<bool>(
        'sendNavUpdate',
        {'data': jsonStr},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Lỗi gửi nav update: ${e.message}');
      return false;
    }
  }

  /// Lấy trạng thái kết nối hiện tại từ native
  Future<WatchConnectionState> getConnectionStatus() async {
    try {
      final status = await _channel.invokeMethod<String>('getConnectionStatus');
      switch (status) {
        case 'connected':
          return WatchConnectionState.connected;
        case 'connecting':
          return WatchConnectionState.connecting;
        default:
          return WatchConnectionState.disconnected;
      }
    } on PlatformException {
      return WatchConnectionState.disconnected;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
