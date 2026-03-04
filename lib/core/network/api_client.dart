import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../app/api_constants.dart';
import '../utils/logger.dart';
import 'api_exception.dart';
import 'api_result.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const Duration _timeout = Duration(seconds: 30);
  static const String _tag = 'ApiClient';

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
    AppLogger.debug(_tag, 'Auth token updated: ${token != null ? '***set***' : 'cleared'}');
  }

  Map<String, String> _buildHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Uri _buildUri(String endpoint) {
    return Uri.parse('${ApiConstants.baseUrl}$endpoint');
  }

  Future<ApiResult<Map<String, dynamic>>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = _buildHeaders(requiresAuth: requiresAuth);
    final encodedBody = jsonEncode(body);

    AppLogger.request(_tag, 'POST $uri\nHeaders: $headers\nBody: $encodedBody');

    try {
      final response = await http
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      AppLogger.error(_tag, 'Network error', e);
      return ApiFailure(ApiException.network());
    } on TimeoutException catch (e) {
      AppLogger.error(_tag, 'Timeout', e);
      return ApiFailure(ApiException.timeout());
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error', e);
      return ApiFailure(ApiException(
        type: ApiExceptionType.unknown,
        message: 'Beklenmeyen bir hata oluştu.',
      ));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> get(
    String endpoint, {
    bool requiresAuth = true,
    Map<String, String>? queryParams,
  }) async {
    final baseUri = _buildUri(endpoint);
    final uri = queryParams != null
        ? baseUri.replace(queryParameters: queryParams)
        : baseUri;
    final headers = _buildHeaders(requiresAuth: requiresAuth);

    AppLogger.request(_tag, 'GET $uri\nHeaders: $headers');

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      AppLogger.error(_tag, 'Network error', e);
      return ApiFailure(ApiException.network());
    } on TimeoutException catch (e) {
      AppLogger.error(_tag, 'Timeout', e);
      return ApiFailure(ApiException.timeout());
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error', e);
      return ApiFailure(ApiException(
        type: ApiExceptionType.unknown,
        message: 'Beklenmeyen bir hata oluştu.',
      ));
    }
  }

  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    AppLogger.response(
      _tag,
      'Status: ${response.statusCode}\nBody: ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiSuccess(decoded);
      } catch (e) {
        AppLogger.error(_tag, 'Parse error', e);
        return ApiFailure(ApiException.parseError());
      }
    }

    String? errorMessage;
    Map<String, dynamic>? errors;
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = decoded['message'] as String?;
      errors = decoded['errors'] as Map<String, dynamic>?;
    } catch (_) {}

    return ApiFailure(
      ApiException.fromStatusCode(
        response.statusCode,
        message: errorMessage,
        errors: errors,
      ),
    );
  }
}
