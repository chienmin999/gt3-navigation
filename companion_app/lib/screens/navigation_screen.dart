import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/app_config.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../services/watch_bridge.dart';
import '../utils/distance_formatter.dart';
import '../utils/time_formatter.dart';
import '../widgets/turn_indicator.dart';
import '../widgets/watch_status_badge.dart';

/// Màn hình dẫn đường Turn-by-Turn thời gian thực
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  StreamSubscription? _posSubscription;

  @override
  void initState() {
    super.initState();
    // Giữ màn hình sáng suốt quá trình dẫn đường
    WakelockPlus.enable();

    // Bắt đầu lắng nghe GPS theo thời gian thực
    final locationService = context.read<LocationService>();
    final navService = context.read<NavigationService>();

    _posSubscription = locationService.positionStream.listen((pos) {
      navService.updatePosition(pos.latitude, pos.longitude);

      // Tự động xoay/di chuyển camera theo vị trí người dùng
      _mapController.move(LatLng(pos.latitude, pos.longitude), 17.0);
    });
  }

  @override
  void dispose() {
    _posSubscription?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navService = context.watch<NavigationService>();
    final locationService = context.watch<LocationService>();
    final watchBridge = context.watch<WatchBridge>();

    final currentPos = locationService.currentPosition;
    final userLatLng = currentPos != null
        ? LatLng(currentPos.latitude, currentPos.longitude)
        : null;

    final route = navService.routeInfo;
    final currentStep = navService.currentStep;

    return WillPopScope(
      onWillPop: () async {
        return await _confirmExitNavigation(context) ?? false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // === Bản đồ nền ===
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLatLng ?? const LatLng(21.0285, 105.8542),
                initialZoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConfig.osmTileUrl,
                  userAgentPackageName: 'com.gt3nav.app',
                ),
                if (route != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route.polylinePoints,
                        color: Colors.blueAccent,
                        strokeWidth: 6.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (userLatLng != null)
                      Marker(
                        point: userLatLng,
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (route != null && route.polylinePoints.isNotEmpty)
                      Marker(
                        point: route.polylinePoints.last,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // === Header: Turn Indicator & Watch Status ===
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () async {
                              final shouldExit = await _confirmExitNavigation(context);
                              if (shouldExit == true && mounted) {
                                navService.stopNavigation();
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: WatchStatusBadge(
                            connection: watchBridge.connection,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (currentStep != null)
                    TurnIndicator(
                      currentStep: currentStep,
                      nextStep: navService.nextStep,
                      distanceToNextTurn: navService.distanceToNextTurn,
                    ),
                ],
              ),
            ),

            // === Thông báo khi đã tới nơi ===
            if (navService.state == NavigationState.arrived)
              Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 64),
                        const SizedBox(height: 12),
                        const Text(
                          'Đã đến nơi!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          route?.destinationName ?? 'Bạn đã đến đích an toàn.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            navService.stopNavigation();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Hoàn tất'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // === Bottom Bar: Thông tin còn lại & nút hủy ===
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DistanceFormatter.toKmString(navService.remainingDistance),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          'Còn lại: ${TimeFormatter.formatEta(navService.remainingDuration)}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final shouldExit = await _confirmExitNavigation(context);
                        if (shouldExit == true && mounted) {
                          navService.stopNavigation();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Dừng'),
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

  Future<bool?> _confirmExitNavigation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dừng dẫn đường?'),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi chế độ dẫn đường không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục đi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Dừng lại'),
          ),
        ],
      ),
    );
  }
}
