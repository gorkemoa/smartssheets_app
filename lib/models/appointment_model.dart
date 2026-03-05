import 'appointment_assignee_model.dart';
import 'appointment_status_summary_model.dart';

class AppointmentModel {
  final int? id;
  final int? brandId;
  final String? title;
  final String? startsAt;
  final String? endsAt;
  final AppointmentStatusSummaryModel? status;
  final String? notes;
  final String? resultNotes;
  final String? completedAt;
  final Map<String, dynamic>? customFields;
  final List<AppointmentAssigneeModel>? assignees;
  final String? createdAt;
  final String? updatedAt;

  const AppointmentModel({
    this.id,
    this.brandId,
    this.title,
    this.startsAt,
    this.endsAt,
    this.status,
    this.notes,
    this.resultNotes,
    this.completedAt,
    this.customFields,
    this.assignees,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    List<AppointmentAssigneeModel>? assignees;
    if (json['assignees'] != null) {
      assignees = (json['assignees'] as List<dynamic>)
          .map((a) =>
              AppointmentAssigneeModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return AppointmentModel(
      id: json['id'] as int?,
      brandId: json['brand_id'] as int?,
      title: json['title'] as String?,
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      status: json['status'] != null
          ? AppointmentStatusSummaryModel.fromJson(
              json['status'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
      resultNotes: json['result_notes'] as String?,
      completedAt: json['completed_at'] as String?,
      customFields: json['custom_fields'] != null
          ? Map<String, dynamic>.from(
              json['custom_fields'] as Map<String, dynamic>)
          : null,
      assignees: assignees,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (brandId != null) 'brand_id': brandId,
        if (title != null) 'title': title,
        if (startsAt != null) 'starts_at': startsAt,
        if (endsAt != null) 'ends_at': endsAt,
        if (status != null) 'status': status!.toJson(),
        if (notes != null) 'notes': notes,
        if (resultNotes != null) 'result_notes': resultNotes,
        if (completedAt != null) 'completed_at': completedAt,
        if (customFields != null) 'custom_fields': customFields,
        if (assignees != null)
          'assignees': assignees!.map((a) => a.toJson()).toList(),
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };

  /// Parses startsAt to a DateTime in local time, or returns null.
  DateTime? get startsAtDateTime {
    if (startsAt == null) return null;
    try {
      return DateTime.parse(startsAt!).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Parses endsAt to a DateTime in local time, or returns null.
  DateTime? get endsAtDateTime {
    if (endsAt == null) return null;
    try {
      return DateTime.parse(endsAt!).toLocal();
    } catch (_) {
      return null;
    }
  }
}
