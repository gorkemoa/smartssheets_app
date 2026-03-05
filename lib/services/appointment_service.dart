import 'dart:io';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/appointment_detail_response_model.dart';
import '../models/assign_appointment_request_model.dart';
import '../models/calendar_response_model.dart';
import '../models/create_appointment_request_model.dart';
import '../models/update_appointment_request_model.dart';
import '../models/update_result_notes_request_model.dart';
import '../models/appointment_result_files_response_model.dart';
import '../models/appointment_result_file_download_response_model.dart';

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

  // POST /brands/{brandId}/appointments/{appointmentId}/assignments
  Future<ApiResult<AppointmentDetailResponseModel>> assignAppointment(
    int brandId,
    int appointmentId,
    AssignAppointmentRequestModel request,
  ) async {
    AppLogger.info(
      _tag,
      'assignAppointment() called — brandId: $brandId, appointmentId: $appointmentId',
    );

    final result = await ApiClient.instance.post(
      ApiConstants.brandAppointmentAssignments(brandId, appointmentId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAppointmentDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // PATCH /brands/{brandId}/appointments/{appointmentId}/results/notes
  Future<ApiResult<AppointmentDetailResponseModel>> updateResultNotes(
    int brandId,
    int appointmentId,
    UpdateResultNotesRequestModel request,
  ) async {
    AppLogger.info(
      _tag,
      'updateResultNotes() called — brandId: $brandId, appointmentId: $appointmentId',
    );

    final result = await ApiClient.instance.patch(
      ApiConstants.brandAppointmentResultNotes(brandId, appointmentId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToAppointmentDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // DELETE /brands/{brandId}/appointments/{appointmentId}
  Future<ApiResult<bool>> deleteAppointment(
    int brandId,
    int appointmentId,
  ) async {
    AppLogger.info(
      _tag,
      'deleteAppointment() called — brandId: $brandId, appointmentId: $appointmentId',
    );

    final result = await ApiClient.instance.delete(
      ApiConstants.brandAppointmentById(brandId, appointmentId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess() => const ApiSuccess(true),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  // GET /brands/{brandId}/appointments/{appointmentId}/results/files
  Future<ApiResult<AppointmentResultFilesResponseModel>> listResultFiles(
    int brandId,
    int appointmentId,
  ) async {
    AppLogger.info(
      _tag,
      'listResultFiles() — brandId: $brandId, appointmentId: $appointmentId',
    );
    final result = await ApiClient.instance.get(
      ApiConstants.brandAppointmentResultFiles(brandId, appointmentId),
      requiresAuth: true,
    );
    return switch (result) {
      ApiSuccess(:final data) => _mapToResultFiles(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/appointments/{appointmentId}/results/files
  Future<ApiResult<AppointmentResultFilesResponseModel>> uploadResultFiles(
    int brandId,
    int appointmentId,
    List<File> files,
  ) async {
    AppLogger.info(
      _tag,
      'uploadResultFiles() — brandId: $brandId, appointmentId: $appointmentId, count: ${files.length}',
    );
    final result = await ApiClient.instance.postMultipart(
      ApiConstants.brandAppointmentResultFiles(brandId, appointmentId),
      files: files,
      requiresAuth: true,
    );
    return switch (result) {
      ApiSuccess(:final data) => _mapToResultFiles(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // GET /brands/{brandId}/results/files/{fileId}/download
  Future<ApiResult<AppointmentResultFileDownloadResponseModel>> getResultFileDownloadUrl(
    int brandId,
    int fileId,
  ) async {
    AppLogger.info(
      _tag,
      'getResultFileDownloadUrl() — brandId: $brandId, fileId: $fileId',
    );
    final result = await ApiClient.instance.get(
      ApiConstants.brandResultFileDownload(brandId, fileId),
      requiresAuth: true,
    );
    return switch (result) {
      ApiSuccess(:final data) => _mapToDownloadResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // DELETE /brands/{brandId}/appointments/{appointmentId}/results/files/{fileId}
  Future<ApiResult<bool>> deleteResultFile(
    int brandId,
    int appointmentId,
    int fileId,
  ) async {
    AppLogger.info(
      _tag,
      'deleteResultFile() — brandId: $brandId, appointmentId: $appointmentId, fileId: $fileId',
    );
    final result = await ApiClient.instance.delete(
      ApiConstants.brandAppointmentResultFileById(
          brandId, appointmentId, fileId),
      requiresAuth: true,
    );
    return switch (result) {
      ApiSuccess() => const ApiSuccess(true),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

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

  ApiResult<AppointmentResultFilesResponseModel> _mapToResultFiles(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(AppointmentResultFilesResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse result files: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }

  ApiResult<AppointmentResultFileDownloadResponseModel> _mapToDownloadResponse(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(
          AppointmentResultFileDownloadResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse download response: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }
}
