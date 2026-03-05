import 'appointment_result_file_model.dart';

class AppointmentResultFilesResponseModel {
  final List<AppointmentResultFileModel> files;

  const AppointmentResultFilesResponseModel({required this.files});

  factory AppointmentResultFilesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    final list = data is List
        ? data
            .map((e) => AppointmentResultFileModel.fromJson(
                  e as Map<String, dynamic>,
                ))
            .toList()
        : <AppointmentResultFileModel>[];
    return AppointmentResultFilesResponseModel(files: list);
  }
}
