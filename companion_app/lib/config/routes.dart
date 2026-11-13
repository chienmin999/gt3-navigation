import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/navigation_screen.dart';
import '../screens/watch_connect_screen.dart';
import '../screens/settings_screen.dart';

/// Định nghĩa các route trong ứng dụng
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String search = '/search';
  static const String navigation = '/navigation';
  static const String watchConnect = '/watch-connect';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        search: (_) => const SearchScreen(),
        navigation: (_) => const NavigationScreen(),
        watchConnect: (_) => const WatchConnectScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
