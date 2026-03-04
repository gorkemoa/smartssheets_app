import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/create_invitation_request_model.dart';
import '../models/invitation_detail_response_model.dart';
import '../models/invitations_response_model.dart';

class InvitationService {
  InvitationService._();

  static final InvitationService instance = InvitationService._();

  static const String _tag = 'InvitationService';

  // GET /brands/{brandId}/invitations
  Future<ApiResult<InvitationsResponseModel>> invitations(int brandId) async {
    AppLogger.info(_tag, 'invitations() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandInvitations(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToInvitationsResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/invitations
  Future<ApiResult<InvitationDetailResponseModel>> createInvitation(
    int brandId,
    CreateInvitationRequestModel request,
  ) async {
    AppLogger.info(_tag, 'createInvitation() called — brandId: $brandId');

    final result = await ApiClient.instance.post(
      ApiConstants.brandInvitations(brandId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToInvitationDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/invitations/{invId}/resend
  Future<ApiResult<Map<String, dynamic>>> resendInvitation(
    int brandId,
    int invitationId,
  ) async {
    AppLogger.info(
      _tag,
      'resendInvitation() called — brandId: $brandId, invId: $invitationId',
    );

    final result = await ApiClient.instance.post(
      ApiConstants.brandInvitationResend(brandId, invitationId),
      body: {},
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // DELETE /brands/{brandId}/invitations/{invId}
  Future<ApiResult<Map<String, dynamic>>> deleteInvitation(
    int brandId,
    int invitationId,
  ) async {
    AppLogger.info(
      _tag,
      'deleteInvitation() called — brandId: $brandId, invId: $invitationId',
    );

    final result = await ApiClient.instance.delete(
      ApiConstants.brandInvitationById(brandId, invitationId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  ApiResult<InvitationsResponseModel> _mapToInvitationsResponse(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(InvitationsResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse invitations response: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }

  ApiResult<InvitationDetailResponseModel> _mapToInvitationDetail(
    Map<String, dynamic> data,
  ) {
    try {
      return ApiSuccess(InvitationDetailResponseModel.fromJson(data));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse invitation detail: $e');
      return ApiFailure(ApiException(
        type: ApiExceptionType.parseError,
        message: e.toString(),
      ));
    }
  }
}
