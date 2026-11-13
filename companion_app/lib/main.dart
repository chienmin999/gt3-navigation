import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/location_service.dart';
import 'services/navigation_service.dart';
import 'services/watch_bridge.dart';

/// Điểm vào chính của ứng dụng GT3 Nav Companion
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => NavigationService()),
        ChangeNotifierProvider(create: (_) => WatchBridge()),
      ],
      child: const GT3NavApp(),
    ),
  );
}
