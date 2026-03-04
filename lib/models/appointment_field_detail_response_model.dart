import 'appointment_field_model.dart';

class AppointmentFieldDetailResponseModel {
  final AppointmentFieldModel field;

  AppointmentFieldDetailResponseModel({required this.field});

  factory AppointmentFieldDetailResponseModel.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AppointmentFieldDetailResponseModel(
      field: AppointmentFieldModel.fromJson(data),
    );
  }
}
