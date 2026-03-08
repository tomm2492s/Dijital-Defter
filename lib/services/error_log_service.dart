import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Uygulama hatalarını cihaz hafızasına kaydeder; paylaşılabilir metin dosyası üretir (örn. WhatsApp).
class ErrorLogService {
  ErrorLogService._();
  static final ErrorLogService instance = ErrorLogService._();

  static const String _appFolder = 'DijitalDefter';
  static const String _errorLogFolder = 'HataKayitlari';
  static const String _logFileName = 'error_log.json';
  static const int _maxEntries = 500;

  Future<Directory> _getErrorLogDirectory() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory(join(doc.path, _appFolder, _errorLogFolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _getLogFile() async {
    final dir = await _getErrorLogDirectory();
    return File(join(dir.path, _logFileName));
  }

  /// Hata kaydı: mesaj, stack trace, zaman, isteğe bağlı bağlam. Tüm veriler dosyaya yazılır.
  Future<void> logError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    try {
      final file = await _getLogFile();
      final List<Map<String, dynamic>> entries = await _loadEntries(file);
      final entry = <String, dynamic>{
        'time': DateTime.now().toUtc().toIso8601String(),
        'message': error.toString(),
        'type': error.runtimeType.toString(),
        'stackTrace': stackTrace?.toString(),
        'context': context,
      };
      entries.insert(0, entry);
      while (entries.length > _maxEntries) {
        entries.removeLast();
      }
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(entries),
        encoding: utf8,
      );
    } catch (_) {
      // Log yazarken hata olursa sessizce geç (döngüye girmemek için)
    }
  }

  Future<List<Map<String, dynamic>>> _loadEntries(File file) async {
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString(encoding: utf8);
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
          decoded.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}),
        );
      }
    } catch (_) {}
    return [];
  }

  /// Kayıtlı hata var mı?
  Future<bool> get hasErrors async {
    final file = await _getLogFile();
    if (!await file.exists()) return false;
    final entries = await _loadEntries(file);
    return entries.isNotEmpty;
  }

  /// Tüm kayıtları okunabilir metin dosyasına yazar; dosyayı döndürür (paylaşım için).
  /// Dosya adı: dijital_defter_hata_raporu_YYYYMMdd_HHmmss.txt
  Future<File?> createShareableReportFile() async {
    final file = await _getLogFile();
    final entries = await _loadEntries(file);
    if (entries.isEmpty) return null;

    final dir = await _getErrorLogDirectory();
    final dateStr = DateFormat('yyyyMMdd_Hms').format(DateTime.now());
    final reportFile = File(join(dir.path, 'dijital_defter_hata_raporu_$dateStr.txt'));
    final sb = StringBuffer();

    sb.writeln('========================================');
    sb.writeln('Dijital Defter - Hata Raporu');
    sb.writeln('Oluşturulma: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now())}');
    sb.writeln('Kayıt sayısı: ${entries.length}');
    sb.writeln('========================================');
    sb.writeln();

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      sb.writeln('--- Hata ${i + 1} ---');
      sb.writeln('Zaman: ${e['time'] ?? '-'}');
      sb.writeln('Bağlam: ${e['context'] ?? '-'}');
      sb.writeln('Tür: ${e['type'] ?? '-'}');
      sb.writeln('Mesaj: ${e['message'] ?? '-'}');
      final st = e['stackTrace']?.toString();
      if (st != null && st.isNotEmpty) {
        sb.writeln('Stack trace:');
        sb.writeln(st);
      }
      sb.writeln();
    }

    await reportFile.writeAsString(sb.toString(), encoding: utf8);
    return reportFile;
  }

  /// Hata raporu dosyasını oluşturur ve paylaşım (WhatsApp vb.) açar. Kayıt yoksa false döner.
  Future<bool> shareErrorReport() async {
    final file = await createShareableReportFile();
    if (file == null) return false;
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Dijital Defter - Hata Raporu',
      text: 'Uygulama hata raporu ektedir.',
    );
    return true;
  }

  /// Log dosyasını temizler (tüm kayıtları siler).
  Future<void> clearLog() async {
    final file = await _getLogFile();
    if (await file.exists()) await file.writeAsString('[]', encoding: utf8);
  }
}
