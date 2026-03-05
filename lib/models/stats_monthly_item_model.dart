class StatsMonthlyItemModel {
  final String? month;
  final int? count;

  const StatsMonthlyItemModel({
    this.month,
    this.count,
  });

  factory StatsMonthlyItemModel.fromJson(Map<String, dynamic> json) {
    return StatsMonthlyItemModel(
      month: json['month'] as String?,
      count: json['count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'count': count,
      };
}
