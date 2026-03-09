import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  static const String _keyColumnLabels = 'column_labels';
  static const String _keyStatusTrueLabel = 'status_true_label';
  static const String _keyStatusFalseLabel = 'status_false_label';
  static const String _keyMaintenancePeriodMonths = 'maintenance_period_months';
  static const String _keyMaintenanceReminderDays = 'maintenance_reminder_days';
  static const String _keyHiddenColumns = 'hidden_columns';

  /// Rapor başlığı varsayılanı (ayarlarda boş bırakılırsa kullanılır).
  static const String defaultReportTitle = 'ENVANTER BAKIM DEĞERİ';

  /// Tablo sütunları için varsayılan başlıklar.
  static const Map<String, String> defaultColumnLabels = {
    'sira': 'Sıra',
    'inventory_no': 'Demirbaş No',
    'elevator_no': 'Asansör No',
    'material_name': 'Malzeme Adı',
    'unit_location': 'Bulunduğu Birim',
    'maintenance_date': 'Tarih',
    'action_done': 'Yapılan İşlem',
    'technician': 'Bakım Yapan',
    'status': 'Durum',
  };

  /// Durum alanı için varsayılan metinler.
  static const String defaultStatusTrueLabel = 'Yapıldı';
  static const String defaultStatusFalseLabel = 'Yapılmadı';

  /// Bakım periyodu ve hatırlatma için varsayılanlar.
  /// Varsayılan: 3 ayda bir bakım, 30 gün önce hatırlatma.
  static const int defaultMaintenancePeriodMonths = 3;
  static const int defaultMaintenanceReminderDays = 30;

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

  /// Kullanıcı tarafından özelleştirilmiş tablo sütun başlıklarını döndürür.
  /// Kayıt yoksa varsayılan başlıklar kullanılır.
  Future<Map<String, String>> getColumnLabels() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyColumnLabels);
    if (json == null || json.isEmpty) {
      return Map<String, String>.from(defaultColumnLabels);
    }
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final labels = <String, String>{};
      for (final entry in map.entries) {
        final key = entry.key;
        final value = entry.value?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          labels[key] = value;
        }
      }
      // Eksik anahtarlar için varsayılanı tamamla.
      for (final entry in defaultColumnLabels.entries) {
        labels.putIfAbsent(entry.key, () => entry.value);
      }
      return labels;
    } catch (_) {
      return Map<String, String>.from(defaultColumnLabels);
    }
  }

  /// Tablo sütun başlıklarını kaydeder. Boş bırakılanlar varsayılan ile doldurulur.
  Future<void> saveColumnLabels(Map<String, String> labels) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = <String, String>{};
    labels.forEach((key, value) {
      final v = value.trim();
      if (v.isNotEmpty) {
        cleaned[key] = v;
      }
    });
    if (cleaned.isEmpty) {
      await prefs.remove(_keyColumnLabels);
    } else {
      await prefs.setString(_keyColumnLabels, jsonEncode(cleaned));
    }
  }

  Future<String> getStatusTrueLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_keyStatusTrueLabel) ?? '';
    if (v.trim().isEmpty) return defaultStatusTrueLabel;
    return v.trim();
  }

  Future<String> getStatusFalseLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_keyStatusFalseLabel) ?? '';
    if (v.trim().isEmpty) return defaultStatusFalseLabel;
    return v.trim();
  }

  Future<void> saveStatusLabels({
    required String trueLabel,
    required String falseLabel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final t = trueLabel.trim();
    final f = falseLabel.trim();
    if (t.isEmpty) {
      await prefs.remove(_keyStatusTrueLabel);
    } else {
      await prefs.setString(_keyStatusTrueLabel, t);
    }
    if (f.isEmpty) {
      await prefs.remove(_keyStatusFalseLabel);
    } else {
      await prefs.setString(_keyStatusFalseLabel, f);
    }
  }

  /// Global bakım periyodu (ay cinsinden). 3, 6, 12 gibi değerler beklenir.
  Future<int> getMaintenancePeriodMonths() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyMaintenancePeriodMonths);
    if (value == null || value <= 0) {
      return defaultMaintenancePeriodMonths;
    }
    return value;
  }

  /// Bakım hatırlatma eşiği (kaç gün önce uyarı gösterileceği).
  Future<int> getMaintenanceReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyMaintenanceReminderDays);
    if (value == null || value < 0) {
      return defaultMaintenanceReminderDays;
    }
    return value;
  }

  Future<void> saveMaintenanceReminderSettings({
    required int periodMonths,
    required int reminderDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _keyMaintenancePeriodMonths,
      periodMonths > 0 ? periodMonths : defaultMaintenancePeriodMonths,
    );
    await prefs.setInt(
      _keyMaintenanceReminderDays,
      reminderDays >= 0 ? reminderDays : defaultMaintenanceReminderDays,
    );
  }

  /// Global olarak gizlenen sütun id'lerini döndürür.
  Future<List<String>> getHiddenColumnIds() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHiddenColumns);
    if (json == null || json.isEmpty) return <String>[];
    try {
      final list = (jsonDecode(json) as List<dynamic>).map((e) => e.toString()).toList();
      // Sadece bilinen sütun id'lerini kabul et.
      return list.where((id) => defaultColumnLabels.keys.contains(id)).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> saveHiddenColumnIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final valid = ids.where((id) => defaultColumnLabels.keys.contains(id)).toList();
    if (valid.isEmpty) {
      await prefs.remove(_keyHiddenColumns);
    } else {
      await prefs.setString(_keyHiddenColumns, jsonEncode(valid));
    }
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
