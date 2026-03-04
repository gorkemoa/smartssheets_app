import 'invitation_model.dart';

class InvitationsResponseModel {
  final List<InvitationModel> invitations;

  InvitationsResponseModel({required this.invitations});

  factory InvitationsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return InvitationsResponseModel(
      invitations: data
          .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
