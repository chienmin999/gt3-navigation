import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_connection.dart';
import '../services/watch_bridge.dart';

/// Màn hình ghép nối & kiểm tra kết nối với Huawei Watch GT 3 SE
class WatchConnectScreen extends StatelessWidget {
  const WatchConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchBridge = context.watch<WatchBridge>();
    final connection = watchBridge.connection;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết nối Đồng hồ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === Card trạng thái kết nối ===
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatusIcon(connection.state),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusTitle(connection.state),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      connection.deviceName ?? 'Huawei Watch GT 3 SE',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (connection.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        connection.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: connection.isConnected
                          ? () => watchBridge.disconnect()
                          : () => watchBridge.connect(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            connection.isConnected ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(connection.isConnected
                          ? Icons.link_off
                          : Icons.link),
                      label: Text(connection.isConnected
                          ? 'Ngắt kết nối'
                          : 'Kết nối ngay'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Nút kiểm tra gửi tín hiệu ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiểm tra tín hiệu (Test Ping)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gửi một lệnh rẽ mẫu để kiểm tra xem đồng hồ có rung và hiển thị icon không.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: connection.isConnected
                                ? () {
                                    watchBridge.sendNavUpdate({
                                      'type': 'nav_update',
                                      'maneuver': 'turn_left',
                                      'distance': '150 m',
                                      'street': 'Đường Thử Nghiệm',
                                      'eta': '12:00',
                                      'remaining_km': '1.5',
                                      'vibrate': true,
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã gửi lệnh rẽ trái + rung sang đồng hồ!'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.turn_left),
                            label: const Text('Thử rẽ trái'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: connection.isConnected
                                ? () {
                                    watchBridge.sendNavUpdate({
                                      'type': 'nav_update',
                                      'maneuver': 'turn_right',
                                      'distance': '80 m',
                                      'street': 'Đường Thử Nghiệm',
                                      'eta': '12:00',
                                      'remaining_km': '1.2',
                                      'vibrate': true,
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã gửi lệnh rẽ phải + rung sang đồng hồ!'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.turn_right),
                            label: const Text('Thử rẽ phải'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Hướng dẫn kết nối ===
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Hướng dẫn thiết lập:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. Cài đặt Watch App (.hap) lên GT 3 SE thông qua Android (Huawei Health Mod / DevEco Studio).\n'
                      '2. Trên đồng hồ vào Cài đặt > Hệ thống > chọn "Ngắt kết nối" (KHÔNG chọn Khôi phục cài đặt gốc).\n'
                      '3. Mở iPhone kết nối với GT 3 SE qua ứng dụng Huawei Health bằng cùng tài khoản Huawei ID.\n'
                      '4. Mở app này trên iPhone, bấm nút "Kết nối ngay" ở trên để ủy quyền qua Huawei Health và bắt đầu sử dụng!',
                      style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(WatchConnectionState state) {
    Color color;
    IconData icon;

    switch (state) {
      case WatchConnectionState.connected:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case WatchConnectionState.connecting:
        color = Colors.amber;
        icon = Icons.sync;
        break;
      case WatchConnectionState.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case WatchConnectionState.disconnected:
      default:
        color = Colors.grey;
        icon = Icons.watch_off;
        break;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 40),
    );
  }

  String _getStatusTitle(WatchConnectionState state) {
    switch (state) {
      case WatchConnectionState.connected:
        return 'Đã kết nối';
      case WatchConnectionState.connecting:
        return 'Đang kết nối...';
      case WatchConnectionState.error:
        return 'Lỗi kết nối';
      case WatchConnectionState.disconnected:
      default:
        return 'Chưa kết nối';
    }
  }
}
