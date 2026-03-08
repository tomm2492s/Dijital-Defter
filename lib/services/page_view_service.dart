import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/table_columns.dart';
import 'database_service.dart';

/// Sayfa bazlı tablo görünümü: hangi sütunların görüneceği ve sırası.
/// Veritabanında saklanır; uygulama kapatılıp açılsa da kalır.
class PageViewService {
  PageViewService._();
  static final PageViewService instance = PageViewService._();

  final DatabaseService _db = DatabaseService.instance;
  static String _prefsKey(int? pageId) => 'page_columns_${pageId ?? 0}';

  /// Bu sayfa için kayıtlı sütun id listesini döndürür; yoksa varsayılan.
  Future<List<String>> getColumnIds(int? pageId) async {
    var ids = await _db.getPageViewColumnIds(pageId);
    if (ids == null || ids.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_prefsKey(pageId));
      if (json != null && json.isNotEmpty) {
        try {
          ids = (jsonDecode(json) as List<dynamic>).map((e) => e.toString()).toList();
          if (ids.isNotEmpty) await _db.savePageViewColumnIds(pageId, ids);
        } catch (_) {}
      }
    }
    if (ids == null || ids.isEmpty) return List.from(kDefaultColumnIds);
    return List.from(ids);
  }

  /// Bu sayfa için sütun id listesini kaydeder (veritabanında kalıcı).
  Future<void> saveColumnIds(int? pageId, List<String> columnIds) async {
    await _db.savePageViewColumnIds(pageId, columnIds);
  }
}
