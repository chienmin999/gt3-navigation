import 'package:permission_handler/permission_handler.dart';

/// Service quản lý runtime permissions (vị trí, bluetooth, v.v.)
class PermissionService {
  PermissionService._();

  /// Yêu cầu tất cả quyền cần thiết cho ứng dụng
  /// Trả về true nếu tất cả quyền đã được cấp
  static Future<bool> requestAllPermissions() async {
    final results = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.notification,
    ].request();

    // Kiểm tra quyền vị trí — bắt buộc
    final locationGranted = results[Permission.location]?.isGranted ?? false;
    final locationWhenInUse =
        results[Permission.locationWhenInUse]?.isGranted ?? false;

    return locationGranted || locationWhenInUse;
  }

  /// Yêu cầu quyền vị trí
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Yêu cầu quyền vị trí chạy nền (cho navigation liên tục)
  static Future<bool> requestBackgroundLocationPermission() async {
    // Phải có quyền whenInUse trước
    final foregroundGranted = await requestLocationPermission();
    if (!foregroundGranted) return false;

    var status = await Permission.locationAlways.status;
    if (status.isGranted) return true;

    status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// Yêu cầu quyền Bluetooth
  static Future<bool> requestBluetoothPermission() async {
    final results = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    return results[Permission.bluetoothConnect]?.isGranted ?? false;
  }

  /// Kiểm tra xem quyền vị trí đã được cấp chưa
  static Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Kiểm tra xem quyền Bluetooth đã được cấp chưa
  static Future<bool> isBluetoothGranted() async {
    return await Permission.bluetoothConnect.isGranted;
  }

  /// Mở cài đặt ứng dụng để cấp quyền thủ công
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
