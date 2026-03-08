import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ayarlar servisi – SharedPreferences ile kurum bilgilerini ve tema tercihini saklar.
/// Sprint 6'da PDF/DOCX rapor üst bilgisi olarak kullanılacak.
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const String _keyReportTitle = 'report_title';
  static const String _keyInstitution = 'institution_name';
  static const String _keyDepartment = 'department';
  static const String _keyResponsible = 'responsible_person';
  static const String _keyPeriod = 'period';
  static const String _keyThemeMode = 'theme_mode';

  /// Rapor başlığı varsayılanı (ayarlarda boş bırakılırsa kullanılır).
  static const String defaultReportTitle = 'ENVANTER BAKIM DEĞERİ';

  // --- Kaydet ---

  Future<void> save({
    required String reportTitle,
    required String institutionName,
    required String department,
    required String responsiblePerson,
    required String period,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReportTitle, reportTitle.trim());
    await prefs.setString(_keyInstitution, institutionName);
    await prefs.setString(_keyDepartment, department);
    await prefs.setString(_keyResponsible, responsiblePerson);
    await prefs.setString(_keyPeriod, period);
  }

  // --- Yükle ---

  Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _keyReportTitle: prefs.getString(_keyReportTitle) ?? '',
      _keyInstitution: prefs.getString(_keyInstitution) ?? '',
      _keyDepartment: prefs.getString(_keyDepartment) ?? '',
      _keyResponsible: prefs.getString(_keyResponsible) ?? '',
      _keyPeriod: prefs.getString(_keyPeriod) ?? '',
    };
  }

  // --- Tekil getter'lar ---

  Future<String> getReportTitle() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_keyReportTitle) ?? '';
    return t.trim().isEmpty ? defaultReportTitle : t;
  }

  Future<String> getInstitutionName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyInstitution) ?? '';
  }

  Future<String> getDepartment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDepartment) ?? '';
  }

  Future<String> getResponsiblePerson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyResponsible) ?? '';
  }

  Future<String> getPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPeriod) ?? '';
  }

  /// Tema tercihi: 'light', 'dark', 'system'. Varsayılan: system.
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyThemeMode) ?? 'system';
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_keyThemeMode, s);
  }
}
