import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/error_log_service.dart';

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

class DijitalDefterApp extends StatelessWidget {
  const DijitalDefterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dijital Defter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardScreen(),
    );
  }
}

