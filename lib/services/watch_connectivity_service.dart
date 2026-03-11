import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

/// Flutter ↔ iOS Platform Channel köprüsü.
///
/// sendAppointments  : Flutter → Watch (randevu listesi + statüler)
/// changeAppointmentStatus (gelen) : Watch → iPhone → Flutter (durum güncelle)
class WatchConnectivityService {
  static const MethodChannel _channel =
      MethodChannel('com.smartmetrics.smartsheetsapp/watch');

  static final WatchConnectivityService instance =
      WatchConnectivityService._();

  /// Watch'tan gelen "durum değiştir" isteği için çağrılacak handler.
  /// Dönüş değeri true → başarılı, false → başarısız.
  Future<bool> Function(int appointmentId, int statusId)? _statusChangeHandler;

  WatchConnectivityService._() {
    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethodCall);
    }
  }

  /// ViewModel bu metodu ile durum değiştirme handler'ını kaydeder.
  void setStatusChangeHandler(
    Future<bool> Function(int appointmentId, int statusId) handler,
  ) {
    _statusChangeHandler = handler;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'changeAppointmentStatus') {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final appointmentId = args['appointment_id'] as int;
      final statusId = args['status_id'] as int;
      return await _statusChangeHandler?.call(appointmentId, statusId) ?? false;
    }
    return null;
  }

  /// Randevuları ve mevcut statü listesini Apple Watch'a gönderir.
  ///
  /// [upcoming]  : Henüz başlamamış randevular (max 10)
  /// [current]   : Şu an aktif randevu, yoksa null
  /// [past]      : Geçmiş randevular (max 10)
  /// [statuses]  : Markaya ait tüm statü seçenekleri
  Future<void> sendAppointments({
    required List<Map<String, dynamic>> upcoming,
    required Map<String, dynamic>? current,
    required List<Map<String, dynamic>> past,
    required List<Map<String, dynamic>> statuses,
  }) async {
    if (!Platform.isIOS) return;
    try {
      final payload = {
        'upcoming': upcoming,
        'current': current,
        'past': past,
        'statuses': statuses,
      };
      await _channel.invokeMethod('sendAppointments', {
        'data': jsonEncode(payload),
      });
    } catch (_) {
      // Watch bağlı değilse veya platform channel hatası olursa sessizce geç.
    }
  }
}
