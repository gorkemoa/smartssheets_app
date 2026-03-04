import 'membership_permissions_model.dart';

class CreateInvitationRequestModel {
  final String email;
  final String role;
  final MembershipPermissionsModel? permissions;

  CreateInvitationRequestModel({
    required this.email,
    required this.role,
    this.permissions,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role,
        if (permissions != null) 'permissions': permissions!.toJson(),
      };
}
