/// Model for POST /invitations/accept
/// No UI for this endpoint — backend models only.
class AcceptInvitationRequestModel {
  final String token;
  final String name;
  final String? phone;
  final String password;
  final String passwordConfirmation;

  AcceptInvitationRequestModel({
    required this.token,
    required this.name,
    this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'name': name,
        if (phone != null) 'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
