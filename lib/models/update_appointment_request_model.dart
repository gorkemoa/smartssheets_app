class UpdateAppointmentRequestModel {
  final String? title;
  final String? startsAt;
  final String? endsAt;
  final int? statusId;
  final String? notes;
  final String? resultNotes;
  final List<int>? assignmentMembershipIds;
  final Map<String, dynamic>? customFields;

  const UpdateAppointmentRequestModel({
    this.title,
    this.startsAt,
    this.endsAt,
    this.statusId,
    this.notes,
    this.resultNotes,
    this.assignmentMembershipIds,
    this.customFields,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (startsAt != null) 'starts_at': startsAt,
        if (endsAt != null) 'ends_at': endsAt,
        if (statusId != null) 'status_id': statusId,
        if (notes != null) 'notes': notes,
        if (resultNotes != null) 'result_notes': resultNotes,
        if (assignmentMembershipIds != null)
          'assignment_membership_ids': assignmentMembershipIds,
        if (customFields != null) 'custom_fields': customFields,
      };
}
