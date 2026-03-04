import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error, debug, request, response }

class AppLogger {
  AppLogger._();

  static void _log(LogLevel level, String tag, String message, [Object? extra]) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final prefix = _prefix(level);
    final output = extra != null
        ? '[$timestamp] $prefix [$tag] $message\n$extra'
        : '[$timestamp] $prefix [$tag] $message';

    debugPrint(output);
  }

  static String _prefix(LogLevel level) {
    return switch (level) {
      LogLevel.info => 'ℹ️  INFO',
      LogLevel.warning => '⚠️  WARN',
      LogLevel.error => '❌ ERROR',
      LogLevel.debug => '🐛 DEBUG',
      LogLevel.request => '➡️  REQUEST',
      LogLevel.response => '⬅️  RESPONSE',
    };
  }

  static void info(String tag, String message) => _log(LogLevel.info, tag, message);
  static void warning(String tag, String message) => _log(LogLevel.warning, tag, message);
  static void error(String tag, String message, [Object? error]) => _log(LogLevel.error, tag, message, error);
  static void debug(String tag, String message) => _log(LogLevel.debug, tag, message);
  static void request(String tag, String message) => _log(LogLevel.request, tag, message);
  static void response(String tag, String message) => _log(LogLevel.response, tag, message);
}
