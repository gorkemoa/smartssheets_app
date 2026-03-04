import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/appointment_status_detail_response_model.dart';
import '../models/appointment_statuses_response_model.dart';
import '../models/create_appointment_status_request_model.dart';
import '../models/update_appointment_status_request_model.dart';

class AppointmentStatusService {
  AppointmentStatusService._();

  static final AppointmentStatusService instance =
      AppointmentStatusService._();

  static const String _tag = 'AppointmentStatusService';

  // GET /brands/{brandId}/statuses
  Future<ApiResult<AppointmentStatusesResponseModel>> statuses(
      int brandId) async {
    AppLogger.info(_tag, 'statuses() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandStatuses(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToStatusesResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/statuses
  Future<ApiResult<AppointmentStatusDetailResponseModel>> createStatus(
    int brandId,
    CreateAppointmentStatusRequestModel request,
  ) async {
    AppLogger.info(_tag, 'createStatus() called — brandId: $brandId');

    final result = await ApiClient.instance.post(
      ApiConstants.brandStatuses(brandId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToStatusDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // PATCH /brands/{brandId}/statuses/{statusId}
  Future<ApiResult<AppointmentStatusDetailResponseModel>> updateStatus(
    int brandId,
    int statusId,
    UpdateAppointmentStatusRequestModel request,
  ) async {
    AppLogger.info(
      _tag,
      'updateStatus() called — brandId: $brandId, statusId: $statusId',
    );

    final result = await ApiClient.instance.patch(
      ApiConstants.brandStatusById(brandId, statusId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToStatusDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // DELETE /brands/{brandId}/statuses/{statusId}
  Future<ApiResult<Map<String, dynamic>>> deleteStatus(
    int brandId,
    int statusId,
  ) async {
    AppLogger.info(
      _tag,
      'deleteStatus() called — brandId: $brandId, statusId: $statusId',
    );

    final result = await ApiClient.instance.delete(
      ApiConstants.brandStatusById(brandId, statusId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  ApiResult<AppointmentStatusesResponseModel> _mapToStatusesResponse(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(AppointmentStatusesResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse statuses response: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }

  ApiResult<AppointmentStatusDetailResponseModel> _mapToStatusDetail(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(AppointmentStatusDetailResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse status detail: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }
}
