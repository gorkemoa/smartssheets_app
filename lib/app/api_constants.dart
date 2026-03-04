class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://smart-sheet.getsmarty.com.tr/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Brands
  static const String brands = '/brands';
  static String brandById(int id) => '/brands/$id';
  static String brandMembers(int id) => '/brands/$id/members';
  static String brandMemberById(int brandId, int memberId) =>
      '/brands/$brandId/members/$memberId';

  // Invitations
  static String brandInvitations(int brandId) =>
      '/brands/$brandId/invitations';
  static String brandInvitationById(int brandId, int invId) =>
      '/brands/$brandId/invitations/$invId';
  static String brandInvitationResend(int brandId, int invId) =>
      '/brands/$brandId/invitations/$invId/resend';
  static const String invitationAccept = '/invitations/accept';

  // Appointment Statuses
  static String brandStatuses(int brandId) => '/brands/$brandId/statuses';
  static String brandStatusById(int brandId, int statusId) =>
      '/brands/$brandId/statuses/$statusId';

  // Appointment Custom Fields
  static String brandAppointmentFields(int brandId) =>
      '/brands/$brandId/settings/appointment-fields';
  static String brandAppointmentFieldById(int brandId, int fieldId) =>
      '/brands/$brandId/settings/appointment-fields/$fieldId';
}
