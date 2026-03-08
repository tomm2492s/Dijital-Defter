import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/error_log_service.dart';
import 'services/settings_service.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      final log = ErrorLogService.instance;
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        log.logError(
          details.exception,
          details.stack,
          context: 'FlutterError',
        );
      };
      runApp(const DijitalDefterApp());
    },
    (error, stackTrace) {
      ErrorLogService.instance.logError(error, stackTrace, context: 'ZonedGuarded');
    },
  );
}

class DijitalDefterApp extends StatefulWidget {
  const DijitalDefterApp({super.key});

  @override
  State<DijitalDefterApp> createState() => _DijitalDefterAppState();
}

class _DijitalDefterAppState extends State<DijitalDefterApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await SettingsService.instance.getThemeMode();
    if (mounted) setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dijital Defter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: DashboardScreen(onThemeReload: () => _loadTheme()),
    );
  }
}

