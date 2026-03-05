import 'appointment_model.dart';

class AppointmentDetailResponseModel {
  final AppointmentModel appointment;

  const AppointmentDetailResponseModel({required this.appointment});

  factory AppointmentDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return AppointmentDetailResponseModel(
      appointment: AppointmentModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}
