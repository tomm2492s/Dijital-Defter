import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/maintenance_record.dart';
import '../models/sheet_page.dart';
import '../services/database_service.dart';
import '../services/error_log_service.dart';
import '../services/page_view_service.dart';
import '../services/report_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../utils/table_columns.dart';
import '../widgets/record_table_sheet.dart';
import 'page_view_edit_screen.dart';
import 'pdf_preview_screen.dart';
import 'record_form_screen.dart';

/// Tek bir sayfanın içeriği: başlık + satır satır kayıtlar; satıra tıklanınca düzenleme, yeni satır ekleme, PDF/DOCX.
class PageDetailScreen extends StatefulWidget {
  const PageDetailScreen({super.key, required this.page});

  final SheetPage page;

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
  final DatabaseService _db = DatabaseService.instance;
  final ReportService _reportService = ReportService.instance;
  final SettingsService _settings = SettingsService.instance;
  final StorageService _storage = StorageService.instance;
  final PageViewService _pageView = PageViewService.instance;
  List<String>? _columnIds;
  Future<List<MaintenanceRecord>>? _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadColumnIds();
    _refreshRecords();
  }

  void _refreshRecords() {
    setState(() {
      _recordsFuture = widget.page.id == null
          ? Future.value(<MaintenanceRecord>[])
          : _db.getRecordsByPageId(widget.page.id!);
    });
  }

  Future<List<MaintenanceRecord>> _loadRecords() async {
    if (widget.page.id == null) return [];
    return _db.getRecordsByPageId(widget.page.id!);
  }

  Future<void> _loadColumnIds() async {
    final ids = await _pageView.getColumnIds(widget.page.id);
    if (!mounted) return;
    setState(() => _columnIds = List.from(ids));
  }

  Future<void> _openViewEdit() async {
    if (_columnIds == null) await _loadColumnIds();
    if (!mounted) return;
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute<List<String>>(
        builder: (context) => PageViewEditScreen(
          initialColumnIds: List.from(_columnIds ?? kDefaultColumnIds),
          onSave: (ids) async {
            await _pageView.saveColumnIds(widget.page.id, ids);
          },
        ),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _columnIds = List<String>.from(result));
    }
  }

  void _openForm([MaintenanceRecord? record]) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        // ignore: unnecessary_underscores
        pageBuilder: (_, __, ___) => RecordFormScreen(
          record: record,
          pageId: widget.page.id,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshRecords();
    });
  }

  Future<void> _onDeleteRecord(MaintenanceRecord record) async {
    if (record.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _db.delete(record.id!);
      if (!mounted) return;
      _refreshRecords();
      messenger.showSnackBar(const SnackBar(content: Text('Kayıt silindi.')));
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Sayfa - kayıt silme');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Kayıt silinemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List?> _buildPdfBytes(List<MaintenanceRecord> records) async {
    final msg = await _reportService.checkSettingsForReport();
    if (msg != null) return null;
    final headerInfo = await _settings.load();
    return _reportService.buildPdf(
      records: records,
      headerInfo: headerInfo,
      landscape: true,
    );
  }

  Future<void> _showPdfPreview(List<MaintenanceRecord> records) async {
    final messenger = ScaffoldMessenger.of(context);
    final bytes = await _buildPdfBytes(records);
    if (bytes == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Rapor için Ayarlar\'dan Kurum Adı girin.')));
      return;
    }
    if (!mounted) return;
    final name = 'sayfa_${widget.page.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PdfPreviewScreen(
          bytes: bytes,
          filename: name,
        ),
      ),
    );
  }

  Future<void> _saveOrSharePdf(List<MaintenanceRecord> records) async {
    final messenger = ScaffoldMessenger.of(context);
    final bytes = await _buildPdfBytes(records);
    if (bytes == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Rapor için Ayarlar\'dan Kurum Adı girin.')));
      return;
    }
    try {
      final name = 'sayfa_${widget.page.id}_${DateFormat('yyyyMMdd_Hm').format(DateTime.now())}.pdf';
      final file = await _storage.saveReportToDocuments(bytes, name);
      await Share.shareXFiles([XFile(file.path)], subject: 'Sayfa raporu (PDF)');
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Sayfa - PDF kaydet/paylaş');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File?> _buildDocxFile(List<MaintenanceRecord> records, {bool forView = true}) async {
    final msg = await _reportService.checkSettingsForReport();
    if (msg != null) return null;
    final headerInfo = await _settings.load();
    final bytes = await _reportService.buildDocx(records: records, headerInfo: headerInfo);
    final name = 'sayfa_${widget.page.id}_${DateFormat('yyyyMMdd_Hm').format(DateTime.now())}.docx';
    if (forView) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);
      return file;
    }
    return await _storage.saveReportToDocuments(bytes, name);
  }

  Future<void> _viewDocx(List<MaintenanceRecord> records) async {
    final messenger = ScaffoldMessenger.of(context);
    final file = await _buildDocxFile(records, forView: true);
    if (file == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Rapor için Ayarlar\'dan Kurum Adı girin.')));
      return;
    }
    final result = await OpenFilex.open(file.path);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      messenger.showSnackBar(SnackBar(content: Text('Açılamadı: ${result.message}')));
    }
  }

  Future<void> _saveOrShareDocx(List<MaintenanceRecord> records) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await _buildDocxFile(records, forView: false);
      if (file == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Rapor için Ayarlar\'dan Kurum Adı girin.')));
        return;
      }
      await Share.shareXFiles([XFile(file.path)], subject: 'Sayfa raporu (DOCX)');
    } catch (e, stackTrace) {
      ErrorLogService.instance.logError(e, stackTrace, context: 'Sayfa - DOCX paylaş');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(StorageService.messageForStorageError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReportMenu(List<MaintenanceRecord> records) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF ile görüntüle'),
                subtitle: const Text('Önizleme ve istersen kaydet / paylaş'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPdfPreview(records);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('PDF olarak kaydet / paylaş'),
                subtitle: const Text('Dosyaya kaydet veya uygulama ile paylaş'),
                onTap: () {
                  Navigator.pop(ctx);
                  _saveOrSharePdf(records);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('DOCX ile görüntüle'),
                subtitle: const Text('Word veya uyumlu uygulamada aç'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewDocx(records);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('DOCX olarak kaydet / paylaş'),
                subtitle: const Text('Paylaşım menüsü ile kaydet veya gönder'),
                onTap: () {
                  Navigator.pop(ctx);
                  _saveOrShareDocx(records);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.page.title?.isNotEmpty == true
        ? widget.page.title!
        : 'Sayfa #${widget.page.id ?? ''}';
    final dateStr = DateFormat('dd.MM.yyyy').format(widget.page.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(180),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_column_outlined),
            onPressed: _openViewEdit,
            tooltip: 'Görünümü düzenle',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final list = await _loadRecords();
              if (list.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Bu sayfada kayıt yok.')),
                );
                return;
              }
              _showReportMenu(list);
            },
            tooltip: 'Rapor al (PDF / DOCX)',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _openForm(),
            tooltip: 'Yeni satır ekle',
          ),
        ],
      ),
      body: FutureBuilder<List<MaintenanceRecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    const Text('Kayıtlar yüklenemedi. Lütfen tekrar deneyin.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Bu sayfada henüz kayıt yok.\nYeni satır eklemek için + veya alttaki butonu kullanın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni satır ekle'),
                  ),
                ],
              ),
            );
          }
          final ids = _columnIds ?? kDefaultColumnIds;
          final columns = resolveColumns(ids);
          return RefreshIndicator(
            onRefresh: () async {
              await _loadColumnIds();
              setState(() {});
            },
            child: RecordTableSheet(
              key: ValueKey<String>(ids.join(',')),
              records: list,
              onTapRow: _openForm,
              onDeleteRow: _onDeleteRecord,
              columns: columns,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: 'Yeni satır ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
