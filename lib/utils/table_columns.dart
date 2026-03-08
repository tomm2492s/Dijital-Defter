import 'package:intl/intl.dart';
import '../models/maintenance_record.dart';

/// Tablo sütun tanımı: id, başlık, hücre genişlik ağırlığı (flex).
class TableColumnDef {
  const TableColumnDef({
    required this.id,
    required this.label,
    this.flex = 2,
  });

  final String id;
  final String label;
  final int flex;

  /// Kayıttan bu sütunun metin değerini döndürür. [rowIndex] sadece "sira" için kullanılır.
  String getValue(MaintenanceRecord record, int rowIndex) {
    switch (id) {
      case 'sira':
        return '${rowIndex + 1}';
      case 'inventory_no':
        return record.inventoryNo ?? '';
      case 'elevator_no':
        return record.elevatorNo;
      case 'material_name':
        return record.materialName;
      case 'unit_location':
        return record.unitLocation;
      case 'maintenance_date':
        return DateFormat('dd.MM.yyyy').format(record.maintenanceDate);
      case 'action_done':
        return record.actionDone;
      case 'technician':
        return record.technician;
      case 'status':
        return record.status ? 'Yapıldı' : 'Yapılmadı';
      default:
        return '';
    }
  }

  bool get isStatus => id == 'status';
}

/// Tüm kullanılabilir sütunlar (görünüm düzeninde seçilebilir).
const List<TableColumnDef> kAllTableColumns = [
  TableColumnDef(id: 'sira', label: 'Sıra', flex: 1),
  TableColumnDef(id: 'inventory_no', label: 'Demirbaş No', flex: 2),
  TableColumnDef(id: 'elevator_no', label: 'Asansör No', flex: 2),
  TableColumnDef(id: 'material_name', label: 'Malzeme Adı', flex: 2),
  TableColumnDef(id: 'unit_location', label: 'Bulunduğu Birim', flex: 2),
  TableColumnDef(id: 'maintenance_date', label: 'Tarih', flex: 2),
  TableColumnDef(id: 'action_done', label: 'Yapılan İşlem', flex: 2),
  TableColumnDef(id: 'technician', label: 'Bakım Yapan', flex: 2),
  TableColumnDef(id: 'status', label: 'Durum', flex: 1),
];

/// Varsayılan görünen sütun id'leri (sıralı).
const List<String> kDefaultColumnIds = [
  'sira',
  'elevator_no',
  'material_name',
  'maintenance_date',
  'status',
];

TableColumnDef? getColumnDef(String id) {
  try {
    return kAllTableColumns.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

/// [columnIds] sırasına göre geçerli sütun tanımlarını döndürür; bilinmeyen id'ler atlanır.
List<TableColumnDef> resolveColumns(List<String> columnIds) {
  final out = <TableColumnDef>[];
  for (final id in columnIds) {
    final def = getColumnDef(id);
    if (def != null) out.add(def);
  }
  if (out.isEmpty) {
    return kDefaultColumnIds.map((id) => getColumnDef(id)!).toList();
  }
  return out;
}
