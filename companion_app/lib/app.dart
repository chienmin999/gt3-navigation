import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

/// Widget gốc của ứng dụng — thiết lập theme và routing
class GT3NavApp extends StatelessWidget {
  const GT3NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GT3 Navigation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
