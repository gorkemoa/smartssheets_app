class UpdateBrandRequestModel {
  final String? name;
  final String? timezone;

  const UpdateBrandRequestModel({
    this.name,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (timezone != null) 'timezone': timezone,
    };
  }
}
