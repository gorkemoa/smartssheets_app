import 'billing_plan_model.dart';

class BillingPlansResponseModel {
  final List<BillingPlanModel>? data;

  const BillingPlansResponseModel({this.data});

  factory BillingPlansResponseModel.fromJson(Map<String, dynamic> json) {
    return BillingPlansResponseModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BillingPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.map((e) => e.toJson()).toList(),
      };
}
