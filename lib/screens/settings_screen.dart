import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../services/error_log_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../utils/app_info.dart';

/// Ayarlar ekranı: Kurum Adı, Birim, Sorumlu Kişi, Dönem.
/// Kaydedilen değerler ileride PDF/DOCX rapor üst bilgisi olarak kullanılacak.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onThemeReload});

  final VoidCallback? onThemeReload;

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
  ThemeMode _themeMode = ThemeMode.system;

  late TextEditingController _reportTitleController;
  late TextEditingController _institutionController;
  late TextEditingController _departmentController;
  late TextEditingController _responsibleController;
  late TextEditingController _periodController;
  late TextEditingController _labelInventoryController;
  late TextEditingController _labelElevatorController;
  late TextEditingController _labelMaterialController;
  late TextEditingController _labelUnitLocationController;
  late TextEditingController _labelDateController;
  late TextEditingController _labelActionController;
  late TextEditingController _labelTechnicianController;
  late TextEditingController _labelStatusController;
  late TextEditingController _statusTrueLabelController;
  late TextEditingController _statusFalseLabelController;

  bool _isLoading = true;
  int _maintenancePeriodMonths = SettingsService.defaultMaintenancePeriodMonths;
  int _maintenanceReminderDays = SettingsService.defaultMaintenanceReminderDays;
  Set<String> _hiddenColumnIds = <String>{};

  @override
  void initState() {
    super.initState();
    _reportTitleController = TextEditingController();
    _institutionController = TextEditingController();
    _departmentController = TextEditingController();
    _responsibleController = TextEditingController();
    _periodController = TextEditingController();
    _labelInventoryController = TextEditingController();
    _labelElevatorController = TextEditingController();
    _labelMaterialController = TextEditingController();
    _labelUnitLocationController = TextEditingController();
    _labelDateController = TextEditingController();
    _labelActionController = TextEditingController();
    _labelTechnicianController = TextEditingController();
    _labelStatusController = TextEditingController();
    _statusTrueLabelController = TextEditingController();
    _statusFalseLabelController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await _settings.load();
    _reportTitleController.text = data['report_title'] ?? '';
    _institutionController.text = data['institution_name'] ?? '';
    _departmentController.text = data['department'] ?? '';
    _responsibleController.text = data['responsible_person'] ?? '';
    _periodController.text = data['period'] ?? '';
    _themeMode = await _settings.getThemeMode();
    final columnLabels = await _settings.getColumnLabels();
    _labelInventoryController.text =
        columnLabels['inventory_no'] ?? SettingsService.defaultColumnLabels['inventory_no']!;
    _labelElevatorController.text =
        columnLabels['elevator_no'] ?? SettingsService.defaultColumnLabels['elevator_no']!;
    _labelMaterialController.text =
        columnLabels['material_name'] ?? SettingsService.defaultColumnLabels['material_name']!;
    _labelUnitLocationController.text =
        columnLabels['unit_location'] ?? SettingsService.defaultColumnLabels['unit_location']!;
    _labelDateController.text =
        columnLabels['maintenance_date'] ?? SettingsService.defaultColumnLabels['maintenance_date']!;
    _labelActionController.text =
        columnLabels['action_done'] ?? SettingsService.defaultColumnLabels['action_done']!;
    _labelTechnicianController.text =
        columnLabels['technician'] ?? SettingsService.defaultColumnLabels['technician']!;
    _labelStatusController.text =
        columnLabels['status'] ?? SettingsService.defaultColumnLabels['status']!;
    _statusTrueLabelController.text = await _settings.getStatusTrueLabel();
    _statusFalseLabelController.text = await _settings.getStatusFalseLabel();
    _maintenancePeriodMonths = await _settings.getMaintenancePeriodMonths();
    _maintenanceReminderDays = await _settings.getMaintenanceReminderDays();
    _hiddenColumnIds = (await _settings.getHiddenColumnIds()).toSet();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await _settings.saveThemeMode(mode);
    if (mounted) setState(() => _themeMode = mode);
    widget.onThemeReload?.call();
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    _responsibleController.dispose();
    _periodController.dispose();
     _labelInventoryController.dispose();
    _labelElevatorController.dispose();
    _labelMaterialController.dispose();
    _labelUnitLocationController.dispose();
    _labelDateController.dispose();
    _labelActionController.dispose();
    _labelTechnicianController.dispose();
    _labelStatusController.dispose();
    _statusTrueLabelController.dispose();
    _statusFalseLabelController.dispose();
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
      await _settings.saveColumnLabels({
        'inventory_no': _labelInventoryController.text,
        'elevator_no': _labelElevatorController.text,
        'material_name': _labelMaterialController.text,
        'unit_location': _labelUnitLocationController.text,
        'maintenance_date': _labelDateController.text,
        'action_done': _labelActionController.text,
        'technician': _labelTechnicianController.text,
        'status': _labelStatusController.text,
      });
      await _settings.saveStatusLabels(
        trueLabel: _statusTrueLabelController.text,
        falseLabel: _statusFalseLabelController.text,
      );
      await _settings.saveMaintenanceReminderSettings(
        periodMonths: _maintenancePeriodMonths,
        reminderDays: _maintenanceReminderDays,
      );
      await _settings.saveHiddenColumnIds(_hiddenColumnIds.toList());
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
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
              // ignore: unnecessary_underscores
              errorBuilder: (_, __, ___) => Icon(
                Icons.settings_rounded,
                size: 28,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Ayarlar'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Tema
                  Text(
                    'Tema',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode),
                                label: Text('Aydınlık'),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode),
                                label: Text('Karanlık'),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto),
                                label: Text('Sistem'),
                              ),
                            ],
                            selected: {_themeMode},
                            onSelectionChanged: (Set<ThemeMode> selected) {
                              final mode = selected.first;
                              _setThemeMode(mode);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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

                  // Bakım hatırlatma ayarları
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Bakım periyodu ve hatırlatma',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: _maintenancePeriodMonths,
                            decoration: const InputDecoration(
                              labelText: 'Global bakım periyodu',
                              helperText: 'Tüm kayıtlar için kullanılacak bakım aralığı.',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 3,
                                child: Text('3 ayda bir'),
                              ),
                              DropdownMenuItem(
                                value: 6,
                                child: Text('6 ayda bir'),
                              ),
                              DropdownMenuItem(
                                value: 12,
                                child: Text('12 ayda bir'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _maintenancePeriodMonths = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _maintenanceReminderDays,
                            decoration: const InputDecoration(
                              labelText: 'Hatırlatma eşiği (gün önce)',
                              helperText: 'Sonraki bakım tarihinden kaç gün önce listede görünsün?',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('Sadece günü geldiğinde'),
                              ),
                              DropdownMenuItem(
                                value: 7,
                                child: Text('7 gün önce'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30 gün önce'),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text('60 gün önce'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _maintenanceReminderDays = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tablo sütun başlıkları ve durum metinleri
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Tablo başlıkları ve durum metinleri',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _labelInventoryController,
                            decoration: const InputDecoration(
                              labelText: 'Demirbaş No sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelElevatorController,
                            decoration: const InputDecoration(
                              labelText: 'Asansör No sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelMaterialController,
                            decoration: const InputDecoration(
                              labelText: 'Malzeme Adı sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelUnitLocationController,
                            decoration: const InputDecoration(
                              labelText: 'Bulunduğu Birim sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelDateController,
                            decoration: const InputDecoration(
                              labelText: 'Tarih sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelActionController,
                            decoration: const InputDecoration(
                              labelText: 'Yapılan İşlem sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelTechnicianController,
                            decoration: const InputDecoration(
                              labelText: 'Bakım Yapan sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelStatusController,
                            decoration: const InputDecoration(
                              labelText: 'Durum sütun başlığı',
                            ),
                            maxLength: 100,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _statusTrueLabelController,
                            decoration: const InputDecoration(
                              labelText: 'Durum = true metni',
                              hintText: 'Örn: Yapıldı',
                            ),
                            maxLength: 50,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _statusFalseLabelController,
                            decoration: const InputDecoration(
                              labelText: 'Durum = false metni',
                              hintText: 'Örn: Yapılmadı',
                            ),
                            maxLength: 50,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Gizlenecek sütunlar',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...SettingsService.defaultColumnLabels.entries.map(
                            (entry) {
                              final id = entry.key;
                              // "Sıra" ve "Durum" sütunlarını gizlemeye izin vermeyelim (kritik bilgiler).
                              final canHide = id != 'sira' && id != 'status';
                              final hidden = _hiddenColumnIds.contains(id);
                              return CheckboxListTile(
                                title: Text('${entry.value} sütununu gizle'),
                                value: hidden,
                                onChanged: !canHide
                                    ? null
                                    : (v) {
                                        setState(() {
                                          if (v == true) {
                                            _hiddenColumnIds.add(id);
                                          } else {
                                            _hiddenColumnIds.remove(id);
                                          }
                                        });
                                      },
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
                  const SizedBox(height: 24),
                  // Hakkında
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Hakkında',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 20, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                AppInfo.appName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sürüm ${AppInfo.version}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Geliştiren: ${AppInfo.developerName}',
                            style: Theme.of(context).textTheme.bodyMedium,
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
                    version: 'v1.0.1',
                    date: 'Son güncellemeler',
                    items: [
                      'Hata loglama: Hatalar cihazda saklanır; Ayarlar > Hata raporunu paylaş ile WhatsApp/e-posta gönderilebilir.',
                      'PDF önizleme: Önizleme alanında beyaz arka plan.',
                      'Global hata yakalama: Yakalanmamış hatalar da kaydedilir.',
                      'Takvim yerelleştirme: DatePicker ve tarih bileşenleri flutter_localizations ile Türkçe gösterilir.',
                      'Tablo başlıkları: Demirbaş No, Asansör No, Malzeme Adı, Bulunduğu Birim, Tarih, Yapılan İşlem, Bakım Yapan ve Durum sütun başlıkları Ayarlar ekranından özelleştirilebilir.',
                      'Durum metinleri: Durum alanı için true/false metinleri (örn. Yapıldı / Yapılmadı) kullanıcı tarafından değiştirilebilir ve tablo, form ve PDF/DOCX raporlarda aynı şekilde kullanılır.',
                      'Bakım periyodu: Global bakım periyodu (3, 6, 12 ay) ve hatırlatma eşiği (0, 7, 30, 60 gün önce) Ayarlar ekranından tanımlanabilir.',
                      'Ana ekranda "Yaklaşan / geciken bakımlar" kartı ile yaklaşan veya geciken bakımlar listelenir ve ilgili defter sayfasına hızlı geçiş yapılabilir.',
                      'Satır sıralama: Sayfa detayında kayıtlar "Bir yukarı taşı / Bir aşağı taşı" seçenekleri ile yeniden sıralanabilir ve bu sıralama PDF/DOCX rapor çıktısına da yansır.',
                      'Sütun gizleme: Ayarlar ekranındaki "Gizlenecek sütunlar" bölümünden seçilen sütunlar tüm tablo görünümlerinden ve PDF/DOCX raporlarından global olarak gizlenir; "Tablo görünümünü düzenle" ekranı da bu ayarlara uyar.',
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
