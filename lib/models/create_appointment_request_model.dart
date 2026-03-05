class CreateAppointmentRequestModel {
  final String title;
  final String startsAt;
  final String endsAt;
  final int? statusId;
  final String? notes;
  final List<int>? assignmentMembershipIds;
  final Map<String, dynamic>? customFields;

  const CreateAppointmentRequestModel({
    required this.title,
    required this.startsAt,
    required this.endsAt,
    this.statusId,
    this.notes,
    this.assignmentMembershipIds,
    this.customFields,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'starts_at': startsAt,
        'ends_at': endsAt,
        if (statusId != null) 'status_id': statusId,
        if (notes != null) 'notes': notes,
        if (assignmentMembershipIds != null)
          'assignment_membership_ids': assignmentMembershipIds,
        if (customFields != null) 'custom_fields': customFields,
      };
}
