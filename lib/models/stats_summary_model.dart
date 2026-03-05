import 'stats_summary_status_model.dart';

class StatsSummaryModel {
  final int? totalAppointments;
  final int? thisMonthCreated;
  final List<StatsSummaryStatusModel>? byStatus;
  final int? activeCount;
  final int? invalidCount;
  final int? upcoming7Days;

  const StatsSummaryModel({
    this.totalAppointments,
    this.thisMonthCreated,
    this.byStatus,
    this.activeCount,
    this.invalidCount,
    this.upcoming7Days,
  });

  factory StatsSummaryModel.fromJson(Map<String, dynamic> json) {
    return StatsSummaryModel(
      totalAppointments: json['total_appointments'] as int?,
      thisMonthCreated: json['this_month_created'] as int?,
      byStatus: (json['by_status'] as List<dynamic>?)
          ?.map((e) =>
              StatsSummaryStatusModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeCount: json['active_count'] as int?,
      invalidCount: json['invalid_count'] as int?,
      upcoming7Days: json['upcoming_7_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_appointments': totalAppointments,
        'this_month_created': thisMonthCreated,
        'by_status': byStatus?.map((e) => e.toJson()).toList(),
        'active_count': activeCount,
        'invalid_count': invalidCount,
        'upcoming_7_days': upcoming7Days,
      };
}
