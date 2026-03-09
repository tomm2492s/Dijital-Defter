import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_record.dart';

class ReminderItem {
  final MaintenanceRecord record;
  final DateTime nextDate;
  final bool overdue;

  const ReminderItem({
    required this.record,
    required this.nextDate,
    required this.overdue,
  });
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminders,
    required this.loading,
    required this.onTapItem,
  });

  final List<ReminderItem> reminders;
  final bool loading;
  final Future<void> Function(ReminderItem) onTapItem;

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty && !loading) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final items = reminders.take(5).toList();
    final overdueCount = reminders.where((r) => r.overdue).length;
    final upcomingCount = reminders.length - overdueCount;
    return Card(
      color: theme.colorScheme.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: theme.colorScheme.onSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Yaklaşan / geciken bakımlar',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (overdueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$overdueCount gecikmiş',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                    ),
                  )
                else if (upcomingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$upcomingCount yaklaşan',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                if (loading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty && loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Bakım bilgileri yükleniyor...',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ...items.map((item) {
              final r = item.record;
              final statusText = item.overdue ? 'Gecikmiş' : 'Yaklaşıyor';
              final statusColor = item.overdue ? Colors.red : theme.colorScheme.primary;
              final nextStr = DateFormat('dd.MM.yyyy').format(item.nextDate);
              final lastStr = DateFormat('dd.MM.yyyy').format(r.maintenanceDate);
              return ListTile(
                contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
                dense: true,
                title: Text(
                  '${r.elevatorNo} - ${r.materialName}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Son bakım: $lastStr · Sonraki: $nextStr',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                onTap: () => onTapItem(item),
              );
            }),
            if (reminders.length > items.length)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Toplam ${reminders.length} kayıt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

