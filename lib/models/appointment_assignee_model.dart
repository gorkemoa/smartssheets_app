class AppointmentAssigneeModel {
  final int? membershipId;
  final int? userId;
  final String? name;
  final String? email;

  const AppointmentAssigneeModel({
    this.membershipId,
    this.userId,
    this.name,
    this.email,
  });

  factory AppointmentAssigneeModel.fromJson(Map<String, dynamic> json) {
    return AppointmentAssigneeModel(
      membershipId: json['membership_id'] as int?,
      userId: json['user_id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (membershipId != null) 'membership_id': membershipId,
        if (userId != null) 'user_id': userId,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      };
}
