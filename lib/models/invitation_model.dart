import 'membership_permissions_model.dart';

class InvitationModel {
  final int? id;
  final int? brandId;
  final String? email;
  final String? role;
  final MembershipPermissionsModel? permissions;
  final String? expiresAt;
  final String? acceptedAt;
  final String? createdAt;

  InvitationModel({
    this.id,
    this.brandId,
    this.email,
    this.role,
    this.permissions,
    this.expiresAt,
    this.acceptedAt,
    this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as int?,
      brandId: json['brand_id'] as int?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      permissions: json['permissions'] != null
          ? MembershipPermissionsModel.fromJson(
              json['permissions'] as Map<String, dynamic>)
          : null,
      expiresAt: json['expires_at'] as String?,
      acceptedAt: json['accepted_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (brandId != null) 'brand_id': brandId,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (permissions != null) 'permissions': permissions!.toJson(),
        if (expiresAt != null) 'expires_at': expiresAt,
        if (acceptedAt != null) 'accepted_at': acceptedAt,
        if (createdAt != null) 'created_at': createdAt,
      };
}
