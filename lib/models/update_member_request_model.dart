class UpdateMemberRequestModel {
  final String? role;
  final String? status;
  final Map<String, bool>? permissionsJson;

  const UpdateMemberRequestModel({
    this.role,
    this.status,
    this.permissionsJson,
  });

  Map<String, dynamic> toJson() {
    return {
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (permissionsJson != null) 'permissions_json': permissionsJson,
    };
  }
}
