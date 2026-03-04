class CreateBrandRequestModel {
  final String name;
  final String? timezone;

  const CreateBrandRequestModel({
    required this.name,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (timezone != null) 'timezone': timezone,
    };
  }
}
