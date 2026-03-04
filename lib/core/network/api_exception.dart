enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  parseError,
  unknown,
}

class ApiException implements Exception {
  final ApiExceptionType type;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.network() => const ApiException(
        type: ApiExceptionType.network,
        message: 'İnternet bağlantısı kurulamadı.',
      );

  factory ApiException.timeout() => const ApiException(
        type: ApiExceptionType.timeout,
        message: 'Bağlantı zaman aşımına uğradı.',
      );

  factory ApiException.unauthorized({String? message}) => ApiException(
        type: ApiExceptionType.unauthorized,
        message: message ?? 'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );

  factory ApiException.forbidden({String? message}) => ApiException(
        type: ApiExceptionType.forbidden,
        message: message ?? 'Bu işlem için yetkiniz bulunmuyor.',
        statusCode: 403,
      );

  factory ApiException.notFound({String? message}) => ApiException(
        type: ApiExceptionType.notFound,
        message: message ?? 'İstenen kaynak bulunamadı.',
        statusCode: 404,
      );

  factory ApiException.serverError({String? message}) => ApiException(
        type: ApiExceptionType.serverError,
        message: message ?? 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.',
        statusCode: 500,
      );

  factory ApiException.parseError({String? message}) => ApiException(
        type: ApiExceptionType.parseError,
        message: message ?? 'Veri işlenirken bir hata oluştu.',
      );

  factory ApiException.fromStatusCode(
    int statusCode, {
    String? message,
    Map<String, dynamic>? errors,
  }) {
    // If we have detailed validation errors, prioritize the first one
    String? finalMessage = message;
    if (errors != null && errors.isNotEmpty) {
      final firstErrorValue = errors.values.first;
      if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
        finalMessage = firstErrorValue.first.toString();
      } else if (firstErrorValue is String) {
        finalMessage = firstErrorValue;
      }
    }

    switch (statusCode) {
      case 401:
        return ApiException.unauthorized(message: finalMessage);
      case 403:
        return ApiException.forbidden(message: finalMessage);
      case 404:
        return ApiException.notFound(message: finalMessage);
      case >= 500:
        return ApiException.serverError(message: finalMessage);
      default:
        return ApiException(
          type: ApiExceptionType.unknown,
          message: finalMessage ?? 'Bilinmeyen bir hata oluştu.',
          statusCode: statusCode,
          errors: errors,
        );
    }
  }

  @override
  String toString() => 'ApiException(type: $type, message: $message, statusCode: $statusCode)';
}
