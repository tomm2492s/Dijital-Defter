import 'package:flutter/material.dart';
import '../models/maintenance_record.dart';
import 'package:intl/intl.dart';

/// Liste öğesi: durum göstergesi (Yeşil/Kırmızı veya ✅/❌) ile bakım kaydı.
class MaintenanceRecordTile extends StatelessWidget {
  const MaintenanceRecordTile({
    super.key,
    required this.record,
    required this.onTap,
  });

  final MaintenanceRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(record.maintenanceDate);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: record.status ? Colors.green : Colors.red,
          child: Icon(
            record.status ? Icons.check : Icons.close,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          '${record.elevatorNo} – ${record.materialName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$dateStr · ${record.technician}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
