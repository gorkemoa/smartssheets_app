import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/appointment_status_model.dart';
import '../models/create_appointment_status_request_model.dart';
import '../models/update_appointment_status_request_model.dart';
import '../services/appointment_status_service.dart';

class AppointmentStatusesViewModel extends ChangeNotifier {
  final int brandId;

  AppointmentStatusesViewModel({required this.brandId});

  bool _isLoading = false;
  String? _errorMessage;
  List<AppointmentStatusModel> _statuses = [];
  bool _isSubmitting = false;
  String? _submitError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppointmentStatusModel> get statuses => _statuses;
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
    await _fetchStatuses();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchStatuses();
    _setLoading(false);
  }

  Future<void> onRetry() async => init();

  // No pagination — satisfies ViewModel contract
  Future<void> loadMore() async {}

  Future<void> _fetchStatuses() async {
    final result = await AppointmentStatusService.instance.statuses(brandId);
    switch (result) {
      case ApiSuccess(:final data):
        _statuses = data.statuses;
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<bool> createStatus({
    required String name,
    required String color,
    required int sortOrder,
    required bool isDefault,
    required bool isActive,
    required String statusType,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentStatusService.instance.createStatus(
      brandId,
      CreateAppointmentStatusRequestModel(
        name: name,
        color: color,
        sortOrder: sortOrder,
        isDefault: isDefault,
        isActive: isActive,
        statusType: statusType,
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchStatuses();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateStatus(
    int statusId, {
    required String name,
    required String color,
    required int sortOrder,
    required bool isDefault,
    required bool isActive,
    required String statusType,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentStatusService.instance.updateStatus(
      brandId,
      statusId,
      UpdateAppointmentStatusRequestModel(
        name: name,
        color: color,
        sortOrder: sortOrder,
        isDefault: isDefault,
        isActive: isActive,
        statusType: statusType,
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchStatuses();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> deleteStatus(int statusId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentStatusService.instance.deleteStatus(
      brandId,
      statusId,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        _statuses.removeWhere((s) => s.id == statusId);
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }
}
