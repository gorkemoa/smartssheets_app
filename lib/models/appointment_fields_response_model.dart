import 'appointment_field_model.dart';

class AppointmentFieldsResponseModel {
  final List<AppointmentFieldModel> fields;

  AppointmentFieldsResponseModel({required this.fields});

  factory AppointmentFieldsResponseModel.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return AppointmentFieldsResponseModel(
      fields: data
          .map((e) =>
              AppointmentFieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
