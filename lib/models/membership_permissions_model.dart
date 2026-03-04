class MembershipPermissionsModel {
  final bool? createAppointment;
  final bool? uploadResult;
  final bool? changeStatus;
  final bool? manageMembers;
  final bool? manageStatuses;
  final bool? manageAppointmentFields;

  const MembershipPermissionsModel({
    this.createAppointment,
    this.uploadResult,
    this.changeStatus,
    this.manageMembers,
    this.manageStatuses,
    this.manageAppointmentFields,
  });

  factory MembershipPermissionsModel.fromJson(Map<String, dynamic> json) {
    return MembershipPermissionsModel(
      createAppointment: json['create_appointment'] as bool?,
      uploadResult: json['upload_result'] as bool?,
      changeStatus: json['change_status'] as bool?,
      manageMembers: json['manage_members'] as bool?,
      manageStatuses: json['manage_statuses'] as bool?,
      manageAppointmentFields: json['manage_appointment_fields'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'create_appointment': createAppointment,
      'upload_result': uploadResult,
      'change_status': changeStatus,
      'manage_members': manageMembers,
      'manage_statuses': manageStatuses,
      'manage_appointment_fields': manageAppointmentFields,
    };
  }
}
