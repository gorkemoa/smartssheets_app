class AppointmentStatusSummaryModel {
  final int? id;
  final String? name;
  final String? statusType;
  final String? color;

  const AppointmentStatusSummaryModel({
    this.id,
    this.name,
    this.statusType,
    this.color,
  });

  factory AppointmentStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return AppointmentStatusSummaryModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      statusType: json['status_type'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (statusType != null) 'status_type': statusType,
        if (color != null) 'color': color,
      };
}
