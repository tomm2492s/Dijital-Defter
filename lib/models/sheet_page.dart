/// Defter sayfası – içinde birden fazla bakım kaydı (satır) tutar.
class SheetPage {
  final int? id;
  final String? title;
  final DateTime createdAt;
  final int sortOrder;

  const SheetPage({
    this.id,
    this.title,
    required this.createdAt,
    this.sortOrder = 0,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  static SheetPage fromMap(Map<String, Object?> map) {
    return SheetPage(
      id: map['id'] as int?,
      title: map['title'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  SheetPage copyWith({int? id, String? title, DateTime? createdAt, int? sortOrder}) {
    return SheetPage(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
