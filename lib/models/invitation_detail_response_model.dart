import 'invitation_model.dart';

class InvitationDetailResponseModel {
  final InvitationModel invitation;

  InvitationDetailResponseModel({required this.invitation});

  factory InvitationDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return InvitationDetailResponseModel(
      invitation: InvitationModel.fromJson(data),
    );
  }
}
