import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../app/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/change_password_request_model.dart';
import '../models/delete_account_request_model.dart';
import '../models/login_request_model.dart';
import '../models/me_response_model.dart';
import '../models/register_request_model.dart';
import '../models/update_profile_request_model.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _tag = 'AuthService';

  Future<ApiResult<AuthResponseModel>> login(LoginRequestModel request) async {
    AppLogger.info(_tag, 'login() called for email: ${request.email}');

    final result = await ApiClient.instance.post(
      ApiConstants.login,
      body: request.toJson(),
      requiresAuth: false,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAuthResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  Future<ApiResult<AuthResponseModel>> register(RegisterRequestModel request) async {
    AppLogger.info(_tag, 'register() called for email: ${request.email}');

    final result = await ApiClient.instance.post(
      ApiConstants.register,
      body: request.toJson(),
      requiresAuth: false,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAuthResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  ApiResult<AuthResponseModel> _mapToAuthResponse(Map<String, dynamic> data) {
    try {
      final model = AuthResponseModel.fromJson(data);
      AppLogger.info(_tag, 'Auth response parsed. userId: ${model.user?.id}');
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToAuthResponse', e);
      return ApiFailure(
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }

  Future<void> saveSession(AuthResponseModel authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    if (authResponse.token != null) {
      await prefs.setString(AppConstants.keyAuthToken, authResponse.token!);
      ApiClient.instance.setAuthToken(authResponse.token);
      AppLogger.info(_tag, 'Session saved. userId: ${authResponse.user?.id}');
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    ApiClient.instance.setAuthToken(null);
    AppLogger.info(_tag, 'Session cleared.');
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);
    if (token != null && token.isNotEmpty) {
      ApiClient.instance.setAuthToken(token);
      AppLogger.info(_tag, 'Session restored.');
      return true;
    }
    return false;
  }

  Future<ApiResult<MeResponseModel>> me() async {
    AppLogger.info(_tag, 'me() called');

    final result = await ApiClient.instance.get(
      ApiConstants.me,
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToMeResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  ApiResult<MeResponseModel> _mapToMeResponse(Map<String, dynamic> data) {
    try {
      final model = MeResponseModel.fromJson(data);
      AppLogger.info(_tag, 'Me response parsed. userId: \${model.user?.id}');
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToMeResponse', e);
      return ApiFailure(
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }

  Future<void> logout() async {
    AppLogger.info(_tag, 'logout() called');
    await ApiClient.instance.post(
      ApiConstants.logout,
      body: {},
      requiresAuth: true,
    );
    await clearSession();
  }

  Future<ApiResult<void>> updateProfile(
    UpdateProfileRequestModel request,
  ) async {
    AppLogger.info(_tag, 'updateProfile() called');

    final result = await ApiClient.instance.patch(
      ApiConstants.updateProfile,
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess() => const ApiSuccess(null),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  Future<ApiResult<void>> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    AppLogger.info(_tag, 'changePassword() called');

    final result = await ApiClient.instance.post(
      ApiConstants.changePassword,
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess() => const ApiSuccess(null),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  Future<ApiResult<void>> deleteAccount(
    DeleteAccountRequestModel request,
  ) async {
    AppLogger.info(_tag, 'deleteAccount() called');

    final result = await ApiClient.instance.delete(
      ApiConstants.deleteAccount,
      requiresAuth: true,
      body: request.toJson(),
    );

    return switch (result) {
      ApiSuccess() => const ApiSuccess(null),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }
}
