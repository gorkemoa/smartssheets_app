import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/appointment_field_detail_response_model.dart';
import '../models/appointment_fields_response_model.dart';
import '../models/create_appointment_field_request_model.dart';
import '../models/update_appointment_field_request_model.dart';

class AppointmentFieldService {
  AppointmentFieldService._();

  static final AppointmentFieldService instance = AppointmentFieldService._();

  static const String _tag = 'AppointmentFieldService';

  // GET /brands/{brandId}/settings/appointment-fields
  Future<ApiResult<AppointmentFieldsResponseModel>> fields(
      int brandId) async {
    AppLogger.info(_tag, 'fields() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandAppointmentFields(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToFieldsResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/settings/appointment-fields
  Future<ApiResult<AppointmentFieldDetailResponseModel>> createField(
    int brandId,
    CreateAppointmentFieldRequestModel request,
  ) async {
    AppLogger.info(_tag, 'createField() called — brandId: $brandId');

    final result = await ApiClient.instance.post(
      ApiConstants.brandAppointmentFields(brandId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToFieldDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // PATCH /brands/{brandId}/settings/appointment-fields/{fieldId}
  Future<ApiResult<AppointmentFieldDetailResponseModel>> updateField(
    int brandId,
    int fieldId,
    UpdateAppointmentFieldRequestModel request,
  ) async {
    AppLogger.info(
      _tag,
      'updateField() called — brandId: $brandId, fieldId: $fieldId',
    );

    final result = await ApiClient.instance.patch(
      ApiConstants.brandAppointmentFieldById(brandId, fieldId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToFieldDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // DELETE /brands/{brandId}/settings/appointment-fields/{fieldId}
  Future<ApiResult<Map<String, dynamic>>> deleteField(
    int brandId,
    int fieldId,
  ) async {
    AppLogger.info(
      _tag,
      'deleteField() called — brandId: $brandId, fieldId: $fieldId',
    );

    final result = await ApiClient.instance.delete(
      ApiConstants.brandAppointmentFieldById(brandId, fieldId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  ApiResult<AppointmentFieldsResponseModel> _mapToFieldsResponse(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(AppointmentFieldsResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse fields response: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }

  ApiResult<AppointmentFieldDetailResponseModel> _mapToFieldDetail(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(AppointmentFieldDetailResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse field detail: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }
}
