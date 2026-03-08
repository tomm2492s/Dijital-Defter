import 'package:flutter/material.dart';
import '../models/maintenance_record.dart';
import '../utils/table_columns.dart';

/// Tek bir "defter sayfası" alanı: başlık satırı + satır satır kayıtlar; satıra tıklanınca düzenlenir.
/// [columns] ile hangi sütunların görüneceği ve sırası belirlenir; verilmezse varsayılan sütunlar kullanılır.
/// [onDeleteRow] verilirse sola kaydırarak veya uzun basarak silme + onay dialog'u sunulur.
class RecordTableSheet extends StatelessWidget {
  const RecordTableSheet({
    super.key,
    required this.records,
    required this.onTapRow,
    this.onDeleteRow,
    this.columns,
  });

  final List<MaintenanceRecord> records;
  final ValueChanged<MaintenanceRecord> onTapRow;
  final ValueChanged<MaintenanceRecord>? onDeleteRow;
  /// Görünecek sütunlar (sıralı). Null ise [kDefaultColumnIds] ile çözülür.
  final List<TableColumnDef>? columns;

  List<TableColumnDef> get _cols =>
      columns ?? resolveColumns(kDefaultColumnIds);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cols = _cols;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  for (final c in cols) _headerCell(context, c.label, flex: c.flex),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: records.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = records[i];
                  final isDark = theme.brightness == Brightness.dark;
                  final rowColor = isDark
                      ? (r.status
                          ? Colors.green.withAlpha(38)
                          : Colors.red.withAlpha(38))
                      : (r.status
                          ? Colors.green.shade50
                          : Colors.red.shade50);
                  final row = Material(
                    color: rowColor,
                    child: InkWell(
                      onTap: () => onTapRow(r),
                      onLongPress: onDeleteRow == null
                          ? null
                          : () => _showRowActions(context, r, theme),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            for (final c in cols)
                              _cell(
                                context,
                                c.getValue(r, i),
                                flex: c.flex,
                                done: c.isStatus && r.status,
                              ),
                            Icon(Icons.edit_outlined,
                                size: 20,
                                color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                  if (onDeleteRow != null && r.id != null) {
                    return Dismissible(
                      key: ValueKey<int>(r.id!),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_forever,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) => _confirmDelete(context, r),
                      onDismissed: (_) => onDeleteRow!(r),
                      child: row,
                    );
                  }
                  return row;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(BuildContext context, String text, {int flex = 1}) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: theme.colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _cell(BuildContext context, String text, {int flex = 1, bool done = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: done
              ? (isDark ? Colors.green.shade200 : Colors.green.shade800)
              : null,
          fontWeight: done ? FontWeight.w500 : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, MaintenanceRecord record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kaydı sil'),
        content: const Text(
          'Bu kaydı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _showRowActions(BuildContext context, MaintenanceRecord record, ThemeData theme) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(ctx);
                onTapRow(record);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text('Sil', style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await _confirmDelete(context, record);
                if (ok && context.mounted) onDeleteRow!(record);
              },
            ),
          ],
        ),
      ),
    );
  }
}
