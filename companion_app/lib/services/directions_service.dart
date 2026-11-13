import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';
import '../models/route_info.dart';
import '../models/turn_instruction.dart';
import '../models/place.dart';

/// Service gọi API tính đường và tìm kiếm địa điểm
class DirectionsService {
  DirectionsService._();

  // =====================================================
  // OSRM — Tính tuyến đường (miễn phí, không cần API key)
  // =====================================================

  /// Tính tuyến đường từ origin → destination
  /// Trả về RouteInfo chứa polyline + danh sách bước rẽ
  static Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
    String destinationName = '',
  }) async {
    final url = Uri.parse(
      '${AppConfig.osrmBaseUrl}/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('OSRM error: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
        return null; // Không tìm thấy đường
      }

      final route = data['routes'][0];
      final legs = route['legs'] as List;

      // Parse polyline từ GeoJSON
      final geometry = route['geometry']['coordinates'] as List;
      final polylinePoints = geometry
          .map<LatLng>((coord) => LatLng(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              ))
          .toList();

      // Parse tất cả steps từ tất cả legs
      final steps = <TurnInstruction>[];
      for (final leg in legs) {
        final legSteps = leg['steps'] as List;
        for (final step in legSteps) {
          steps.add(TurnInstruction.fromOsrmStep(step));
        }
      }

      return RouteInfo(
        totalDistanceMeters: (route['distance'] as num).toDouble(),
        totalDurationSeconds: (route['duration'] as num).toDouble(),
        polylinePoints: polylinePoints,
        steps: steps,
        destinationName: destinationName,
      );
    } catch (e) {
      throw Exception('Lỗi tính đường: $e');
    }
  }

  // =====================================================
  // Nominatim — Tìm kiếm địa điểm (miễn phí, giới hạn 1 req/s)
  // =====================================================

  /// Tìm kiếm địa điểm bằng text query
  static Future<List<Place>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(AppConfig.nominatimBaseUrl).replace(
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '10',
        'addressdetails': '1',
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': AppConfig.nominatimUserAgent},
      );

      if (response.statusCode != 200) {
        throw Exception('Nominatim error: ${response.statusCode}');
      }

      final data = json.decode(response.body) as List;
      return data.map((item) => Place.fromNominatim(item)).toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }

  /// Reverse geocode — tọa độ → tên địa điểm
  static Future<String> reverseGeocode(LatLng location) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${location.latitude}&lon=${location.longitude}'
      '&format=json&zoom=18',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': AppConfig.nominatimUserAgent},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] as String? ?? 'Vị trí đã chọn';
      }
    } catch (_) {
      // Bỏ qua lỗi, trả về tên mặc định
    }
    return 'Vị trí đã chọn';
  }
}
