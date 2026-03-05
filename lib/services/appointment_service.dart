import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/appointment_detail_response_model.dart';
import '../models/calendar_response_model.dart';
import '../models/create_appointment_request_model.dart';
import '../models/update_appointment_request_model.dart';

class AppointmentService {
  AppointmentService._();

  static final AppointmentService instance = AppointmentService._();

  static const String _tag = 'AppointmentService';

  // GET /brands/{brandId}/calendar?from=YYYY-MM-DD&to=YYYY-MM-DD
  Future<ApiResult<CalendarResponseModel>> calendar(
    int brandId, {
    required String from,
    required String to,
  }) async {
    AppLogger.info(
      _tag,
      'calendar() called — brandId: $brandId, from: $from, to: $to',
    );

    final result = await ApiClient.instance.get(
      ApiConstants.brandCalendar(brandId),
      requiresAuth: true,
      queryParams: {'from': from, 'to': to},
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToCalendarResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // GET /brands/{brandId}/appointments/{appointmentId}
  Future<ApiResult<AppointmentDetailResponseModel>> appointmentDetail(
    int brandId,
    int appointmentId,
  ) async {
    AppLogger.info(
      _tag,
      'appointmentDetail() called — brandId: $brandId, appointmentId: $appointmentId',
    );

    final result = await ApiClient.instance.get(
      ApiConstants.brandAppointmentById(brandId, appointmentId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAppointmentDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/appointments
  Future<ApiResult<AppointmentDetailResponseModel>> createAppointment(
    int brandId,
    CreateAppointmentRequestModel request,
  ) async {
    AppLogger.info(_tag, 'createAppointment() called — brandId: $brandId');

    final result = await ApiClient.instance.post(
      ApiConstants.brandAppointments(brandId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAppointmentDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // PATCH /brands/{brandId}/appointments/{appointmentId}
  Future<ApiResult<AppointmentDetailResponseModel>> updateAppointment(
    int brandId,
    int appointmentId,
    UpdateAppointmentRequestModel request,
  ) async {
    AppLogger.info(
      _tag,
      'updateAppointment() called — brandId: $brandId, appointmentId: $appointmentId',
    );

    final result = await ApiClient.instance.patch(
      ApiConstants.brandAppointmentById(brandId, appointmentId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAppointmentDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  ApiResult<CalendarResponseModel> _mapToCalendarResponse(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(CalendarResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse calendar response: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }

  ApiResult<AppointmentDetailResponseModel> _mapToAppointmentDetail(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(AppointmentDetailResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse appointment detail: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }
}
