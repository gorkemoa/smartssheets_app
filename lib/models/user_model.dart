import 'membership_model.dart';

class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<MembershipModel>? memberships;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.memberships,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      memberships: (json['memberships'] as List<dynamic>?)
          ?.map((e) => MembershipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'memberships': memberships?.map((e) => e.toJson()).toList(),
    };
  }
}
