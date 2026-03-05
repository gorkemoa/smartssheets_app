import 'appointment_model.dart';

class CalendarResponseModel {
  final List<AppointmentModel> appointments;

  const CalendarResponseModel({required this.appointments});

  factory CalendarResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return CalendarResponseModel(
      appointments: list
          .map((a) => AppointmentModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
