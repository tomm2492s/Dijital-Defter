import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/maintenance_record.dart';
import '../services/error_log_service.dart';
import '../services/report_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

/// Rapor ekranı: tarih aralığı seçimi, PDF/DOCX oluşturma, önizleme ve paylaşım.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _reportService = ReportService.instance;
  final _settings = SettingsService.instance;
  final _storage = StorageService.instance;

  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now();
  bool _landscape = true;
  bool _isGenerating = false;
  String? _error;

  Future<void> _pickDateFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateFrom,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _dateFrom = d);
  }

  Future<void> _pickDateTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateTo,
      firstDate: _dateFrom,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _dateTo = d);
  }

  Future<Map<String, String>> _loadHeaderInfo() async {
    return _settings.load();
  }

  Future<List<MaintenanceRecord>> _loadRecords() async {
    final start = DateTime(_dateFrom.year, _dateFrom.month, _dateFrom.day);
    final end = DateTime(_dateTo.year, _dateTo.month, _dateTo.day);
    if (start.isAfter(end)) {
      setState(() => _error = 'Başlangıç tarihi bitişten sonra olamaz.');
      return [];
    }
    setState(() => _error = null);
    return _reportService.getRecordsForReport(start, end);
  }

  Future<void> _generatePdf() async {
    final msg = await _reportService.checkSettingsForReport();
    if (msg != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final headerInfo = await _loadHeaderInfo();
      final records = await _loadRecords();
      final columnLabels = await _settings.getColumnLabels();
      final statusTrue = await _settings.getStatusTrueLabel();
      final statusFalse = await _settings.getStatusFalseLabel();
      if (records.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seçilen tarih aralığında kayıt bulunamadı.')),
        );
        setState(() => _isGenerating = false);
        return;
      }
      final bytes = await _reportService.buildPdf(
        records: records,
        headerInfo: headerInfo,
        columnLabels: columnLabels,
        statusTrueLabel: statusTrue,
        statusFalseLabel: statusFalse,
        landscape: _landscape,
      );
      if (!mounted) return;
      setState(() => _isGenerating = false);

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('PDF Rapor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rapor oluşturuldu. Önizle veya paylaş.'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: PdfPreview(
                    build: (_) => Future.value(bytes),
                    initialPageFormat: _landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kapat'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final name = 'envanter_bakim_rapor_${DateFormat('yyyyMMdd').format(_dateFrom)}_${DateFormat('yyyyMMdd').format(_dateTo)}.pdf';
                  final file = await _storage.saveReportToDocuments(bytes, name);
                  await Share.shareXFiles([XFile(file.path)], subject: 'Envanter bakım raporu (PDF)');
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e, stackTrace) {
                  ErrorLogService.instance.logError(e, stackTrace, context: 'Rapor - PDF paylaş');
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(StorageService.messageForStorageError(e)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Paylaş'),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Rapor - PDF oluştur');
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateDocx() async {
    final msg = await _reportService.checkSettingsForReport();
    if (msg != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final headerInfo = await _loadHeaderInfo();
      final records = await _loadRecords();
      final columnLabels = await _settings.getColumnLabels();
      final statusTrue = await _settings.getStatusTrueLabel();
      final statusFalse = await _settings.getStatusFalseLabel();
      if (records.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seçilen tarih aralığında kayıt bulunamadı.')),
        );
        setState(() => _isGenerating = false);
        return;
      }
      final bytes = await _reportService.buildDocx(
        records: records,
        headerInfo: headerInfo,
        columnLabels: columnLabels,
        statusTrueLabel: statusTrue,
        statusFalseLabel: statusFalse,
      );
      if (!mounted) return;
      setState(() => _isGenerating = false);

      final name = 'envanter_bakim_rapor_${DateFormat('yyyyMMdd').format(_dateFrom)}_${DateFormat('yyyyMMdd').format(_dateTo)}.docx';
      final file = await _storage.saveReportToDocuments(bytes, name);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Envanter Bakım Raporu',
        text: 'Tarih aralığı: ${DateFormat('dd.MM.yyyy').format(_dateFrom)} - ${DateFormat('dd.MM.yyyy').format(_dateTo)}',
      );
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Rapor - DOCX oluştur');
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Al'),
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Tarih aralığını seçin ve rapor formatını belirleyin.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Başlangıç tarihi'),
                  subtitle: Text(dateFormat.format(_dateFrom)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateFrom,
                ),
                ListTile(
                  title: const Text('Bitiş tarihi'),
                  subtitle: Text(dateFormat.format(_dateTo)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTo,
                ),
                SwitchListTile(
                  title: const Text('Yatay sayfa (landscape)'),
                  subtitle: const Text('Tablo geniş olduğunda önerilir'),
                  value: _landscape,
                  onChanged: (v) => setState(() => _landscape = v),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('PDF Oluştur ve Önizle / Paylaş'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _generateDocx,
                  icon: const Icon(Icons.description),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('DOCX Oluştur ve Paylaş'),
                  ),
                ),
              ],
            ),
    );
  }
}
