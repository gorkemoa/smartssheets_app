import 'brand_model.dart';

class BrandDetailResponseModel {
  final BrandModel? data;

  const BrandDetailResponseModel({
    this.data,
  });

  factory BrandDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return BrandDetailResponseModel(
      data: json['data'] != null
          ? BrandModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}
