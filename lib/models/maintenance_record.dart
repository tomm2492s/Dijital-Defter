/// Bakım kaydı modeli.
/// Alanlar: id, inventory_no, elevator_no, material_name, unit_location,
/// maintenance_date, action_done, technician, status
class MaintenanceRecord {
  final int? id;
  final int? pageId; // Hangi sayfaya ait (defter sayfası)
  final String? inventoryNo;
  final String elevatorNo;
  final String materialName;
  final String unitLocation;
  final DateTime maintenanceDate;
  final String actionDone;
  final String technician;
  final bool status; // true = Yapıldı, false = Yapılmadı

  const MaintenanceRecord({
    this.id,
    this.pageId,
    this.inventoryNo,
    required this.elevatorNo,
    required this.materialName,
    required this.unitLocation,
    required this.maintenanceDate,
    required this.actionDone,
    required this.technician,
    required this.status,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'page_id': pageId,
      'inventory_no': inventoryNo,
      'elevator_no': elevatorNo,
      'material_name': materialName,
      'unit_location': unitLocation,
      'maintenance_date': maintenanceDate.toIso8601String(),
      'action_done': actionDone,
      'technician': technician,
      'status': status ? 1 : 0,
    };
  }

  static MaintenanceRecord fromMap(Map<String, Object?> map) {
    return MaintenanceRecord(
      id: map['id'] as int?,
      pageId: map['page_id'] as int?,
      inventoryNo: map['inventory_no'] as String?,
      elevatorNo: map['elevator_no'] as String,
      materialName: map['material_name'] as String,
      unitLocation: map['unit_location'] as String,
      maintenanceDate: DateTime.parse(map['maintenance_date'] as String),
      actionDone: map['action_done'] as String,
      technician: map['technician'] as String,
      status: (map['status'] as int?) == 1,
    );
  }

  MaintenanceRecord copyWith({
    int? id,
    int? pageId,
    String? inventoryNo,
    String? elevatorNo,
    String? materialName,
    String? unitLocation,
    DateTime? maintenanceDate,
    String? actionDone,
    String? technician,
    bool? status,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      inventoryNo: inventoryNo ?? this.inventoryNo,
      elevatorNo: elevatorNo ?? this.elevatorNo,
      materialName: materialName ?? this.materialName,
      unitLocation: unitLocation ?? this.unitLocation,
      maintenanceDate: maintenanceDate ?? this.maintenanceDate,
      actionDone: actionDone ?? this.actionDone,
      technician: technician ?? this.technician,
      status: status ?? this.status,
    );
  }
}
