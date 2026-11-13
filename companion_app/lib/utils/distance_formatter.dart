/// Định dạng khoảng cách cho hiển thị
class DistanceFormatter {
  DistanceFormatter._();

  /// Chuyển mét → chuỗi đọc được (ví dụ: "120 m", "3.5 km")
  static String format(double meters) {
    if (meters < 0) return '0 m';

    if (meters < 1000) {
      // Dưới 1km: hiển thị mét, làm tròn
      if (meters < 100) {
        return '${meters.round()} m';
      }
      // Làm tròn tới chục
      final rounded = (meters / 10).round() * 10;
      return '$rounded m';
    }

    // Trên 1km: hiển thị km
    final km = meters / 1000;
    if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    }
    return '${km.round()} km';
  }

  /// Chuyển mét → km dạng chuỗi (ví dụ: "3.5")
  static String toKmString(double meters) {
    return (meters / 1000).toStringAsFixed(1);
  }
}
