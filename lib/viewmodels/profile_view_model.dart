import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/me_response_model.dart';
import '../services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  MeResponseModel? _meResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MeResponseModel? get meResponse => _meResponse;

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
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchMe();
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

  Future<bool> logout() async {
    _setLoading(true);
    await AuthService.instance.logout();
    _setLoading(false);
    return true;
  }
}
