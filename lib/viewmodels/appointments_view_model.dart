import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/appointment_model.dart';
import '../models/create_appointment_request_model.dart';
import '../models/update_appointment_request_model.dart';
import '../services/appointment_service.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final int brandId;

  AppointmentsViewModel({required this.brandId});

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isLoading = false;
  String? _errorMessage;
  List<AppointmentModel> _appointments = [];
  bool _isSubmitting = false;
  String? _submitError;

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
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
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
}
