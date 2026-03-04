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

    AppLogger.request(
      _tag,
      'URL: $uri\nMETHOD: POST\nHEADERS: $headers\nBODY: $encodedBody',
    );

    try {
      final response = await http
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response, uri.toString(), 'POST');
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

    AppLogger.request(
      _tag,
      'URL: $uri\nMETHOD: GET\nHEADERS: $headers',
    );

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      return _handleResponse(response, uri.toString(), 'GET');
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

  Future<ApiResult<Map<String, dynamic>>> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = _buildHeaders(requiresAuth: requiresAuth);
    final encodedBody = jsonEncode(body);

    AppLogger.request(
      _tag,
      'URL: $uri\nMETHOD: PATCH\nHEADERS: $headers\nBODY: $encodedBody',
    );

    try {
      final response = await http
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response, uri.toString(), 'PATCH');
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

  Future<ApiResult<Map<String, dynamic>>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = _buildHeaders(requiresAuth: requiresAuth);

    AppLogger.request(
      _tag,
      'URL: $uri\nMETHOD: DELETE\nHEADERS: $headers',
    );

    try {
      final response = await http
          .delete(uri, headers: headers)
          .timeout(_timeout);

      return _handleResponse(response, uri.toString(), 'DELETE');
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

  ApiResult<Map<String, dynamic>> _handleResponse(
    http.Response response,
    String url,
    String method,
  ) {
    AppLogger.response(
      _tag,
      'URL: $url\nMETHOD: $method\nSTATUS: ${response.statusCode}\nBODY: ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 204 No Content — body is empty, return an empty map
      if (response.statusCode == 204 || response.body.isEmpty) {
        return const ApiSuccess({});
      }
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
