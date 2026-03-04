class AppointmentFieldOptionModel {
  final String? value;
  final String? label;

  const AppointmentFieldOptionModel({this.value, this.label});

  factory AppointmentFieldOptionModel.fromJson(Map<String, dynamic> json) {
    return AppointmentFieldOptionModel(
      value: json['value'] as String?,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (value != null) 'value': value,
        if (label != null) 'label': label,
      };
}
