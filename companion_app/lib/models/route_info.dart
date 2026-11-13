import 'package:latlong2/latlong.dart';
import 'turn_instruction.dart';

/// Thông tin tổng quan về tuyến đường
class RouteInfo {
  /// Tổng khoảng cách (mét)
  final double totalDistanceMeters;

  /// Tổng thời gian dự kiến (giây)
  final double totalDurationSeconds;

  /// Danh sách tọa độ tạo nên đường đi (polyline)
  final List<LatLng> polylinePoints;

  /// Danh sách các bước rẽ
  final List<TurnInstruction> steps;

  /// Tên điểm xuất phát
  final String originName;

  /// Tên điểm đến
  final String destinationName;

  const RouteInfo({
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.polylinePoints,
    required this.steps,
    this.originName = '',
    this.destinationName = '',
  });

  /// Khoảng cách tổng dạng đọc được (km hoặc m)
  String get formattedDistance {
    if (totalDistanceMeters >= 1000) {
      return '${(totalDistanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${totalDistanceMeters.round()} m';
  }

  /// Thời gian dự kiến dạng đọc được
  String get formattedDuration {
    final minutes = (totalDurationSeconds / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '$minutes phút';
  }

  /// Khoảng cách tổng tính bằng km (dạng chuỗi)
  String get totalKm =>
      (totalDistanceMeters / 1000).toStringAsFixed(1);
}
