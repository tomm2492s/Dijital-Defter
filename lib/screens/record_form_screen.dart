import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/maintenance_record.dart';
import '../services/database_service.dart';
import '../services/error_log_service.dart';
import '../services/report_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

/// Veri giriş ekranı: tüm alanlar, validasyon, ekleme/güncelleme.
class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({super.key, this.record, this.pageId});

  /// Düzenleme için mevcut kayıt; null ise yeni kayıt.
  final MaintenanceRecord? record;
  /// Yeni kayıt hangi sayfaya eklenecek (sayfa detaydan açıldıysa dolu).
  final int? pageId;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService.instance;
  final _reportService = ReportService.instance;
  final _settings = SettingsService.instance;
  final _storage = StorageService.instance;

  // Ayarlardan gelen sütun başlıkları (form için).
  String _inventoryLabel = SettingsService.defaultColumnLabels['inventory_no']!;
  String _elevatorLabel = SettingsService.defaultColumnLabels['elevator_no']!;
  String _materialLabel = SettingsService.defaultColumnLabels['material_name']!;
  String _unitLocationLabel = SettingsService.defaultColumnLabels['unit_location']!;
  String _dateLabel = SettingsService.defaultColumnLabels['maintenance_date']!;
  String _actionLabel = SettingsService.defaultColumnLabels['action_done']!;
  String _technicianLabel = SettingsService.defaultColumnLabels['technician']!;
  String _statusColumnLabel = SettingsService.defaultColumnLabels['status']!;
  String _statusTrueLabel = SettingsService.defaultStatusTrueLabel;
  String _statusFalseLabel = SettingsService.defaultStatusFalseLabel;

  late TextEditingController _inventoryNoController;
  late TextEditingController _elevatorNoController;
  late TextEditingController _materialNameController;
  late TextEditingController _unitLocationController;
  late TextEditingController _actionDoneController;
  late TextEditingController _technicianController;

  late DateTime _maintenanceDate;
  late bool _status;

  /// Bu ekranda art arda kaç kayıt kaydedildi (1. satır, 2. satır... mesajı için).
  int _savedCountInSession = 0;

  /// Bu oturumda kaydedilen kayıtların id listesi (PDF/DOCX’e hepsini dahil etmek için).
  final List<int> _savedRecordIdsInSession = [];

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _inventoryNoController = TextEditingController(text: r?.inventoryNo ?? '');
    _elevatorNoController = TextEditingController(text: r?.elevatorNo ?? '');
    _materialNameController = TextEditingController(text: r?.materialName ?? '');
    _unitLocationController = TextEditingController(text: r?.unitLocation ?? '');
    _actionDoneController = TextEditingController(text: r?.actionDone ?? '');
    _technicianController = TextEditingController(text: r?.technician ?? '');
    _maintenanceDate = r?.maintenanceDate ?? DateTime.now();
    _status = r?.status ?? true;
    _loadColumnAndStatusLabels();
  }

  Future<void> _loadColumnAndStatusLabels() async {
    final labels = await _settings.getColumnLabels();
    final trueLabel = await _settings.getStatusTrueLabel();
    final falseLabel = await _settings.getStatusFalseLabel();
    if (!mounted) return;
    setState(() {
      _inventoryLabel =
          (labels['inventory_no']?.trim().isNotEmpty ?? false) ? labels['inventory_no']!.trim() : SettingsService.defaultColumnLabels['inventory_no']!;
      _elevatorLabel =
          (labels['elevator_no']?.trim().isNotEmpty ?? false) ? labels['elevator_no']!.trim() : SettingsService.defaultColumnLabels['elevator_no']!;
      _materialLabel =
          (labels['material_name']?.trim().isNotEmpty ?? false) ? labels['material_name']!.trim() : SettingsService.defaultColumnLabels['material_name']!;
      _unitLocationLabel =
          (labels['unit_location']?.trim().isNotEmpty ?? false) ? labels['unit_location']!.trim() : SettingsService.defaultColumnLabels['unit_location']!;
      _dateLabel =
          (labels['maintenance_date']?.trim().isNotEmpty ?? false) ? labels['maintenance_date']!.trim() : SettingsService.defaultColumnLabels['maintenance_date']!;
      _actionLabel =
          (labels['action_done']?.trim().isNotEmpty ?? false) ? labels['action_done']!.trim() : SettingsService.defaultColumnLabels['action_done']!;
      _technicianLabel =
          (labels['technician']?.trim().isNotEmpty ?? false) ? labels['technician']!.trim() : SettingsService.defaultColumnLabels['technician']!;
      _statusColumnLabel =
          (labels['status']?.trim().isNotEmpty ?? false) ? labels['status']!.trim() : SettingsService.defaultColumnLabels['status']!;
      _statusTrueLabel = trueLabel;
      _statusFalseLabel = falseLabel;
    });
  }

  @override
  void dispose() {
    _inventoryNoController.dispose();
    _elevatorNoController.dispose();
    _materialNameController.dispose();
    _unitLocationController.dispose();
    _actionDoneController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _maintenanceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _maintenanceDate = picked);
  }

  /// Formdaki güncel değerlerden bakım kaydı oluşturur (kaydetmeden döküman için kullanılır).
  MaintenanceRecord _getCurrentRecord() {
    return MaintenanceRecord(
      id: widget.record?.id,
      pageId: widget.pageId ?? widget.record?.pageId,
      inventoryNo: _inventoryNoController.text.trim().isEmpty ? null : _inventoryNoController.text.trim(),
      elevatorNo: _elevatorNoController.text.trim(),
      materialName: _materialNameController.text.trim(),
      unitLocation: _unitLocationController.text.trim(),
      maintenanceDate: _maintenanceDate,
      actionDone: _actionDoneController.text.trim(),
      technician: _technicianController.text.trim(),
      status: _status,
    );
  }

  Future<void> _exportPdf() async {
    final msg = await _reportService.checkSettingsForReport();
    if (msg != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    try {
      final headerInfo = await _settings.load();
      List<MaintenanceRecord> recordsToExport;
      if (!_isEditing && _savedRecordIdsInSession.isNotEmpty) {
        recordsToExport = await _db.getByIds(_savedRecordIdsInSession);
        if (recordsToExport.isEmpty) {
          if (!_formKey.currentState!.validate()) return;
          recordsToExport = [_getCurrentRecord()];
        }
      } else {
        if (!_formKey.currentState!.validate()) return;
        recordsToExport = [_getCurrentRecord()];
      }
      final columnLabels = await _settings.getColumnLabels();
      final statusTrue = await _settings.getStatusTrueLabel();
      final statusFalse = await _settings.getStatusFalseLabel();
      final bytes = await _reportService.buildPdf(
        records: recordsToExport,
        headerInfo: headerInfo,
        columnLabels: columnLabels,
        statusTrueLabel: statusTrue,
        statusFalseLabel: statusFalse,
        landscape: true,
      );
      if (!mounted) return;
      final name = recordsToExport.length > 1
          ? 'envanter_bakim_${recordsToExport.length}satir_${DateFormat('yyyyMMdd_Hm').format(DateTime.now())}.pdf'
          : 'envanter_bakim_${recordsToExport.first.elevatorNo}_${DateFormat('yyyyMMdd').format(recordsToExport.first.maintenanceDate)}.pdf';
      final file = await _storage.saveReportToDocuments(bytes, name);
      await Share.shareXFiles([XFile(file.path)], subject: 'Envanter bakım (PDF)');
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Form - PDF paylaş');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportDocx() async {
    final msg = await _reportService.checkSettingsForReport();
    if (msg != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    try {
      final headerInfo = await _settings.load();
      List<MaintenanceRecord> recordsToExport;
      if (!_isEditing && _savedRecordIdsInSession.isNotEmpty) {
        recordsToExport = await _db.getByIds(_savedRecordIdsInSession);
        if (recordsToExport.isEmpty) {
          if (!_formKey.currentState!.validate()) return;
          recordsToExport = [_getCurrentRecord()];
        }
      } else {
        if (!_formKey.currentState!.validate()) return;
        recordsToExport = [_getCurrentRecord()];
      }
      final columnLabels = await _settings.getColumnLabels();
      final statusTrue = await _settings.getStatusTrueLabel();
      final statusFalse = await _settings.getStatusFalseLabel();
      final bytes = await _reportService.buildDocx(
        records: recordsToExport,
        headerInfo: headerInfo,
        columnLabels: columnLabels,
        statusTrueLabel: statusTrue,
        statusFalseLabel: statusFalse,
      );
      if (!mounted) return;
      final name = recordsToExport.length > 1
          ? 'envanter_bakim_${recordsToExport.length}satir_${DateFormat('yyyyMMdd_Hm').format(DateTime.now())}.docx'
          : 'envanter_bakim_${recordsToExport.first.elevatorNo}_${DateFormat('yyyyMMdd').format(recordsToExport.first.maintenanceDate)}.docx';
      final file = await _storage.saveReportToDocuments(bytes, name);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Envanter Bakım Kaydı',
        text: recordsToExport.length > 1
            ? '${recordsToExport.length} satır kayıt'
            : '${recordsToExport.first.elevatorNo} - ${recordsToExport.first.materialName} (${DateFormat('dd.MM.yyyy').format(recordsToExport.first.maintenanceDate)})',
      );
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Form - DOCX paylaş');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Formu temizleyip yeni kayıt için hazırlar (çıkıp tekrar girmeye gerek kalmaz).
  void _resetFormForNewRecord() {
    _inventoryNoController.clear();
    _elevatorNoController.clear();
    _materialNameController.clear();
    _unitLocationController.clear();
    _actionDoneController.clear();
    _technicianController.clear();
    setState(() {
      _maintenanceDate = DateTime.now();
      _status = true;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _scheduleReminderForRecord(MaintenanceRecord record) async {
    if (record.id == null) return;
    final periodMonths = await _settings.getMaintenancePeriodMonths();
    final reminderDays = await _settings.getMaintenanceReminderDays();
    if (periodMonths <= 0) return;
    final d = record.maintenanceDate;
    final base = DateTime(d.year, d.month, d.day);
    final nextDate = DateTime(base.year, base.month + periodMonths, base.day);
    final scheduledAt = nextDate.subtract(Duration(days: reminderDays));
    if (scheduledAt.isBefore(DateTime.now())) return;
    final title = 'Bakım hatırlatması';
    final body = '${record.elevatorNo} - ${record.materialName} için bakım zamanı yaklaşıyor.';
    await NotificationService.instance.scheduleMaintenanceReminder(
      id: record.id!,
      scheduledAt: scheduledAt,
      title: title,
      body: body,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final record = _getCurrentRecord();
    int? savedId;

    try {
      if (_isEditing) {
        await _db.update(record);
        savedId = record.id;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt güncellendi.')));
          Navigator.of(context).pop();
        }
      } else {
        final id = await _db.insert(record);
        if (!mounted) return;
        setState(() {
          _savedCountInSession++;
          _savedRecordIdsInSession.add(id);
        });
        savedId = id;
        final rowNum = _savedCountInSession;
        await _handleAfterInsert(rowNum);
      }
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Form - kayıt kaydet/güncelle');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veri kaydedilemedi veya güncellenemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Bildirim planlama hataları kaydı etkilemesin; ayrı try-catch içinde tutulur.
    if (savedId != null) {
      try {
        await _scheduleReminderForRecord(record.copyWith(id: savedId));
      } catch (e, stackTrace) {
        ErrorLogService.instance.logError(e, stackTrace, context: 'Form - bakım hatırlatma bildirimi planlama');
      }
    }
  }

  Future<void> _handleAfterInsert(int rowNum) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final addAnother = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('$rowNum. satırdaki veri kaydedildi'),
        content: const Text(
          'Başka kayıt eklemek ister misiniz? Aynı ekranda kalıp yeni satır girebilirsiniz. İşiniz bitince PDF veya DOCX ile dışa aktarabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Listeye dön'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Başka kayıt ekle'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (addAnother == true) {
      _resetFormForNewRecord();
      messenger.showSnackBar(
        SnackBar(content: Text('$rowNum. satır kaydedildi. Yeni satır için form temizlendi.')),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Kayıt Düzenle' : 'Yeni Kayıt'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isEditing && _savedCountInSession > 0)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Şu ana kadar $_savedCountInSession satır kaydedildi. Sıradaki: ${_savedCountInSession + 1}. satır.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isEditing && _savedCountInSession > 0) const SizedBox(height: 12),
            TextFormField(
              controller: _inventoryNoController,
              decoration: InputDecoration(labelText: _inventoryLabel),
              maxLength: 100,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _elevatorNoController,
              decoration: InputDecoration(labelText: '$_elevatorLabel *'),
              maxLength: 50,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Asansör No zorunludur.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _materialNameController,
              decoration: InputDecoration(labelText: '$_materialLabel *'),
              maxLength: 200,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Malzeme Adı zorunludur.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitLocationController,
              decoration: InputDecoration(labelText: '$_unitLocationLabel *'),
              maxLength: 200,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Bulunduğu Birim zorunludur.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text('$_dateLabel *'),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_maintenanceDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _actionDoneController,
              decoration: InputDecoration(labelText: '$_actionLabel *'),
              maxLines: 3,
              maxLength: 500,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Yapılan İşlem zorunludur.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _technicianController,
              decoration: InputDecoration(labelText: '$_technicianLabel *'),
              maxLength: 200,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Bakım Yapan zorunludur.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(_statusColumnLabel),
              subtitle: Text(_status ? _statusTrueLabel : _statusFalseLabel),
              value: _status,
              onChanged: (v) => setState(() => _status = v),
              activeThumbColor: Colors.green,
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Güncelle'),
                ),
              )
            else ...[
              ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Kaydet'),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final record = _getCurrentRecord();
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final id = await _db.insert(record);
                    if (!mounted) return;
                    setState(() {
                      _savedCountInSession++;
                      _savedRecordIdsInSession.add(id);
                    });
                    final rowNum = _savedCountInSession;
                    _resetFormForNewRecord();
                    messenger.showSnackBar(
                      SnackBar(content: Text('$rowNum. satırdaki veri kaydedildi. Yeni satır için form temizlendi.')),
                    );
                  } catch (e, stackTrace) {
                    ErrorLogService.instance.logError(e, stackTrace, context: 'Form - rapor menüsü kayıt kaydet');
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Veri kaydedilemedi. Lütfen tekrar deneyin.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Kaydet ve yeni kayıt ekle'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Bu kaydın dökümanını hemen al',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Formdaki güncel bilgilerle PDF veya Word (DOCX) oluşturup paylaşabilirsiniz. Paylaşımda kaydetme konumu seçebilirsiniz.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!_isEditing && _savedCountInSession > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Tüm kayıtları tarih aralığıyla dışa aktarmak için ana ekrandan "Rapor Al"ı kullanın.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    label: const Text('PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportDocx,
                    icon: const Icon(Icons.description, size: 20),
                    label: const Text('DOCX'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
