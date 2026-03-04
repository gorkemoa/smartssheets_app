import 'membership_model.dart';

class MembersResponseModel {
  final List<MembershipModel>? data;

  const MembersResponseModel({this.data});

  factory MembersResponseModel.fromJson(Map<String, dynamic> json) {
    return MembersResponseModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MembershipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}
