import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

/// Service quản lý GPS — theo dõi vị trí người dùng liên tục
class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get error => _error;

  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  /// Lấy vị trí hiện tại một lần
  Future<Position?> getCurrentPosition() async {
    try {
      _error = null;
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _error = 'Không thể lấy vị trí: $e';
      notifyListeners();
      return null;
    }
  }

  /// Bắt đầu theo dõi vị trí liên tục (cho navigation)
  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      _error = null;
      _isTracking = true;
      notifyListeners();

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Cập nhật mỗi 5 mét di chuyển
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Lỗi GPS: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Không thể bật GPS tracking: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  /// Dừng theo dõi vị trí
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Kiểm tra xem GPS có sẵn sàng không
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
