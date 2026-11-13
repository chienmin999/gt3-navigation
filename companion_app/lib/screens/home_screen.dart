import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/routes.dart';
import '../models/place.dart';
import '../models/route_info.dart';
import '../services/location_service.dart';
import '../services/directions_service.dart';
import '../services/navigation_service.dart';
import '../services/watch_bridge.dart';
import '../widgets/watch_status_badge.dart';
import '../widgets/route_summary.dart';

/// Màn hình chính — hiển thị bản đồ, tìm kiếm, bắt đầu dẫn đường
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  LatLng? _destination;
  String _destinationName = '';
  RouteInfo? _previewRoute;
  bool _isLoadingRoute = false;
  String? _routeError;

  // Vị trí mặc định: Hà Nội
  static const LatLng _defaultCenter = LatLng(21.0285, 105.8542);

  @override
  void initState() {
    super.initState();
    // Yêu cầu vị trí khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().getCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationService = context.watch<LocationService>();
    final watchBridge = context.watch<WatchBridge>();

    final currentPos = locationService.currentPosition;
    final center = currentPos != null
        ? LatLng(currentPos.latitude, currentPos.longitude)
        : _defaultCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          // Badge trạng thái đồng hồ
          WatchStatusBadge(
            connection: watchBridge.connection,
            onTap: () => Navigator.pushNamed(context, AppRoutes.watchConnect),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          // === Bản đồ ===
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              // Tile layer — OpenStreetMap
              TileLayer(
                urlTemplate: AppConfig.osmTileUrl,
                userAgentPackageName: 'com.gt3nav.app',
              ),

              // Polyline route preview
              if (_previewRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _previewRoute!.polylinePoints,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),

              // Markers
              MarkerLayer(
                markers: [
                  // Vị trí hiện tại
                  if (currentPos != null)
                    Marker(
                      point: LatLng(currentPos.latitude, currentPos.longitude),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Điểm đến
                  if (_destination != null)
                    Marker(
                      point: _destination!,
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

          // === Route summary bar (khi đã có route preview) ===
          if (_previewRoute != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RouteSummary(
                routeInfo: _previewRoute!,
                destinationName: _destinationName,
                onStartNavigation: _startNavigation,
                onCancel: _clearRoute,
              ),
            ),

          // === Loading indicator ===
          if (_isLoadingRoute)
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 12),
                        Text('Đang tính đường...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // === Error message ===
          if (_routeError != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _routeError!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),
            ),
        ],
      ),

      // === FAB: Tìm kiếm ===
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút tìm vị trí hiện tại
          FloatingActionButton.small(
            heroTag: 'myLocation',
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          // Nút tìm kiếm
          FloatingActionButton(
            heroTag: 'search',
            onPressed: _openSearch,
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  /// Xử lý tap trên bản đồ — đặt điểm đến
  void _onMapTap(TapPosition tapPos, LatLng point) async {
    setState(() {
      _destination = point;
      _destinationName = '';
      _routeError = null;
    });

    // Reverse geocode để lấy tên
    final name = await DirectionsService.reverseGeocode(point);
    if (mounted) {
      setState(() => _destinationName = name);
    }

    _calculateRoute();
  }

  /// Mở màn hình tìm kiếm
  Future<void> _openSearch() async {
    final Place? result = await Navigator.pushNamed(
      context,
      AppRoutes.search,
    ) as Place?;

    if (result != null && mounted) {
      setState(() {
        _destination = result.location;
        _destinationName = result.displayName;
        _routeError = null;
      });

      // Di chuyển bản đồ tới điểm đến
      _mapController.move(result.location, 15.0);
      _calculateRoute();
    }
  }

  /// Tính tuyến đường từ vị trí hiện tại tới điểm đến
  Future<void> _calculateRoute() async {
    final locationService = context.read<LocationService>();
    final pos = locationService.currentPosition;

    if (pos == null || _destination == null) {
      setState(() => _routeError = 'Chưa có vị trí hoặc điểm đến');
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
      _previewRoute = null;
    });

    try {
      final route = await DirectionsService.getRoute(
        origin: LatLng(pos.latitude, pos.longitude),
        destination: _destination!,
        destinationName: _destinationName,
      );

      if (mounted) {
        setState(() {
          _previewRoute = route;
          _isLoadingRoute = false;
          if (route == null) {
            _routeError = 'Không tìm thấy đường đi';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _routeError = e.toString();
        });
      }
    }
  }

  /// Bắt đầu dẫn đường
  void _startNavigation() {
    if (_previewRoute == null) return;

    final navService = context.read<NavigationService>();
    final watchBridge = context.read<WatchBridge>();

    navService.setWatchBridge(watchBridge);
    navService.startNavigation(_previewRoute!);

    Navigator.pushNamed(context, AppRoutes.navigation);
  }

  /// Xóa route preview
  void _clearRoute() {
    setState(() {
      _destination = null;
      _destinationName = '';
      _previewRoute = null;
      _routeError = null;
    });
  }

  /// Di chuyển bản đồ về vị trí hiện tại
  void _goToCurrentLocation() async {
    final locationService = context.read<LocationService>();
    final pos = await locationService.getCurrentPosition();
    if (pos != null) {
      _mapController.move(LatLng(pos.latitude, pos.longitude), 16.0);
    }
  }
}
