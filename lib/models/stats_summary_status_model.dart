class StatsSummaryStatusModel {
  final int? statusId;
  final String? name;
  final int? count;

  const StatsSummaryStatusModel({
    this.statusId,
    this.name,
    this.count,
  });

  factory StatsSummaryStatusModel.fromJson(Map<String, dynamic> json) {
    return StatsSummaryStatusModel(
      statusId: json['status_id'] as int?,
      name: json['name'] as String?,
      count: json['count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status_id': statusId,
        'name': name,
        'count': count,
      };
}
