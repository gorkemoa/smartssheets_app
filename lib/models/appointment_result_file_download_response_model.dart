class AppointmentResultFileDownloadResponseModel {
  final String url;

  const AppointmentResultFileDownloadResponseModel({required this.url});

  factory AppointmentResultFileDownloadResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppointmentResultFileDownloadResponseModel(
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'url': url};
}
