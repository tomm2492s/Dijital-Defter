import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Rapor ve yedek dosyalarının Belgeler klasöründe oluşturulması; hata durumunda anlamlı mesaj.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _appFolder = 'DijitalDefter';
  static const String _reportsFolder = 'Raporlar';
  static const String _backupFolder = 'Yedekler';

  /// Uygulama Belgeler alt klasörü: [Documents]/DijitalDefter/
  Future<Directory> _getAppDocumentsDir() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory(join(doc.path, _appFolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Raporlar klasörü: [Documents]/DijitalDefter/Raporlar/
  Future<Directory> getReportsDirectory() async {
    final app = await _getAppDocumentsDir();
    final dir = Directory(join(app.path, _reportsFolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Yedekler klasörü: [Documents]/DijitalDefter/Yedekler/
  Future<Directory> getBackupDirectory() async {
    final app = await _getAppDocumentsDir();
    final dir = Directory(join(app.path, _backupFolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// PDF/DOCX dosyasını Raporlar klasörüne yazar. Depolama hatasında [IOException] fırlatır.
  Future<File> saveReportToDocuments(Uint8List bytes, String filename) async {
    final dir = await getReportsDirectory();
    final file = File(join(dir.path, filename));
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Veritabanı dosyasını Yedekler klasörüne kopyalar. [sourcePath] kaynak .db dosya yolu.
  Future<File> copyDatabaseToBackup(String sourcePath, String backupFilename) async {
    final dir = await getBackupDirectory();
    final dest = File(join(dir.path, backupFilename));
    await File(sourcePath).copy(dest.path);
    return dest;
  }

  /// JSON veya diğer veriyi Yedekler klasörüne yazar.
  Future<File> writeBytesToBackup(Uint8List bytes, String filename) async {
    final dir = await getBackupDirectory();
    final file = File(join(dir.path, filename));
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Depolama/dosya yazma hatalarında kullanıcıya gösterilecek kısa mesaj.
  static String messageForStorageError(Object error) {
    if (error is IOException) {
      return 'Depolama dolu veya dosya yazılamadı. Lütfen depolama alanını kontrol edin.';
    }
    return 'Dosya işlemi başarısız: $error';
  }
}
