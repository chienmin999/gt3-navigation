import 'package:flutter/material.dart';
import '../models/route_info.dart';

/// Thanh tóm tắt tuyến đường xuất hiện ở đáy màn hình trước khi bắt đầu dẫn đường
class RouteSummary extends StatelessWidget {
  final RouteInfo routeInfo;
  final String destinationName;
  final VoidCallback onStartNavigation;
  final VoidCallback onCancel;

  const RouteSummary({
    super.key,
    required this.routeInfo,
    required this.destinationName,
    required this.onStartNavigation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final title = destinationName.isNotEmpty
        ? destinationName
        : (routeInfo.destinationName.isNotEmpty
            ? routeInfo.destinationName
            : 'Điểm đến');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.straighten, size: 18, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      routeInfo.formattedDistance,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      routeInfo.formattedDuration,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onStartNavigation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Bắt đầu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
