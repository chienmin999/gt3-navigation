import 'package:flutter/material.dart';

/// Ánh xạ mã maneuver → IconData Material
/// Dùng cho cả phone UI và để gửi key sang watch
class ManeuverMapper {
  ManeuverMapper._();

  /// Danh sách tất cả maneuver types được hỗ trợ
  static const List<String> allTypes = [
    'straight',
    'turn_left',
    'turn_right',
    'slight_left',
    'slight_right',
    'sharp_left',
    'sharp_right',
    'u_turn',
    'roundabout',
    'arrive',
    'depart',
  ];

  /// Lấy IconData tương ứng với maneuver type
  static IconData getIcon(String maneuver) {
    switch (maneuver) {
      case 'straight':
        return Icons.arrow_upward;
      case 'turn_left':
        return Icons.turn_left;
      case 'turn_right':
        return Icons.turn_right;
      case 'slight_left':
        return Icons.turn_slight_left;
      case 'slight_right':
        return Icons.turn_slight_right;
      case 'sharp_left':
        return Icons.turn_sharp_left;
      case 'sharp_right':
        return Icons.turn_sharp_right;
      case 'u_turn':
        return Icons.u_turn_left;
      case 'roundabout':
        return Icons.roundabout_left;
      case 'arrive':
        return Icons.flag;
      case 'depart':
        return Icons.trip_origin;
      default:
        return Icons.arrow_upward;
    }
  }

  /// Lấy mô tả tiếng Việt cho maneuver
  static String getDescription(String maneuver) {
    switch (maneuver) {
      case 'straight':
        return 'Đi thẳng';
      case 'turn_left':
        return 'Rẽ trái';
      case 'turn_right':
        return 'Rẽ phải';
      case 'slight_left':
        return 'Rẽ nhẹ trái';
      case 'slight_right':
        return 'Rẽ nhẹ phải';
      case 'sharp_left':
        return 'Rẽ gắt trái';
      case 'sharp_right':
        return 'Rẽ gắt phải';
      case 'u_turn':
        return 'Quay đầu';
      case 'roundabout':
        return 'Vào bùng binh';
      case 'arrive':
        return 'Đã đến nơi';
      case 'depart':
        return 'Xuất phát';
      default:
        return 'Tiếp tục';
    }
  }

  /// Màu cho từng loại maneuver
  static Color getColor(String maneuver) {
    switch (maneuver) {
      case 'arrive':
        return Colors.green;
      case 'u_turn':
        return Colors.orange;
      case 'sharp_left':
      case 'sharp_right':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }
}
