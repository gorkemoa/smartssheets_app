class AppointmentStatusModel {
  final int? id;
  final int? brandId;
  final String? name;
  final String? color;
  final int? sortOrder;
  final bool? isDefault;
  final bool? isActive;
  final String? statusType;

  const AppointmentStatusModel({
    this.id,
    this.brandId,
    this.name,
    this.color,
    this.sortOrder,
    this.isDefault,
    this.isActive,
    this.statusType,
  });

  factory AppointmentStatusModel.fromJson(Map<String, dynamic> json) {
    return AppointmentStatusModel(
      id: json['id'] as int?,
      brandId: json['brand_id'] as int?,
      name: json['name'] as String?,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int?,
      isDefault: json['is_default'] as bool?,
      isActive: json['is_active'] as bool?,
      statusType: json['status_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (brandId != null) 'brand_id': brandId,
        if (name != null) 'name': name,
        if (color != null) 'color': color,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (isDefault != null) 'is_default': isDefault,
        if (isActive != null) 'is_active': isActive,
        if (statusType != null) 'status_type': statusType,
      };
}
