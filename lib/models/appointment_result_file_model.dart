class AppointmentResultFileModel {
  final int? id;
  final int? brandId;
  final int? appointmentId;
  final String? originalName;
  final String? mime;
  final int? sizeBytes;
  final String? sha256;
  final String? createdAt;

  const AppointmentResultFileModel({
    this.id,
    this.brandId,
    this.appointmentId,
    this.originalName,
    this.mime,
    this.sizeBytes,
    this.sha256,
    this.createdAt,
  });

  factory AppointmentResultFileModel.fromJson(Map<String, dynamic> json) {
    return AppointmentResultFileModel(
      id: json['id'] as int?,
      brandId: json['brand_id'] as int?,
      appointmentId: json['appointment_id'] as int?,
      originalName: json['original_name'] as String?,
      mime: json['mime'] as String?,
      sizeBytes: json['size_bytes'] as int?,
      sha256: json['sha256'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (brandId != null) 'brand_id': brandId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (originalName != null) 'original_name': originalName,
      if (mime != null) 'mime': mime,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}
