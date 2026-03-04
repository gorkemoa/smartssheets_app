import 'user_model.dart';

class MeResponseModel {
  final UserModel? user;

  const MeResponseModel({this.user});

  factory MeResponseModel.fromJson(Map<String, dynamic> json) {
    return MeResponseModel(
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
    };
  }
}
