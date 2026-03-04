class CreateAppointmentStatusRequestModel {
  final String name;
  final String color;
  final int? sortOrder;
  final bool? isDefault;
  final bool? isActive;
  final String? statusType;

  CreateAppointmentStatusRequestModel({
    required this.name,
    required this.color,
    this.sortOrder,
    this.isDefault,
    this.isActive,
    this.statusType,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (isDefault != null) 'is_default': isDefault,
        if (isActive != null) 'is_active': isActive,
        if (statusType != null) 'status_type': statusType,
      };
}
