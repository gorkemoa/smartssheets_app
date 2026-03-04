import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/create_member_request_model.dart';
import '../models/membership_model.dart';
import '../models/update_member_request_model.dart';
import '../services/member_service.dart';

class MembersViewModel extends ChangeNotifier {
  final int brandId;

  MembersViewModel({required this.brandId});

  bool _isLoading = false;
  String? _errorMessage;
  List<MembershipModel> _members = [];
  bool _isSubmitting = false;
  String? _submitError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MembershipModel> get members => _members;
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
    await _fetchMembers();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchMembers();
    _setLoading(false);
  }

  Future<void> onRetry() async {
    await init();
  }

  // Members list has no pagination — method satisfies ViewModel contract
  Future<void> loadMore() async {}

  Future<void> _fetchMembers() async {
    final result = await MemberService.instance.members(brandId);
    switch (result) {
      case ApiSuccess(:final data):
        _members = data.data ?? [];
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<bool> createMember({
    required String email,
    required String name,
    required String password,
    required String role,
    String? phone,
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

    final result = await MemberService.instance.createMember(
      brandId,
      CreateMemberRequestModel(
        email: email,
        name: name,
        password: password,
        role: role,
        phone: phone?.isEmpty == true ? null : phone,
        permissionsJson: {
          'create_appointment': permCreateAppointment,
          'upload_result': permUploadResult,
          'change_status': permChangeStatus,
          'manage_members': permManageMembers,
          'manage_statuses': permManageStatuses,
          'manage_appointment_fields': permManageAppointmentFields,
        },
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchMembers();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateMember(
    int memberId, {
    required String role,
    required String status,
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

    final result = await MemberService.instance.updateMember(
      brandId,
      memberId,
      UpdateMemberRequestModel(
        role: role,
        status: status,
        permissionsJson: {
          'create_appointment': permCreateAppointment,
          'upload_result': permUploadResult,
          'change_status': permChangeStatus,
          'manage_members': permManageMembers,
          'manage_statuses': permManageStatuses,
          'manage_appointment_fields': permManageAppointmentFields,
        },
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchMembers();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> deleteMember(int memberId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result =
        await MemberService.instance.deleteMember(brandId, memberId);

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchMembers();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }
}
