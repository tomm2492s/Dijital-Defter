import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/error_log_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';

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
      NotificationService.instance.init();
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
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: DashboardScreen(onThemeReload: () => _loadTheme()),
    );
  }
}

