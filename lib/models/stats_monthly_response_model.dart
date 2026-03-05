import 'stats_monthly_item_model.dart';

class StatsMonthlyResponseModel {
  final List<StatsMonthlyItemModel>? data;

  const StatsMonthlyResponseModel({this.data});

  factory StatsMonthlyResponseModel.fromJson(Map<String, dynamic> json) {
    return StatsMonthlyResponseModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) =>
              StatsMonthlyItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.map((e) => e.toJson()).toList(),
      };
}
