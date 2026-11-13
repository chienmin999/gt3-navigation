/// Cấu hình chung cho ứng dụng — API endpoints, hằng số
class AppConfig {
  AppConfig._();

  // === OSRM (Open Source Routing Machine) — miễn phí ===
  static const String osrmBaseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  // === Nominatim (Geocoding miễn phí, tuân thủ usage policy) ===
  static const String nominatimBaseUrl =
      'https://nominatim.openstreetmap.org/search';

  // === OpenStreetMap Tile Server ===
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // === Platform channel ===
  static const String wearEngineChannel = 'com.gt3nav/wear_engine';
  static const String wearEngineEventChannel =
      'com.gt3nav/wear_engine_events';

  // === Navigation thresholds ===
  /// Khoảng cách (mét) để coi là "sắp tới chỗ rẽ" → gửi rung đồng hồ
  static const double maneuverAlertDistanceMeters = 50.0;

  /// Khoảng cách (mét) để chuyển sang bước tiếp theo
  static const double maneuverAdvanceDistanceMeters = 25.0;

  /// Tần suất cập nhật vị trí (milliseconds)
  static const int locationUpdateIntervalMs = 2000;

  // === User-Agent cho Nominatim (bắt buộc theo policy) ===
  static const String nominatimUserAgent = 'GT3NavCompanion/1.0';

  // === Tên ứng dụng ===
  static const String appName = 'GT3 Navigation';
}
