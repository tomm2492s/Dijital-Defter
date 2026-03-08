import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../services/error_log_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

/// Ayarlar ekranı: Kurum Adı, Birim, Sorumlu Kişi, Dönem.
/// Kaydedilen değerler ileride PDF/DOCX rapor üst bilgisi olarak kullanılacak.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settings = SettingsService.instance;
  final _db = DatabaseService.instance;
  final _storage = StorageService.instance;
  final _errorLog = ErrorLogService.instance;
  bool _isBackingUp = false;
  bool _isSharingError = false;

  late TextEditingController _reportTitleController;
  late TextEditingController _institutionController;
  late TextEditingController _departmentController;
  late TextEditingController _responsibleController;
  late TextEditingController _periodController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reportTitleController = TextEditingController();
    _institutionController = TextEditingController();
    _departmentController = TextEditingController();
    _responsibleController = TextEditingController();
    _periodController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await _settings.load();
    _reportTitleController.text = data['report_title'] ?? '';
    _institutionController.text = data['institution_name'] ?? '';
    _departmentController.text = data['department'] ?? '';
    _responsibleController.text = data['responsible_person'] ?? '';
    _periodController.text = data['period'] ?? '';
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    _responsibleController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _settings.save(
        reportTitle: _reportTitleController.text.trim(),
        institutionName: _institutionController.text.trim(),
        department: _departmentController.text.trim(),
        responsiblePerson: _responsibleController.text.trim(),
        period: _periodController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar kaydedildi.')),
        );
      }
    } catch (e, stackTrace) {
      await _errorLog.logError(e, stackTrace, context: 'Ayarlar kaydetme');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedilemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Bilgi kartı
                  Card(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bu bilgiler PDF/DOCX raporlarında üst bilgi olarak kullanılacaktır.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rapor başlığı (PDF/DOCX'te görünen ana başlık)
                  TextFormField(
                    controller: _reportTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Rapor başlığı',
                      hintText: 'ENVANTER BAKIM DEĞERİ',
                      prefixIcon: Icon(Icons.title),
                    ),
                    maxLength: 150,
                  ),
                  const SizedBox(height: 8),

                  // Kurum / İşletme Adı
                  TextFormField(
                    controller: _institutionController,
                    decoration: const InputDecoration(
                      labelText: 'Kurum / İşletme Adı *',
                      prefixIcon: Icon(Icons.business),
                    ),
                    maxLength: 200,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Kurum / İşletme Adı zorunludur.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Birim
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Birim',
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 8),

                  // Sorumlu Kişi
                  TextFormField(
                    controller: _responsibleController,
                    decoration: const InputDecoration(
                      labelText: 'Sorumlu Kişi',
                      prefixIcon: Icon(Icons.person),
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 8),

                  // Dönem
                  TextFormField(
                    controller: _periodController,
                    decoration: const InputDecoration(
                      labelText: 'Dönem',
                      hintText: 'ör. 2026 - 1. Çeyrek',
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 24),

                  // Kaydet butonu
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Kaydet'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Neler yeni
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Neler yeni',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.new_releases),
                      title: const Text('Yapılan işler ve güncellemeler'),
                      subtitle: const Text('Son değişiklikleri görüntüle'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showWhatsNew(context),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Yedekleme bölümü
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Yedekleme',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Veritabanı ve verileri cihazda Belgeler / DijitalDefter / Yedekler klasörüne kaydedebilir veya paylaşabilirsiniz.',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _isBackingUp
                                ? null
                                : () async => _backupDatabase(),
                            icon: const Icon(Icons.backup),
                            label: const Text('Veritabanını yedekle (.db)'),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: _isBackingUp
                                ? null
                                : () async => _exportJson(),
                            icon: const Icon(Icons.code),
                            label: const Text('Veriyi JSON olarak dışa aktar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Hata kayıtları
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Hata kayıtları',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Uygulama hataları cihazda saklanır. Hata raporunu WhatsApp veya e-posta ile paylaşabilirsiniz.',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _isSharingError
                                ? null
                                : () async => _shareErrorReport(),
                            icon: const Icon(Icons.bug_report),
                            label: const Text('Hata raporunu paylaş'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _backupDatabase() async {
    setState(() => _isBackingUp = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dbPath = await _db.getDatabaseFilePath();
      final name = 'dijital_defter_${DateFormat('yyyyMMdd_Hm').format(DateTime.now())}.db';
      final file = await _storage.copyDatabaseToBackup(dbPath, name);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Yedek oluşturuldu: ${file.path}'),
            action: SnackBarAction(
              label: 'Paylaş',
              onPressed: () => Share.shareXFiles([XFile(file.path)], subject: 'Veritabanı yedek'),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      await _errorLog.logError(e, stackTrace, context: 'Ayarlar - Veritabanı yedekleme');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _exportJson() async {
    setState(() => _isBackingUp = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final jsonBytes = await _db.exportDataAsJson();
      final name = 'dijital_defter_${DateFormat('yyyyMMdd_Hm').format(DateTime.now())}.json';
      final file = await _storage.writeBytesToBackup(jsonBytes, name);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('JSON dışa aktarıldı: ${file.path}'),
            action: SnackBarAction(
              label: 'Paylaş',
              onPressed: () => Share.shareXFiles([XFile(file.path)], subject: 'Veri yedek (JSON)'),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      await _errorLog.logError(e, stackTrace, context: 'Ayarlar - JSON dışa aktarma');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  void _showWhatsNew(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.new_releases, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Neler yeni',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: const [
                  _WhatsNewItem(
                    version: 'Uygulama özellikleri',
                    date: '',
                    items: [
                      'Sayfa yapısı: Kayıtlar defter sayfaları altında gruplanır; ana ekranda sayfa listesi, sayfa detayında tablo görünümü.',
                      'Sayfa yönetimi: Sayfaları adlandırma, sürükleyerek sıralama ve silme.',
                      'Tablo görünümü: Sütun seçimi ve sırası düzenlenebilir; ayarlar cihazda saklanır.',
                      'Veri girişi: Demirbaş No, Asansör No, Malzeme Adı, Birim, Bakım Tarihi, Yapılan İşlem, Bakım Yapan, Durum (Yapıldı/Yapılmadı).',
                      'Ardışık kayıt: "Kaydet ve yeni kayıt ekle" ile çıkmadan çok satır eklenebilir.',
                      'Raporlama: PDF ve DOCX; kurum bilgileri, Türkçe karakter, çok satırlı metin.',
                      'Rapor menüsü: PDF ile görüntüle, PDF kaydet/paylaş, DOCX ile görüntüle, DOCX kaydet/paylaş.',
                      'PDF önizleme: Tam ekran, yakınlaştırma/sürükleme (InteractiveViewer).',
                      'Ayarlar: Kurum adı, birim, sorumlu, dönem, rapor başlığı.',
                      'Yedekleme: Veritabanı (.db) ve JSON dışa aktarma; paylaşım.',
                      'Offline: Veriler cihazda (SQLite); internet gerekmez.',
                    ],
                  ),
                  _WhatsNewItem(
                    version: 'v1.0.0',
                    date: 'Son güncellemeler',
                    items: [
                      'Hata loglama: Hatalar cihazda saklanır; Ayarlar > Hata raporunu paylaş ile WhatsApp/e-posta gönderilebilir.',
                      'PDF önizleme: Önizleme alanında beyaz arka plan.',
                      'Global hata yakalama: Yakalanmamış hatalar da kaydedilir.',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareErrorReport() async {
    setState(() => _isSharingError = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await _errorLog.shareErrorReport();
      if (mounted && !shared) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Kayıtlı hata yok.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharingError = false);
    }
  }
}

class _WhatsNewItem extends StatelessWidget {
  const _WhatsNewItem({
    required this.version,
    required this.date,
    required this.items,
  });

  final String version;
  final String date;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                version,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (date.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
