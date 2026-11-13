/// Định dạng thời gian cho ETA và thời gian di chuyển
class TimeFormatter {
  TimeFormatter._();

  /// Tính ETA từ bây giờ + số giây còn lại → "18:45"
  static String formatEta(double remainingSeconds) {
    final now = DateTime.now();
    final eta = now.add(Duration(seconds: remainingSeconds.round()));
    return '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';
  }

  /// Định dạng thời gian di chuyển (giây → "5 phút", "1h 30m")
  static String formatDuration(double seconds) {
    if (seconds < 0) return '0 phút';

    final totalMinutes = (seconds / 60).round();
    if (totalMinutes < 1) return '< 1 phút';
    if (totalMinutes < 60) return '$totalMinutes phút';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
