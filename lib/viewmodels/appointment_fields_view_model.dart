import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/appointment_field_model.dart';
import '../models/appointment_field_option_model.dart';
import '../models/appointment_field_validations_model.dart';
import '../models/create_appointment_field_request_model.dart';
import '../models/update_appointment_field_request_model.dart';
import '../services/appointment_field_service.dart';

class AppointmentFieldsViewModel extends ChangeNotifier {
  final int brandId;

  AppointmentFieldsViewModel({required this.brandId});

  bool _isLoading = false;
  String? _errorMessage;
  List<AppointmentFieldModel> _fields = [];
  bool _isSubmitting = false;
  String? _submitError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppointmentFieldModel> get fields => _fields;
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
    await _fetchFields();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchFields();
    _setLoading(false);
  }

  Future<void> onRetry() async => init();

  Future<void> loadMore() async {}

  Future<void> _fetchFields() async {
    final result = await AppointmentFieldService.instance.fields(brandId);
    switch (result) {
      case ApiSuccess(:final data):
        _fields = data.fields;
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<bool> createField({
    required String key,
    required String label,
    required String type,
    bool? required,
    bool? isActive,
    int? sortOrder,
    String? helpText,
    List<AppointmentFieldOptionModel>? optionsJson,
    AppointmentFieldValidationsModel? validationsJson,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentFieldService.instance.createField(
      brandId,
      CreateAppointmentFieldRequestModel(
        key: key,
        label: label,
        type: type,
        required: required,
        isActive: isActive,
        sortOrder: sortOrder,
        helpText: helpText,
        optionsJson: optionsJson,
        validationsJson: validationsJson,
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchFields();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateField(
    int fieldId, {
    String? label,
    String? type,
    bool? required,
    bool? isActive,
    int? sortOrder,
    String? helpText,
    List<AppointmentFieldOptionModel>? optionsJson,
    AppointmentFieldValidationsModel? validationsJson,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentFieldService.instance.updateField(
      brandId,
      fieldId,
      UpdateAppointmentFieldRequestModel(
        label: label,
        type: type,
        required: required,
        isActive: isActive,
        sortOrder: sortOrder,
        helpText: helpText,
        optionsJson: optionsJson,
        validationsJson: validationsJson,
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchFields();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> deleteField(int fieldId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentFieldService.instance.deleteField(
      brandId,
      fieldId,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        _fields.removeWhere((f) => f.id == fieldId);
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }
}
