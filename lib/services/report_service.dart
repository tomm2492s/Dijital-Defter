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
    bool landscape = true,
  }) async {
    final (fontRegular, fontBold) = await _loadPdfFonts();
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd.MM.yyyy');
    final pageFormat = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell('Sıra', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Demirbaş No', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Asansör No', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Malzeme Adı', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Bulunduğu Birim', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Bakım Tarihi', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Yapılan İşlem', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Bakım Yapan', bold: true, fontRegular: fontRegular, fontBold: fontBold),
          _cell('Durum', bold: true, fontRegular: fontRegular, fontBold: fontBold),
        ],
      ),
      ...records.asMap().entries.map((e) {
        final r = e.value;
        final index = e.key + 1;
        return pw.TableRow(
          children: [
            _cell('$index', fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.inventoryNo ?? '-', fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.elevatorNo, fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.materialName, fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.unitLocation, fontRegular: fontRegular, fontBold: fontBold),
            _cell(dateFormat.format(r.maintenanceDate), fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.actionDone, fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.technician, fontRegular: fontRegular, fontBold: fontBold),
            _cell(r.status ? 'Yapıldı' : 'Yapılmadı', fontRegular: fontRegular, fontBold: fontBold),
          ],
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
              0: const pw.FlexColumnWidth(0.8),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.2),
              6: const pw.FlexColumnWidth(2.5),
              7: const pw.FlexColumnWidth(1.2),
              8: const pw.FlexColumnWidth(0.6),
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
  }) async {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final reportTitle = (headerInfo['report_title'] ?? '').trim().isEmpty
        ? SettingsService.defaultReportTitle
        : (headerInfo['report_title'] ?? SettingsService.defaultReportTitle).trim();

    final headerRow = [
      'Sıra',
      'Demirbaş No',
      'Asansör No',
      'Malzeme Adı',
      'Bulunduğu Birim',
      'Bakım Tarihi',
      'Yapılan İşlem',
      'Bakım Yapan',
      'Durum',
    ];
    final dataRows = records.asMap().entries.map((e) {
      final r = e.value;
      final index = e.key + 1;
      return [
        '$index',
        r.inventoryNo ?? '-',
        r.elevatorNo,
        r.materialName,
        r.unitLocation,
        dateFormat.format(r.maintenanceDate),
        r.actionDone,
        r.technician,
        r.status ? 'Yapıldı' : 'Yapılmadı',
      ];
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
