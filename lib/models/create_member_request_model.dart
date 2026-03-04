class CreateMemberRequestModel {
  final String email;
  final String name;
  final String password;
  final String role;
  final String? phone;
  final Map<String, bool>? permissionsJson;

  const CreateMemberRequestModel({
    required this.email,
    required this.name,
    required this.password,
    required this.role,
    this.phone,
    this.permissionsJson,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'role': role,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (permissionsJson != null) 'permissions_json': permissionsJson,
    };
  }
}
