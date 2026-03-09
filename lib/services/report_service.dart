import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:docx_creator/docx_creator.dart';
import '../models/maintenance_record.dart';
import 'database_service.dart';
import 'settings_service.dart';

/// PDF ve DOCX rapor üretimi – tarih aralığına göre veri, kurum bilgileri, tablo.
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  final _db = DatabaseService.instance;
  final _settings = SettingsService.instance;

  /// Ayarların dolu olup olmadığını kontrol eder (rapor için kurum bilgisi gerekli).
  Future<String?> checkSettingsForReport() async {
    final name = await _settings.getInstitutionName();
    if (name.isEmpty) {
      return 'Rapor oluşturmak için önce Ayarlar\'dan Kurum/İşletme Adı girin.';
    }
    return null;
  }

  /// Tarih aralığına göre kayıtları getirir.
  Future<List<MaintenanceRecord>> getRecordsForReport(DateTime start, DateTime end) async {
    return _db.getByDateRange(start, end);
  }

  /// Türkçe karakter destekli font yükler: önce assets, yoksa PdfGoogleFonts (Noto Sans).
  Future<(pw.Font, pw.Font)> _loadPdfFonts() async {
    try {
      final regularData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      return (
        pw.Font.ttf(regularData),
        pw.Font.ttf(boldData),
      );
    } catch (_) {
      final regular = await PdfGoogleFonts.notoSansRegular();
      final bold = await PdfGoogleFonts.notoSansBold();
      return (regular, bold);
    }
  }

  /// PDF oluşturur: "ENVANTER BAKIM DEĞERİ" başlığı, kurum bilgileri, tablo (portrait veya landscape).
  /// Türkçe karakterler için Noto Sans (assets veya Google Fonts) kullanılır.
  Future<Uint8List> buildPdf({
    required List<MaintenanceRecord> records,
    required Map<String, String> headerInfo,
    Map<String, String>? columnLabels,
    String? statusTrueLabel,
    String? statusFalseLabel,
    bool landscape = true,
  }) async {
    final (fontRegular, fontBold) = await _loadPdfFonts();
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd.MM.yyyy');
    final pageFormat = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    final labels = columnLabels ?? SettingsService.defaultColumnLabels;
    final statusTrue = statusTrueLabel ?? SettingsService.defaultStatusTrueLabel;
    final statusFalse = statusFalseLabel ?? SettingsService.defaultStatusFalseLabel;

    final hiddenIds = await _settings.getHiddenColumnIds();
    final allColumnIds = <String>[
      'sira',
      'inventory_no',
      'elevator_no',
      'material_name',
      'unit_location',
      'maintenance_date',
      'action_done',
      'technician',
      'status',
    ];
    final visibleColumnIds = allColumnIds.where((id) => !hiddenIds.contains(id)).toList();

    String valueForColumn(String id, MaintenanceRecord r, int index) {
      switch (id) {
        case 'sira':
          return '$index';
        case 'inventory_no':
          return r.inventoryNo ?? '-';
        case 'elevator_no':
          return r.elevatorNo;
        case 'material_name':
          return r.materialName;
        case 'unit_location':
          return r.unitLocation;
        case 'maintenance_date':
          return dateFormat.format(r.maintenanceDate);
        case 'action_done':
          return r.actionDone;
        case 'technician':
          return r.technician;
        case 'status':
          return r.status ? statusTrue : statusFalse;
        default:
          return '';
      }
    }

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: visibleColumnIds
            .map(
              (id) => _cell(
                labels[id] ?? SettingsService.defaultColumnLabels[id] ?? id,
                bold: true,
                fontRegular: fontRegular,
                fontBold: fontBold,
              ),
            )
            .toList(),
      ),
      ...records.asMap().entries.map((e) {
        final r = e.value;
        final index = e.key + 1;
        return pw.TableRow(
          children: visibleColumnIds
              .map(
                (id) => _cell(
                  valueForColumn(id, r, index),
                  fontRegular: fontRegular,
                  fontBold: fontBold,
                ),
              )
              .toList(),
        );
      }),
    ];

    final reportTitle = (headerInfo['report_title'] ?? '').trim().isEmpty
        ? SettingsService.defaultReportTitle
        : (headerInfo['report_title'] ?? SettingsService.defaultReportTitle).trim();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                reportTitle,
                style: pw.TextStyle(fontSize: 16, font: fontBold),
              ),
              if ((headerInfo['institution_name'] ?? '').isNotEmpty)
                pw.Text('Kurum: ${headerInfo['institution_name']}', style: pw.TextStyle(fontSize: 9, font: fontRegular)),
              if ((headerInfo['department'] ?? '').isNotEmpty)
                pw.Text('Birim: ${headerInfo['department']}', style: pw.TextStyle(fontSize: 9, font: fontRegular)),
              if ((headerInfo['responsible_person'] ?? '').isNotEmpty)
                pw.Text('Sorumlu: ${headerInfo['responsible_person']}', style: pw.TextStyle(fontSize: 9, font: fontRegular)),
              if ((headerInfo['period'] ?? '').isNotEmpty)
                pw.Text('Dönem: ${headerInfo['period']}', style: pw.TextStyle(fontSize: 9, font: fontRegular)),
            ],
          ),
        ),
        build: (context) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: {
              for (var i = 0; i < visibleColumnIds.length; i++)
                i: switch (visibleColumnIds[i]) {
                  'sira' => const pw.FlexColumnWidth(0.8),
                  'inventory_no' => const pw.FlexColumnWidth(1.2),
                  'elevator_no' => const pw.FlexColumnWidth(1.2),
                  'material_name' => const pw.FlexColumnWidth(1.5),
                  'unit_location' => const pw.FlexColumnWidth(1.5),
                  'maintenance_date' => const pw.FlexColumnWidth(1.2),
                  'action_done' => const pw.FlexColumnWidth(2.5),
                  'technician' => const pw.FlexColumnWidth(1.2),
                  'status' => const pw.FlexColumnWidth(0.6),
                  _ => const pw.FlexColumnWidth(1),
                }
            },
            children: tableRows,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Çok satırlı metin: \n ile paragraf kırılır, uzun satırlar hücre genişliğinde sarılır.
  pw.Widget _cell(String text, {bool bold = false, required pw.Font fontRegular, required pw.Font fontBold}) {
    const double fontSize = 7;
    final style = pw.TextStyle(
      fontSize: fontSize,
      font: bold ? fontBold : fontRegular,
    );
    final paragraphs = text.split('\n');
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: paragraphs.map((line) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 1),
            child: pw.Text(
              line.isEmpty ? ' ' : line,
              style: style,
              maxLines: 20,
              overflow: pw.TextOverflow.clip,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// DOCX oluşturur: düzenlenebilir tablo, ayarlardaki başlık ve kurum bilgileri.
  Future<Uint8List> buildDocx({
    required List<MaintenanceRecord> records,
    required Map<String, String> headerInfo,
    Map<String, String>? columnLabels,
    String? statusTrueLabel,
    String? statusFalseLabel,
  }) async {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final reportTitle = (headerInfo['report_title'] ?? '').trim().isEmpty
        ? SettingsService.defaultReportTitle
        : (headerInfo['report_title'] ?? SettingsService.defaultReportTitle).trim();

    final labels = columnLabels ?? SettingsService.defaultColumnLabels;
    final statusTrue = statusTrueLabel ?? SettingsService.defaultStatusTrueLabel;
    final statusFalse = statusFalseLabel ?? SettingsService.defaultStatusFalseLabel;

    final hiddenIds = await _settings.getHiddenColumnIds();
    final allColumnIds = <String>[
      'sira',
      'inventory_no',
      'elevator_no',
      'material_name',
      'unit_location',
      'maintenance_date',
      'action_done',
      'technician',
      'status',
    ];
    final visibleColumnIds = allColumnIds.where((id) => !hiddenIds.contains(id)).toList();

    final headerRow = visibleColumnIds
        .map((id) => labels[id] ?? SettingsService.defaultColumnLabels[id] ?? id)
        .toList();
    final dataRows = records.asMap().entries.map((e) {
      final r = e.value;
      final index = e.key + 1;
      return visibleColumnIds.map((id) {
        switch (id) {
          case 'sira':
            return '$index';
          case 'inventory_no':
            return r.inventoryNo ?? '-';
          case 'elevator_no':
            return r.elevatorNo;
          case 'material_name':
            return r.materialName;
          case 'unit_location':
            return r.unitLocation;
          case 'maintenance_date':
            return dateFormat.format(r.maintenanceDate);
          case 'action_done':
            return r.actionDone;
          case 'technician':
            return r.technician;
          case 'status':
            return r.status ? statusTrue : statusFalse;
          default:
            return '';
        }
      }).toList();
    }).toList();

    final doc = docx()
        .h1(reportTitle)
        .p('Kurum: ${headerInfo['institution_name'] ?? '-'}')
        .p('Birim: ${headerInfo['department'] ?? '-'}')
        .p('Sorumlu: ${headerInfo['responsible_person'] ?? '-'}')
        .p('Dönem: ${headerInfo['period'] ?? '-'}')
        .table([headerRow, ...dataRows], hasHeader: true)
        .build();

    return DocxExporter().exportToBytes(doc);
  }
}
