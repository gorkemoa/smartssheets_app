class DeleteAccountRequestModel {
  final String currentPassword;

  const DeleteAccountRequestModel({required this.currentPassword});

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
    };
  }
}
