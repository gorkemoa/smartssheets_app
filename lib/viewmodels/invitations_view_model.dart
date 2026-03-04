import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/create_invitation_request_model.dart';
import '../models/invitation_model.dart';
import '../models/membership_permissions_model.dart';
import '../services/invitation_service.dart';

class InvitationsViewModel extends ChangeNotifier {
  final int brandId;

  InvitationsViewModel({required this.brandId});

  bool _isLoading = false;
  String? _errorMessage;
  List<InvitationModel> _invitations = [];
  bool _isSubmitting = false;
  String? _submitError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<InvitationModel> get invitations => _invitations;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearSubmitError() {
    _submitError = null;
    notifyListeners();
  }

  Future<void> init() async {
    _setLoading(true);
    _setError(null);
    await _fetchInvitations();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchInvitations();
    _setLoading(false);
  }

  Future<void> onRetry() async => init();

  // No pagination — satisfies ViewModel contract
  Future<void> loadMore() async {}

  Future<void> _fetchInvitations() async {
    final result = await InvitationService.instance.invitations(brandId);
    switch (result) {
      case ApiSuccess(:final data):
        _invitations = data.invitations;
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<bool> createInvitation({
    required String email,
    required String role,
    required bool permCreateAppointment,
    required bool permUploadResult,
    required bool permChangeStatus,
    required bool permManageMembers,
    required bool permManageStatuses,
    required bool permManageAppointmentFields,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await InvitationService.instance.createInvitation(
      brandId,
      CreateInvitationRequestModel(
        email: email,
        role: role,
        permissions: MembershipPermissionsModel(
          createAppointment: permCreateAppointment,
          uploadResult: permUploadResult,
          changeStatus: permChangeStatus,
          manageMembers: permManageMembers,
          manageStatuses: permManageStatuses,
          manageAppointmentFields: permManageAppointmentFields,
        ),
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchInvitations();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> resendInvitation(int invitationId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await InvitationService.instance.resendInvitation(
      brandId,
      invitationId,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> deleteInvitation(int invitationId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await InvitationService.instance.deleteInvitation(
      brandId,
      invitationId,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        _invitations.removeWhere((inv) => inv.id == invitationId);
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }
}
