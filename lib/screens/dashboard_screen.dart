import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/sheet_page.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import 'dashboard_reminders_widgets.dart';
import 'page_detail_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

/// Ana ekran: sayfa listesi. Her sayfa bir “defter yaprağı”; içinde satır satır kayıtlar var.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onThemeReload});

  final VoidCallback? onThemeReload;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService.instance;
  final SettingsService _settings = SettingsService.instance;
  List<SheetPage> _pages = [];
  Map<int, int> _recordCounts = {};
  bool _loading = true;
  List<ReminderItem> _reminders = [];
  bool _loadingReminders = false;

  @override
  void initState() {
    super.initState();
    _loadPages();
    _loadReminders();
  }

  Future<void> _loadPages() async {
    final results = await Future.wait([
      _db.getAllPages(),
      _db.getRecordCountsByPageIds(),
    ]);
    if (mounted) {
      setState(() {
        _pages = results[0] as List<SheetPage>;
        _recordCounts = results[1] as Map<int, int>;
        _loading = false;
      });
    }
  }

  Future<void> _loadReminders() async {
    setState(() => _loadingReminders = true);
    try {
      final periodMonths = await _settings.getMaintenancePeriodMonths();
      final reminderDays = await _settings.getMaintenanceReminderDays();
      if (periodMonths <= 0) {
        if (mounted) {
          setState(() {
            _reminders = [];
            _loadingReminders = false;
          });
        }
        return;
      }
      final records = await _db.getAll();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final windowEnd = today.add(Duration(days: reminderDays));
      final items = <ReminderItem>[];
      for (final r in records) {
        if (r.pageId == null) continue;
        final d = r.maintenanceDate;
        final base = DateTime(d.year, d.month, d.day);
        final nextDate = DateTime(
          base.year,
          base.month + periodMonths,
          base.day,
        );
        final overdue = nextDate.isBefore(today);
        final inWindow = !overdue && !nextDate.isAfter(windowEnd);
        if (overdue || inWindow) {
          items.add(
            ReminderItem(record: r, nextDate: nextDate, overdue: overdue),
          );
        }
      }
      items.sort((a, b) => a.nextDate.compareTo(b.nextDate));
      if (!mounted) return;
      setState(() {
        _reminders = items;
        _loadingReminders = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _reminders = [];
          _loadingReminders = false;
        });
      }
    }
  }

  void _push(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        // ignore: unnecessary_underscores
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  void _openPage(SheetPage page) {
    Navigator.of(context)
        .push(
          PageRouteBuilder<void>(
            // ignore: unnecessary_underscores
            pageBuilder: (_, __, ___) => PageDetailScreen(page: page),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 220),
          ),
        )
        .then((_) {
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _loadPages();
            await _loadReminders();
          });
        });
  }

  void _createNewPage() async {
    final page = SheetPage(title: null, createdAt: DateTime.now());
    final id = await _db.insertPage(page);
    if (!mounted) return;
    final created = SheetPage(
      id: id,
      title: page.title,
      createdAt: page.createdAt,
      sortOrder: _pages.length,
    );
    _openPage(created);
  }

  Future<void> _renamePage(SheetPage page) async {
    final controller = TextEditingController(text: page.title ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sayfayı adlandır'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Sayfa adı',
            hintText: 'örn. İlk sayfa, Sayfa 2',
          ),
          autofocus: true,
          maxLength: 100,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result != true || !mounted) return;
    final title = controller.text.trim();
    await _db.updatePage(page.copyWith(title: title.isEmpty ? null : title));
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadPages();
    });
  }

  Future<void> _deletePage(SheetPage page) async {
    final count = (await _db.getRecordsByPageId(page.id!)).length;
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sayfayı sil'),
        content: Text(
          count > 0
              ? '"${page.title ?? 'Sayfa #${page.id}'}" sayfası ve içindeki $count kayıt silinecek. Emin misiniz?'
              : '"${page.title ?? 'Sayfa #${page.id}'}" sayfası silinecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _db.deletePage(page.id!);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sayfa silindi.')));
      _loadPages();
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    setState(() {
      final item = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, item);
    });
    await _db.updatePagesOrder(_pages);
  }

  void _showPageMenu(SheetPage page) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Adlandır'),
              onTap: () {
                Navigator.pop(ctx);
                _renamePage(page);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Sil',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deletePage(page);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openReminderRecord(ReminderItem item) async {
    final record = item.record;
    final pageId = record.pageId;
    if (pageId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu kaydın bağlı olduğu sayfa bulunamadı.'),
        ),
      );
      return;
    }
    SheetPage? page = _pages.firstWhere(
      (p) => p.id == pageId,
      orElse: () =>
          SheetPage(id: pageId, title: null, createdAt: record.maintenanceDate),
    );
    if (page.id == null) {
      page = await _db.getPageById(pageId);
    }
    if (!mounted) return;
    if (page == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('İlgili sayfa bulunamadı.')));
      return;
    }
    _openPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Dijital Defter'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _push(ReportScreen()),
            tooltip: 'Rapor Al',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                _push(SettingsScreen(onThemeReload: widget.onThemeReload)),
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_reminders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: ReminderCard(
                reminders: _reminders,
                loading: _loadingReminders,
                onTapItem: _openReminderRecord,
              ),
            ),
          Expanded(
            child: _loading && _pages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : (_pages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 56,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Henüz sayfa yok',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'İlk sayfayı oluşturmak için aşağıdaki butona veya + ikonuna basın.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 28),
                                FilledButton.icon(
                                  onPressed: _createNewPage,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('İlk sayfayı oluştur'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await _loadPages();
                            await _loadReminders();
                          },
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _pages.length,
                            onReorder: _onReorder,
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, i) {
                              final page = _pages[i];
                              return ReorderableDragStartListener(
                                index: i,
                                key: ValueKey<int>(page.id ?? 0),
                                child: _PageCard(
                                  page: page,
                                  onTap: () => _openPage(page),
                                  onMenuTap: () => _showPageMenu(page),
                                  recordCount: page.id != null
                                      ? (_recordCounts[page.id!] ?? 0)
                                      : 0,
                                ),
                              );
                            },
                          ),
                        )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPage,
        tooltip: 'Yeni sayfa',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({
    required this.page,
    required this.onTap,
    required this.onMenuTap,
    required this.recordCount,
  });

  final SheetPage page;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = page.title?.isNotEmpty == true
        ? page.title!
        : 'Sayfa #${page.id}';
    final dateStr = DateFormat('dd.MM.yyyy').format(page.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMenuTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.drag_handle_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateStr · $recordCount kayıt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onMenuTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
