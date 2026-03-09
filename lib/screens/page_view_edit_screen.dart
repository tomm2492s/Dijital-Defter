import 'package:flutter/material.dart';
import '../utils/table_columns.dart';
import '../services/settings_service.dart';

/// Kaydedilince yeni sütun id listesini döndüren callback.
typedef PageViewOnSave = Future<void> Function(List<String> ids);

/// Sayfa tablo görünümü düzenleme: hangi sütunlar görünsün ve sırası.
/// [initialColumnIds] mevcut sıralı sütun id listesi; [onSave] kaydedilince yeni listeyi döndürür.
class PageViewEditScreen extends StatefulWidget {
  const PageViewEditScreen({
    super.key,
    required this.initialColumnIds,
    required this.onSave,
  });

  final List<String> initialColumnIds;
  final PageViewOnSave onSave;

  @override
  State<PageViewEditScreen> createState() => _PageViewEditScreenState();
}

class _PageViewEditScreenState extends State<PageViewEditScreen> {
  late List<String> _columnIds;
  Map<String, String>? _columnLabels;
  Set<String> _hiddenGlobalIds = <String>{};

  @override
  void initState() {
    super.initState();
    _columnIds = List.from(widget.initialColumnIds);
    _ensureAtLeastOne();
    _loadInitialSettings();
  }

  void _ensureAtLeastOne() {
    if (_columnIds.isEmpty) {
      _columnIds = List.from(kDefaultColumnIds);
    }
  }

  Future<void> _loadInitialSettings() async {
    final settings = SettingsService.instance;
    final labels = await settings.getColumnLabels();
    final hiddenGlobal = await settings.getHiddenColumnIds();
    if (!mounted) return;
    setState(() {
      _columnLabels = labels;
      _hiddenGlobalIds = hiddenGlobal.toSet();
      // Global olarak gizlenen sütunları bu sayfanın görünüm listesinden de çıkar.
      _columnIds.removeWhere(_hiddenGlobalIds.contains);
      _ensureAtLeastOne();
    });
  }

  List<String> get _availableToAddIds => kAllTableColumns
      .map((c) => c.id)
      // Zaten görünenleri çıkar
      .where((id) => !_columnIds.contains(id))
      // Global olarak gizlenenleri hiç gösterme
      .where((id) => !_hiddenGlobalIds.contains(id))
      .toList();

  String _labelFor(String id) {
    final def = getColumnDef(id);
    final base = def?.label ?? id;
    final labels = _columnLabels;
    if (labels == null) return base;
    final override = labels[id];
    if (override == null || override.trim().isEmpty) return base;
    return override.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablo görünümünü düzenle'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
          Text(
            'Görünen sütunlar (sırayı değiştirmek için sürükleyin)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _columnIds.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final id = _columnIds.removeAt(oldIndex);
                _columnIds.insert(newIndex, id);
              });
            },
            itemBuilder: (context, index) {
              final id = _columnIds[index];
              final label = _labelFor(id);
              return ListTile(
                key: ValueKey(id),
                leading: const Icon(Icons.drag_handle),
                title: Text(label),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      _columnIds.removeAt(index);
                      _ensureAtLeastOne();
                    });
                  },
                  tooltip: 'Sütunu kaldır',
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Sütun ekle',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableToAddIds.map((id) {
              final label = _labelFor(id);
              return InputChip(
                label: Text(label),
                onPressed: () {
                  setState(() => _columnIds.add(id));
                },
              );
            }).toList(),
          ),
          if (_availableToAddIds.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tüm sütunlar görünür.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final ids = List<String>.from(_columnIds);
                    await widget.onSave(ids);
                    if (!context.mounted) return;
                    Navigator.of(context).pop<List<String>>(ids);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
