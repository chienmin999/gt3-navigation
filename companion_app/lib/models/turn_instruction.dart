/// Hướng rẽ — dữ liệu từ OSRM API cho mỗi bước dẫn đường
class TurnInstruction {
  /// Loại hướng rẽ (ví dụ: turn_right, turn_left, straight, v.v.)
  final String maneuver;

  /// Khoảng cách tới điểm rẽ (mét)
  final double distanceMeters;

  /// Tên đường sắp rẽ vào
  final String streetName;

  /// Thời gian di chuyển tới điểm rẽ (giây)
  final double durationSeconds;

  /// Tọa độ điểm rẽ
  final double latitude;
  final double longitude;

  /// Cần rung đồng hồ không (true khi gần tới chỗ rẽ)
  bool vibrate;

  TurnInstruction({
    required this.maneuver,
    required this.distanceMeters,
    required this.streetName,
    required this.durationSeconds,
    required this.latitude,
    required this.longitude,
    this.vibrate = false,
  });

  /// Parse từ OSRM step JSON
  factory TurnInstruction.fromOsrmStep(Map<String, dynamic> step) {
    final maneuverData = step['maneuver'] as Map<String, dynamic>? ?? {};
    final location = maneuverData['location'] as List<dynamic>? ?? [0.0, 0.0];
    final modifier = maneuverData['modifier'] as String? ?? '';
    final type = maneuverData['type'] as String? ?? 'straight';

    // Chuyển OSRM maneuver type + modifier thành dạng đơn giản
    String maneuverKey = _mapOsrmManeuver(type, modifier);

    return TurnInstruction(
      maneuver: maneuverKey,
      distanceMeters: (step['distance'] as num?)?.toDouble() ?? 0.0,
      streetName: (step['name'] as String?) ?? '',
      durationSeconds: (step['duration'] as num?)?.toDouble() ?? 0.0,
      latitude: (location[1] as num).toDouble(),
      longitude: (location[0] as num).toDouble(),
    );
  }

  /// Chuyển sang JSON để gửi sang đồng hồ
  Map<String, dynamic> toWatchJson({
    required String formattedDistance,
    required String eta,
    required String remainingKm,
  }) {
    return {
      'type': 'nav_update',
      'maneuver': maneuver,
      'distance': formattedDistance,
      'street': streetName,
      'eta': eta,
      'remaining_km': remainingKm,
      'vibrate': vibrate,
    };
  }

  /// Map OSRM maneuver type+modifier → key đơn giản cho app
  static String _mapOsrmManeuver(String type, String modifier) {
    switch (type) {
      case 'depart':
        return 'depart';
      case 'arrive':
        return 'arrive';
      case 'turn':
        return _modifierToKey(modifier);
      case 'new name':
      case 'continue':
        return modifier.contains('left')
            ? 'slight_left'
            : modifier.contains('right')
                ? 'slight_right'
                : 'straight';
      case 'merge':
        return _modifierToKey(modifier);
      case 'fork':
        return modifier.contains('left') ? 'slight_left' : 'slight_right';
      case 'roundabout':
      case 'rotary':
        return 'roundabout';
      case 'end of road':
        return _modifierToKey(modifier);
      default:
        return 'straight';
    }
  }

  static String _modifierToKey(String modifier) {
    switch (modifier) {
      case 'left':
        return 'turn_left';
      case 'right':
        return 'turn_right';
      case 'slight left':
        return 'slight_left';
      case 'slight right':
        return 'slight_right';
      case 'sharp left':
        return 'sharp_left';
      case 'sharp right':
        return 'sharp_right';
      case 'uturn':
        return 'u_turn';
      case 'straight':
      default:
        return 'straight';
    }
  }

  @override
  String toString() =>
      'TurnInstruction($maneuver, ${distanceMeters}m, "$streetName")';
}
