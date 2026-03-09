import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/maintenance_record.dart';
import '../models/sheet_page.dart';

/// Veritabanı singleton – CRUD, transaction, commit.
/// Veritabanı dosyası uygulama veri dizininde "databases" klasöründe saklanır.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _db;
  static const String _dbName = 'dijital_defter.db';
  static const int _version = 5;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final basePath = await _getDatabasesPath();
    final dir = Directory(basePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final path = join(basePath, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sheet_pages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        created_at TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE page_view_config (
        page_id INTEGER PRIMARY KEY,
        column_ids TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE maintenance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        page_id INTEGER REFERENCES sheet_pages(id),
        inventory_no TEXT,
        elevator_no TEXT NOT NULL,
        material_name TEXT NOT NULL,
        unit_location TEXT NOT NULL,
        maintenance_date TEXT NOT NULL,
        action_done TEXT NOT NULL,
        technician TEXT NOT NULL,
        status INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sheet_pages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      try {
        await db.execute('ALTER TABLE maintenance_records ADD COLUMN page_id INTEGER');
      } catch (_) {}
      final now = DateTime.now().toUtc().toIso8601String();
      final firstPageId = await db.insert('sheet_pages', {'title': 'İlk sayfa', 'created_at': now});
      await db.rawUpdate('UPDATE maintenance_records SET page_id = ? WHERE page_id IS NULL', [firstPageId]);
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE sheet_pages ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
      final maps = await db.query('sheet_pages', orderBy: 'id DESC');
      for (var i = 0; i < maps.length; i++) {
        await db.update('sheet_pages', {'sort_order': i}, where: 'id = ?', whereArgs: [maps[i]['id']]);
      }
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS page_view_config (
          page_id INTEGER PRIMARY KEY,
          column_ids TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE maintenance_records ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
      // Mevcut kayıtlar için sayfa bazında sıralama değeri ata.
      final maps = await db.query(
        'maintenance_records',
        orderBy: 'page_id ASC, maintenance_date ASC, id ASC',
      );
      int? currentPageId;
      var sort = 0;
      for (final m in maps) {
        final pageId = m['page_id'] as int?;
        if (pageId != currentPageId) {
          currentPageId = pageId;
          sort = 0;
        }
        final id = m['id'] as int?;
        if (id != null) {
          await db.update(
            'maintenance_records',
            {'sort_order': sort},
            where: 'id = ?',
            whereArgs: [id],
          );
          sort++;
        }
      }
    }
  }

  /// Uygulama veri dizininde "databases" klasörü yolu.
  Future<String> _getDatabasesPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return join(dir.path, 'databases');
  }

  /// Dışa aktarma/yedekleme için veritabanı klasörü yolunu döndürür.
  Future<String> getDatabasesPath() async {
    return _getDatabasesPath();
  }

  /// Yedekleme için veritabanı dosyasının tam yolu.
  Future<String> getDatabaseFilePath() async {
    final base = await _getDatabasesPath();
    return join(base, _dbName);
  }

  /// Tüm sayfa ve kayıtları JSON olarak döndürür (yedekleme/dışa aktarma için).
  Future<Uint8List> exportDataAsJson() async {
    final pages = await getAllPages();
    final records = await getAll();
    final data = {
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'pages': pages.map((p) => p.toMap()).toList(),
      'records': records.map((r) => r.toMap()).toList(),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }

  // --- Sayfalar ---

  Future<int> insertPage(SheetPage page) async {
    final db = await database;
    final map = page.toMap();
    final max = await db.rawQuery('SELECT COALESCE(MAX(sort_order), -1) + 1 as n FROM sheet_pages');
    map['sort_order'] = (max.first['n'] as int?) ?? 0;
    return db.insert('sheet_pages', map);
  }

  Future<List<SheetPage>> getAllPages() async {
    final db = await database;
    final maps = await db.query('sheet_pages', orderBy: 'sort_order ASC, id ASC');
    return maps.map((m) => SheetPage.fromMap(m)).toList();
  }

  Future<int> updatePage(SheetPage page) async {
    if (page.id == null) return 0;
    final db = await database;
    return db.update(
      'sheet_pages',
      page.toMap(),
      where: 'id = ?',
      whereArgs: [page.id],
    );
  }

  Future<void> deletePage(int pageId) async {
    final db = await database;
    await db.delete('maintenance_records', where: 'page_id = ?', whereArgs: [pageId]);
    await db.delete('sheet_pages', where: 'id = ?', whereArgs: [pageId]);
  }

  Future<void> updatePagesOrder(List<SheetPage> pages) async {
    final db = await database;
    for (var i = 0; i < pages.length; i++) {
      final p = pages[i];
      if (p.id != null) {
        await db.update('sheet_pages', {'sort_order': i}, where: 'id = ?', whereArgs: [p.id]);
      }
    }
  }

  Future<SheetPage?> getPageById(int id) async {
    final db = await database;
    final maps = await db.query('sheet_pages', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return SheetPage.fromMap(maps.first);
  }

  /// Sayfa tablo görünümü: sütun id listesi (kalıcı, uygulama yeniden başlayınca da kalır).
  Future<List<String>?> getPageViewColumnIds(int? pageId) async {
    if (pageId == null) return null;
    final db = await database;
    final maps = await db.query('page_view_config', where: 'page_id = ?', whereArgs: [pageId]);
    if (maps.isEmpty) return null;
    final json = maps.first['column_ids'] as String?;
    if (json == null || json.isEmpty) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> savePageViewColumnIds(int? pageId, List<String> columnIds) async {
    if (pageId == null) return;
    final db = await database;
    await db.insert(
      'page_view_config',
      {'page_id': pageId, 'column_ids': jsonEncode(columnIds)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Tüm sayfalar için kayıt sayılarını tek sorguda döndürür (liste geçişlerini hızlandırmak için).
  Future<Map<int, int>> getRecordCountsByPageIds() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT page_id, COUNT(*) as cnt FROM maintenance_records WHERE page_id IS NOT NULL GROUP BY page_id',
    );
    return {for (final m in maps) m['page_id'] as int: m['cnt'] as int};
  }

  Future<List<MaintenanceRecord>> getRecordsByPageId(int pageId) async {
    final db = await database;
    final maps = await db.query(
      'maintenance_records',
      where: 'page_id = ?',
      whereArgs: [pageId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map((m) => MaintenanceRecord.fromMap(m)).toList();
  }

  // --- CRUD (kayıtlar) ---

  Future<int> insert(MaintenanceRecord record) async {
    final db = await database;
    final map = record.toMap();
    if (record.pageId != null) {
      final result = await db.rawQuery(
        'SELECT COALESCE(MAX(sort_order), -1) + 1 as n FROM maintenance_records WHERE page_id = ?',
        [record.pageId],
      );
      final next = (result.first['n'] as int?) ?? 0;
      map['sort_order'] = next;
    }
    return db.insert('maintenance_records', map);
  }

  Future<List<MaintenanceRecord>> getAll({String? elevatorFilter, String? materialFilter}) async {
    final db = await database;
    String? where;
    List<Object?>? whereArgs;
    if (elevatorFilter != null && elevatorFilter.isNotEmpty) {
      where = 'elevator_no LIKE ?';
      whereArgs = ['%$elevatorFilter%'];
    }
    if (materialFilter != null && materialFilter.isNotEmpty) {
      if (where != null) {
        where += ' AND material_name LIKE ?';
        whereArgs!.add('%$materialFilter%');
      } else {
        where = 'material_name LIKE ?';
        whereArgs = ['%$materialFilter%'];
      }
    }
    final maps = await db.query(
      'maintenance_records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'maintenance_date DESC, id DESC',
    );
    return maps.map((m) => MaintenanceRecord.fromMap(m)).toList();
  }

  /// Tarih aralığına göre kayıtları getirir (rapor için).
  Future<List<MaintenanceRecord>> getByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toUtc().toIso8601String().split('T').first;
    final endStr = end.toUtc().toIso8601String().split('T').first;
    final maps = await db.query(
      'maintenance_records',
      where: 'date(maintenance_date) >= ? AND date(maintenance_date) <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'maintenance_date ASC, id ASC',
    );
    return maps.map((m) => MaintenanceRecord.fromMap(m)).toList();
  }

  Future<MaintenanceRecord?> getById(int id) async {
    final db = await database;
    final maps = await db.query('maintenance_records', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return MaintenanceRecord.fromMap(maps.first);
  }

  /// Verilen id listesi sırasına göre kayıtları getirir (form oturumundaki kayıtlar için).
  Future<List<MaintenanceRecord>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final maps = await db.query(
      'maintenance_records',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    final byId = {for (var m in maps) m['id'] as int: MaintenanceRecord.fromMap(m)};
    return [for (final id in ids) byId[id]!];
  }

  Future<int> update(MaintenanceRecord record) async {
    if (record.id == null) return 0;
    final db = await database;
    return db.update(
      'maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> swapRecordSortOrder(MaintenanceRecord a, MaintenanceRecord b) async {
    if (a.id == null || b.id == null) return;
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'maintenance_records',
        {'sort_order': b.sortOrder},
        where: 'id = ?',
        whereArgs: [a.id],
      );
      await txn.update(
        'maintenance_records',
        {'sort_order': a.sortOrder},
        where: 'id = ?',
        whereArgs: [b.id],
      );
    });
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('maintenance_records', where: 'id = ?', whereArgs: [id]);
  }

  /// Transaction ile toplu işlem örneği.
  Future<void> transaction(Future<void> Function(Transaction txn) action) async {
    final db = await database;
    await db.transaction(action);
  }
}
