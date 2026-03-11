class UpdateProfileRequestModel {
  final String name;
  final String email;
  final String? phone;

  const UpdateProfileRequestModel({
    required this.name,
    required this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
    };
  }
}
