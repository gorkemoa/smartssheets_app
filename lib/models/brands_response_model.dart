import 'brand_model.dart';

class BrandsResponseModel {
  final List<BrandModel>? data;

  const BrandsResponseModel({
    this.data,
  });

  factory BrandsResponseModel.fromJson(Map<String, dynamic> json) {
    return BrandsResponseModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}
