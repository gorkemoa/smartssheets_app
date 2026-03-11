import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../core/network/api_result.dart';
import 'dart:async' show unawaited;
import '../models/appointment_model.dart';
import '../models/assign_appointment_request_model.dart';
import '../models/create_appointment_request_model.dart';
import '../models/update_appointment_request_model.dart';
import '../models/update_result_notes_request_model.dart';
import '../models/appointment_result_file_model.dart';
import '../models/appointment_statuses_response_model.dart';
import '../services/appointment_service.dart';
import '../services/appointment_status_service.dart';
import '../services/watch_connectivity_service.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final int brandId;

  AppointmentsViewModel({required this.brandId}) {
    WatchConnectivityService.instance.setStatusChangeHandler(
      _changeStatusFromWatch,
    );
  }

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isLoading = false;
  String? _errorMessage;
  List<AppointmentModel> _appointments = [];
  bool _isSubmitting = false;
  String? _submitError;

  // Result files
  bool _isLoadingFiles = false;
  String? _filesError;
  List<AppointmentResultFileModel> _resultFiles = [];
  bool _isUploadingFiles = false;

  // Track current loaded range
  late DateTime _rangeFrom;
  late DateTime _rangeTo;

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppointmentModel> get appointments => _appointments;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  bool get isLoadingFiles => _isLoadingFiles;
  String? get filesError => _filesError;
  List<AppointmentResultFileModel> get resultFiles => _resultFiles;
  bool get isUploadingFiles => _isUploadingFiles;

  List<AppointmentModel> get selectedDayAppointments {
    return _appointments.where((a) {
      final dt = a.startsAtDateTime;
      if (dt == null) return false;
      return _isSameDay(dt, _selectedDay);
    }).toList()
      ..sort((a, b) {
        final ta = a.startsAtDateTime ?? DateTime(0);
        final tb = b.startsAtDateTime ?? DateTime(0);
        return ta.compareTo(tb);
      });
  }

  /// Returns appointments for a given day (used by table_calendar event loader).
  List<AppointmentModel> eventsForDay(DateTime day) {
    return _appointments.where((a) {
      final dt = a.startsAtDateTime;
      if (dt == null) return false;
      return _isSameDay(dt, day);
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
    final now = DateTime.now();
    _rangeFrom = DateTime(now.year, now.month, 1);
    _rangeTo = DateTime(now.year, now.month + 1, 0);
    _setLoading(true);
    _setError(null);
    await _fetchCalendar();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await _fetchCalendar();
    _setLoading(false);
  }

  Future<void> onRetry() async => init();

  Future<void> loadMore() async {}

  /// Called by table_calendar when the visible month page changes.
  Future<void> onPageChanged(DateTime firstDayOfMonth) async {
    _focusedDay = firstDayOfMonth;
    _rangeFrom = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, 1);
    _rangeTo = DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0);
    _setError(null);
    await _fetchCalendar();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  Future<void> _fetchCalendar() async {
    final result = await AppointmentService.instance.calendar(
      brandId,
      from: _fmt(_rangeFrom),
      to: _fmt(_rangeTo),
    );
    switch (result) {
      case ApiSuccess(:final data):
        _appointments = data.appointments;
        unawaited(_pushToWidget(_appointments));
        unawaited(_pushToWatch(_appointments));
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<void> _pushToWidget(List<AppointmentModel> appointments) async {
    if (!Platform.isIOS) return;
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final upcoming = appointments
          .where((a) {
            final dt = a.startsAtDateTime;
            return dt != null && !dt.isBefore(today);
          })
          .take(5)
          .map((a) => {
                'id': a.id ?? 0,
                'title': a.title ?? '',
                'starts_at': a.startsAt ?? '',
                'status_name': a.status?.name ?? '',
                'status_color': a.status?.color ?? '#999999',
              })
          .toList();
      await HomeWidget.saveWidgetData<String>(
        'appointments_json',
        jsonEncode(upcoming),
      );
      await HomeWidget.updateWidget(iOSName: 'AppointmentsWidget');
    } catch (_) {}
  }

  /// Randevuları Apple Watch'a gönderir.
  /// Upcoming / Current / Past olarak üç kategoriye ayırır.
  Future<void> _pushToWatch(List<AppointmentModel> appointments) async {
    if (!Platform.isIOS) return;
    try {
      final now = DateTime.now();

      // Tarih ve saat formatlama yardımcıları
      String fmtDate(DateTime dt) => '${dt.day} ${_monthName(dt.month)}';
      String fmtTime(DateTime dt) =>
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      Map<String, dynamic> toWatchMap(AppointmentModel a) {
        final dt = a.startsAtDateTime;
        final dtEnd = a.endsAtDateTime;
        return {
          'appointment_id': a.id ?? 0,
          'status_id': a.status?.id ?? 0,
          'title': a.title ?? '',
          'date': dt != null ? fmtDate(dt) : '',
          'time': dt != null ? fmtTime(dt) : '',
          'end_time': dtEnd != null ? fmtTime(dtEnd) : '',
          'status_name': a.status?.name ?? '',
          'status_color': a.status?.color ?? '#888888',
          'notes': a.notes ?? '',
        };
      }

      // Şu an devam eden: başlamış ama bitmemiş
      final currentList = appointments.where((a) {
        final start = a.startsAtDateTime;
        final end = a.endsAtDateTime;
        if (start == null || start.isAfter(now)) return false;
        if (end != null && end.isBefore(now)) return false;
        return true;
      }).toList();

      // Yaklaşan: henüz başlamamış, en yakın 10 randevu
      final upcoming = appointments
          .where((a) {
            final dt = a.startsAtDateTime;
            return dt != null && dt.isAfter(now);
          })
          .take(10)
          .map(toWatchMap)
          .toList();

      // Geçmiş: bitiş zamanı geçmiş, en son 10 randevu
      final past = appointments
          .where((a) {
            final end = a.endsAtDateTime;
            final start = a.startsAtDateTime;
            if (end != null && end.isBefore(now)) return true;
            // Bitiş saati yoksa başlangıçtan 1 saat sonra geçmiş say
            if (end == null && start != null) {
              return start.isBefore(now.subtract(const Duration(hours: 1)));
            }
            return false;
          })
          .take(10)
          .map(toWatchMap)
          .toList();

      // Markaya ait tüm statü seçeneklerini çek
      List<Map<String, dynamic>> statusMaps = [];
      final statusResult =
          await AppointmentStatusService.instance.statuses(brandId);
      switch (statusResult) {
        case ApiSuccess<AppointmentStatusesResponseModel>(:final data):
          statusMaps = data.statuses
              .map((s) => {
                    'id': s.id ?? 0,
                    'name': s.name ?? '',
                    'color': s.color ?? '#888888',
                  })
              .toList();
        case ApiFailure():
          break; // statü listesi olmadan devam et
      }

      await WatchConnectivityService.instance.sendAppointments(
        upcoming: upcoming,
        current: currentList.isNotEmpty ? toWatchMap(currentList.first) : null,
        past: past,
        statuses: statusMaps,
      );
    } catch (_) {}  }

  /// Watch'tan gelen durum değiştirme isteğini işler.
  Future<bool> _changeStatusFromWatch(
    int appointmentId,
    int statusId,
  ) async {
    final result = await AppointmentService.instance.updateAppointment(
      brandId,
      appointmentId,
      UpdateAppointmentRequestModel(statusId: statusId),
    );
    switch (result) {
      case ApiSuccess():
        await _fetchCalendar(); // Güncel listeyi Watch'a tekrar gönder
        return true;
      case ApiFailure():
        return false;
    }
  }

  /// Türkçe ay adı döndürür.
  String _monthName(int month) {
    const months = [
      '',
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return months[month];
  }

  Future<bool> createAppointment(
    CreateAppointmentRequestModel request,
  ) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.createAppointment(
      brandId,
      request,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchCalendar();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateAppointment(
    int appointmentId,
    UpdateAppointmentRequestModel request,
  ) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.updateAppointment(
      brandId,
      appointmentId,
      request,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchCalendar();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> assignAppointment(
    int appointmentId,
    AssignAppointmentRequestModel request,
  ) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.assignAppointment(
      brandId,
      appointmentId,
      request,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchCalendar();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateResultNotes(
    int appointmentId,
    UpdateResultNotesRequestModel request,
  ) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.updateResultNotes(
      brandId,
      appointmentId,
      request,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchCalendar();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> deleteAppointment(int appointmentId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.deleteAppointment(
      brandId,
      appointmentId,
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchCalendar();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  // ── Result Files ─────────────────────────────────────────────

  Future<void> loadResultFiles(int appointmentId) async {
    _isLoadingFiles = true;
    _filesError = null;
    notifyListeners();

    final result = await AppointmentService.instance.listResultFiles(
      brandId,
      appointmentId,
    );

    _isLoadingFiles = false;
    switch (result) {
      case ApiSuccess(:final data):
        _resultFiles = data.files;
      case ApiFailure(:final exception):
        _filesError = exception.message;
    }
    notifyListeners();
  }

  Future<bool> uploadResultFiles(
    int appointmentId,
    List<File> files,
  ) async {
    _isUploadingFiles = true;
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.uploadResultFiles(
      brandId,
      appointmentId,
      files,
    );

    _isUploadingFiles = false;
    switch (result) {
      case ApiSuccess(:final data):
        _resultFiles = data.files;
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<String?> getResultFileDownloadUrl(
    int appointmentId,
    int fileId,
  ) async {
    final result = await AppointmentService.instance.getResultFileDownloadUrl(
      brandId,
      fileId,
    );
    return switch (result) {
      ApiSuccess(:final data) => data.url,
      ApiFailure() => null,
    };
  }

  Future<bool> deleteResultFile(
    int appointmentId,
    int fileId,
  ) async {
    _submitError = null;
    notifyListeners();

    final result = await AppointmentService.instance.deleteResultFile(
      brandId,
      appointmentId,
      fileId,
    );

    switch (result) {
      case ApiSuccess():
        _resultFiles.removeWhere((f) => f.id == fileId);
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  void clearResultFiles() {
    _resultFiles = [];
    _filesError = null;
    _isLoadingFiles = false;
    notifyListeners();
  }
}