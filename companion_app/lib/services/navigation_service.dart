import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/route_info.dart';
import '../models/turn_instruction.dart';
import '../config/app_config.dart';
import '../utils/distance_formatter.dart';
import '../utils/time_formatter.dart';
import 'watch_bridge.dart';

/// Trạng thái dẫn đường
enum NavigationState {
  idle,       // Chưa bắt đầu
  routing,    // Đang tính đường
  navigating, // Đang dẫn đường
  arrived,    // Đã tới nơi
  error,      // Lỗi
}

/// Service điều khiển logic dẫn đường turn-by-turn
class NavigationService extends ChangeNotifier {
  NavigationState _state = NavigationState.idle;
  RouteInfo? _routeInfo;
  int _currentStepIndex = 0;
  double _distanceToNextTurn = 0;
  double _remainingDistance = 0;
  double _remainingDuration = 0;
  String? _errorMessage;
  WatchBridge? _watchBridge;

  // Getters
  NavigationState get state => _state;
  RouteInfo? get routeInfo => _routeInfo;
  int get currentStepIndex => _currentStepIndex;
  double get distanceToNextTurn => _distanceToNextTurn;
  double get remainingDistance => _remainingDistance;
  double get remainingDuration => _remainingDuration;
  String? get errorMessage => _errorMessage;
  bool get isNavigating => _state == NavigationState.navigating;

  TurnInstruction? get currentStep {
    if (_routeInfo == null || _currentStepIndex >= _routeInfo!.steps.length) {
      return null;
    }
    return _routeInfo!.steps[_currentStepIndex];
  }

  TurnInstruction? get nextStep {
    if (_routeInfo == null ||
        _currentStepIndex + 1 >= _routeInfo!.steps.length) {
      return null;
    }
    return _routeInfo!.steps[_currentStepIndex + 1];
  }

  /// Gán WatchBridge để gửi cập nhật sang đồng hồ
  void setWatchBridge(WatchBridge bridge) {
    _watchBridge = bridge;
  }

  /// Bắt đầu dẫn đường với route đã tính sẵn
  void startNavigation(RouteInfo routeInfo) {
    _routeInfo = routeInfo;
    _currentStepIndex = 0;
    _remainingDistance = routeInfo.totalDistanceMeters;
    _remainingDuration = routeInfo.totalDurationSeconds;
    _distanceToNextTurn = routeInfo.steps.isNotEmpty
        ? routeInfo.steps[0].distanceMeters
        : 0;
    _state = NavigationState.navigating;
    _errorMessage = null;
    notifyListeners();

    // Gửi bước đầu tiên sang đồng hồ
    _sendWatchUpdate();
  }

  /// Cập nhật vị trí hiện tại — gọi liên tục từ location stream
  void updatePosition(double lat, double lng) {
    if (_state != NavigationState.navigating || _routeInfo == null) return;

    final userPos = LatLng(lat, lng);
    final currentInstruction = currentStep;
    if (currentInstruction == null) return;

    // Tính khoảng cách từ user tới điểm rẽ tiếp theo
    final turnPoint = LatLng(
      currentInstruction.latitude,
      currentInstruction.longitude,
    );
    _distanceToNextTurn = _distanceBetween(userPos, turnPoint);

    // === Kiểm tra nếu đã qua điểm rẽ → chuyển bước tiếp theo ===
    if (_distanceToNextTurn < AppConfig.maneuverAdvanceDistanceMeters) {
      _advanceToNextStep();
    }
    // === Kiểm tra nếu sắp tới chỗ rẽ → bật rung ===
    else if (_distanceToNextTurn < AppConfig.maneuverAlertDistanceMeters) {
      if (!currentInstruction.vibrate) {
        currentInstruction.vibrate = true;
        _sendWatchUpdate();
      }
    }

    // Cập nhật khoảng cách và thời gian còn lại (ước tính)
    _updateRemainingEstimates(userPos);
    notifyListeners();
  }

  /// Chuyển sang bước rẽ tiếp theo
  void _advanceToNextStep() {
    if (_routeInfo == null) return;

    _currentStepIndex++;

    // Kiểm tra đã tới đích chưa
    if (_currentStepIndex >= _routeInfo!.steps.length) {
      _state = NavigationState.arrived;
      _sendArrivalUpdate();
      notifyListeners();
      return;
    }

    // Reset vibrate cho bước mới
    final newStep = currentStep;
    if (newStep != null) {
      newStep.vibrate = false;
      _distanceToNextTurn = newStep.distanceMeters;
    }

    // Gửi cập nhật bước mới sang đồng hồ
    _sendWatchUpdate();
    notifyListeners();
  }

  /// Cập nhật ước tính khoảng cách/thời gian còn lại
  void _updateRemainingEstimates(LatLng userPos) {
    if (_routeInfo == null) return;

    // Tổng distance từ bước hiện tại đến cuối
    double remaining = _distanceToNextTurn;
    for (int i = _currentStepIndex + 1; i < _routeInfo!.steps.length; i++) {
      remaining += _routeInfo!.steps[i].distanceMeters;
    }
    _remainingDistance = remaining;

    // Ước tính thời gian còn lại (tỉ lệ đơn giản)
    if (_routeInfo!.totalDistanceMeters > 0) {
      _remainingDuration = _routeInfo!.totalDurationSeconds *
          (_remainingDistance / _routeInfo!.totalDistanceMeters);
    }
  }

  /// Gửi cập nhật navigation sang đồng hồ
  void _sendWatchUpdate() {
    final step = currentStep;
    if (step == null || _watchBridge == null) return;

    final data = step.toWatchJson(
      formattedDistance: DistanceFormatter.format(_distanceToNextTurn),
      eta: TimeFormatter.formatEta(_remainingDuration),
      remainingKm: DistanceFormatter.toKmString(_remainingDistance),
    );

    _watchBridge!.sendNavUpdate(data);
  }

  /// Gửi thông báo đã tới nơi
  void _sendArrivalUpdate() {
    _watchBridge?.sendNavUpdate({
      'type': 'nav_update',
      'maneuver': 'arrive',
      'distance': '0 m',
      'street': _routeInfo?.destinationName ?? 'Đích đến',
      'eta': '--:--',
      'remaining_km': '0',
      'vibrate': true,
    });
  }

  /// Dừng dẫn đường
  void stopNavigation() {
    _state = NavigationState.idle;
    _routeInfo = null;
    _currentStepIndex = 0;
    _errorMessage = null;
    notifyListeners();
  }

  /// Tính khoảng cách giữa 2 tọa độ (mét) — Haversine formula
  double _distanceBetween(LatLng a, LatLng b) {
    const earthRadius = 6371000.0; // mét
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final aVal = sinDLat * sinDLat +
        math.cos(_toRadians(a.latitude)) *
            math.cos(_toRadians(b.latitude)) *
            sinDLng *
            sinDLng;
    final c = 2 * math.atan2(math.sqrt(aVal), math.sqrt(1 - aVal));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
