class AssignAppointmentRequestModel {
  final List<int> assignmentMembershipIds;

  const AssignAppointmentRequestModel({
    required this.assignmentMembershipIds,
  });

  Map<String, dynamic> toJson() => {
        'assignment_membership_ids': assignmentMembershipIds,
      };
}
