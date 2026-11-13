import 'package:flutter/material.dart';
import '../models/watch_connection.dart';

/// Badge hiển thị trạng thái kết nối với đồng hồ
class WatchStatusBadge extends StatelessWidget {
  final WatchConnection connection;
  final VoidCallback onTap;

  const WatchStatusBadge({
    super.key,
    required this.connection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String tooltip;

    switch (connection.state) {
      case WatchConnectionState.connected:
        color = Colors.green;
        icon = Icons.watch;
        tooltip = 'Đã kết nối: ${connection.deviceName ?? "Huawei Watch"}';
        break;
      case WatchConnectionState.connecting:
        color = Colors.amber;
        icon = Icons.watch;
        tooltip = 'Đang kết nối...';
        break;
      case WatchConnectionState.error:
        color = Colors.red;
        icon = Icons.watch_off;
        tooltip = connection.errorMessage ?? 'Lỗi kết nối';
        break;
      case WatchConnectionState.disconnected:
      default:
        color = Colors.grey;
        icon = Icons.watch_off;
        tooltip = 'Chưa kết nối đồng hồ';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
