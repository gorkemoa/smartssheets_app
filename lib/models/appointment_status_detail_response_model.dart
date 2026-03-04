import 'appointment_status_model.dart';

class AppointmentStatusDetailResponseModel {
  final AppointmentStatusModel status;

  AppointmentStatusDetailResponseModel({required this.status});

  factory AppointmentStatusDetailResponseModel.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AppointmentStatusDetailResponseModel(
      status: AppointmentStatusModel.fromJson(data),
    );
  }
}
