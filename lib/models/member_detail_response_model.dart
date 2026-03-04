import 'membership_model.dart';

class MemberDetailResponseModel {
  final MembershipModel? data;

  const MemberDetailResponseModel({this.data});

  factory MemberDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return MemberDetailResponseModel(
      data: json['data'] != null
          ? MembershipModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}
