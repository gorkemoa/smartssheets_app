import 'brand_model.dart';
import 'membership_permissions_model.dart';
import 'user_model.dart';

class MembershipModel {
  final int? id;
  final int? brandId;
  final int? userId;
  final String? role;
  final MembershipPermissionsModel? permissionsJson;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final BrandModel? brand;
  final UserModel? user;

  const MembershipModel({
    this.id,
    this.brandId,
    this.userId,
    this.role,
    this.permissionsJson,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.user,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id'] as int?,
      brandId: json['brand_id'] as int?,
      userId: json['user_id'] as int?,
      role: json['role'] as String?,
      permissionsJson: json['permissions_json'] != null
          ? MembershipPermissionsModel.fromJson(
              json['permissions_json'] as Map<String, dynamic>,
            )
          : null,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      brand: json['brand'] != null
          ? BrandModel.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_id': brandId,
      'user_id': userId,
      'role': role,
      'permissions_json': permissionsJson?.toJson(),
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'brand': brand?.toJson(),
      'user': user?.toJson(),
    };
  }
}
