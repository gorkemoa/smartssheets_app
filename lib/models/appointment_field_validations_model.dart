class AppointmentFieldValidationsModel {
  final num? min;
  final num? max;

  const AppointmentFieldValidationsModel({this.min, this.max});

  factory AppointmentFieldValidationsModel.fromJson(
      Map<String, dynamic> json) {
    return AppointmentFieldValidationsModel(
      min: json['min'] as num?,
      max: json['max'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (min != null) 'min': min,
        if (max != null) 'max': max,
      };
}
