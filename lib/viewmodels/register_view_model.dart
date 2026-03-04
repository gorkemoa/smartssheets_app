import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  AuthResponseModel? _authResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthResponseModel? get authResponse => _authResponse;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _setError(null);

    final request = RegisterRequestModel(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final result = await AuthService.instance.register(request);

    _setLoading(false);

    return switch (result) {
      ApiSuccess(:final data) => _onRegisterSuccess(data),
      ApiFailure(:final exception) => _onRegisterFailure(exception.message),
    };
  }

  bool _onRegisterSuccess(AuthResponseModel data) {
    _authResponse = data;
    AuthService.instance.saveSession(data);
    notifyListeners();
    return true;
  }

  bool _onRegisterFailure(String message) {
    _setError(message);
    return false;
  }
}
