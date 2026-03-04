import 'appointment_status_model.dart';

class AppointmentStatusesResponseModel {
  final List<AppointmentStatusModel> statuses;

  AppointmentStatusesResponseModel({required this.statuses});

  factory AppointmentStatusesResponseModel.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return AppointmentStatusesResponseModel(
      statuses: data
          .map((e) =>
              AppointmentStatusModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
