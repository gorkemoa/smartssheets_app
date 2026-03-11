import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/billing_plans_response_model.dart';
import '../models/billing_status_model.dart';
import '../models/change_password_request_model.dart';
import '../models/delete_account_request_model.dart';
import '../models/me_response_model.dart';
import '../models/update_profile_request_model.dart';
import '../services/auth_service.dart';
import '../services/billing_service.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  MeResponseModel? _meResponse;
  bool _isSubmitting = false;
  final Map<int, BillingPlansResponseModel> _billingPlansMap = {};
  final Map<int, BillingStatusModel> _billingStatusMap = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MeResponseModel? get meResponse => _meResponse;
  bool get isSubmitting => _isSubmitting;
  Map<int, BillingPlansResponseModel> get billingPlansMap =>
      Map.unmodifiable(_billingPlansMap);
  Map<int, BillingStatusModel> get billingStatusMap =>
      Map.unmodifiable(_billingStatusMap);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> init() async {
    _setLoading(true);
    _setError(null);
    await _fetchMe();
    await _fetchBillingForMemberships();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchMe();
    await _fetchBillingForMemberships();
    _setLoading(false);
  }

  Future<void> onRetry() async {
    await init();
  }

  Future<void> _fetchMe() async {
    final result = await AuthService.instance.me();
    switch (result) {
      case ApiSuccess(:final data):
        _meResponse = data;
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<void> _fetchBillingForMemberships() async {
    final memberships = _meResponse?.user?.memberships;
    if (memberships == null || memberships.isEmpty) return;
    final brandIds = memberships
        .map((m) => m.brand?.id ?? m.brandId)
        .whereType<int>()
        .toSet();
    await Future.wait(brandIds.map((id) async {
      await Future.wait([_fetchBillingPlans(id), _fetchBillingStatus(id)]);
    }));
  }

  Future<void> _fetchBillingPlans(int brandId) async {
    final result = await BillingService.instance.getPlans(brandId);
    if (result case ApiSuccess(:final data)) {
      _billingPlansMap[brandId] = data;
      notifyListeners();
    }
  }

  Future<void> _fetchBillingStatus(int brandId) async {
    final result = await BillingService.instance.getBillingStatus(brandId);
    if (result case ApiSuccess(:final data)) {
      _billingStatusMap[brandId] = data;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    await AuthService.instance.logout();
    _setLoading(false);
    return true;
  }

  Future<bool> updateProfile(UpdateProfileRequestModel request) async {
    _isSubmitting = true;
    notifyListeners();
    final result = await AuthService.instance.updateProfile(request);
    _isSubmitting = false;
    notifyListeners();
    switch (result) {
      case ApiSuccess():
        await _fetchMe();
        return true;
      case ApiFailure(:final exception):
        return Future.error(exception.message);
    }
  }

  Future<bool> changePassword(ChangePasswordRequestModel request) async {
    _isSubmitting = true;
    notifyListeners();
    final result = await AuthService.instance.changePassword(request);
    _isSubmitting = false;
    notifyListeners();
    switch (result) {
      case ApiSuccess():
        return true;
      case ApiFailure(:final exception):
        return Future.error(exception.message);
    }
  }

  Future<bool> deleteAccount(DeleteAccountRequestModel request) async {
    _isSubmitting = true;
    notifyListeners();
    final result = await AuthService.instance.deleteAccount(request);
    _isSubmitting = false;
    notifyListeners();
    switch (result) {
      case ApiSuccess():
        await AuthService.instance.clearSession();
        return true;
      case ApiFailure(:final exception):
        return Future.error(exception.message);
    }
  }
}
