import 'package:flutter/foundation.dart';
import '../app/app_constants.dart';
import '../core/network/api_result.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
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

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    final request = LoginRequestModel(
      email: email.trim(),
      password: password,
      deviceName: AppConstants.deviceName,
    );

    final result = await AuthService.instance.login(request);

    _setLoading(false);

    return switch (result) {
      ApiSuccess(:final data) => _onLoginSuccess(data),
      ApiFailure(:final exception) => _onLoginFailure(exception.message),
    };
  }

  bool _onLoginSuccess(AuthResponseModel data) {
    _authResponse = data;
    AuthService.instance.saveSession(data);
    notifyListeners();
    return true;
  }

  bool _onLoginFailure(String message) {
    _setError(message);
    return false;
  }

  void onRetry({required String email, required String password}) {
    login(email: email, password: password);
  }
}
