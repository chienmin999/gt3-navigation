/// Trạng thái kết nối với đồng hồ
enum WatchConnectionState {
  /// Chưa kết nối
  disconnected,

  /// Đang kết nối
  connecting,

  /// Đã kết nối, sẵn sàng gửi dữ liệu
  connected,

  /// Lỗi kết nối
  error,
}

/// Model giữ thông tin trạng thái kết nối đồng hồ
class WatchConnection {
  final WatchConnectionState state;
  final String? deviceName;
  final String? errorMessage;

  const WatchConnection({
    this.state = WatchConnectionState.disconnected,
    this.deviceName,
    this.errorMessage,
  });

  bool get isConnected => state == WatchConnectionState.connected;
  bool get isConnecting => state == WatchConnectionState.connecting;
  bool get hasError => state == WatchConnectionState.error;

  WatchConnection copyWith({
    WatchConnectionState? state,
    String? deviceName,
    String? errorMessage,
  }) {
    return WatchConnection(
      state: state ?? this.state,
      deviceName: deviceName ?? this.deviceName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() => 'WatchConnection($state, device: $deviceName)';
}
