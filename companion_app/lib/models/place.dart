import 'package:latlong2/latlong.dart';

/// Địa điểm / vị trí — kết quả tìm kiếm hoặc điểm đến
class Place {
  /// Tên hiển thị
  final String displayName;

  /// Tọa độ
  final LatLng location;

  /// Loại địa điểm (từ Nominatim)
  final String type;

  /// Địa chỉ ngắn (nếu có)
  final String? shortAddress;

  const Place({
    required this.displayName,
    required this.location,
    this.type = '',
    this.shortAddress,
  });

  /// Parse từ Nominatim JSON
  factory Place.fromNominatim(Map<String, dynamic> json) {
    return Place(
      displayName: json['display_name'] as String? ?? '',
      location: LatLng(
        double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
        double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      ),
      type: json['type'] as String? ?? '',
    );
  }

  @override
  String toString() => 'Place("$displayName", $location)';
}
