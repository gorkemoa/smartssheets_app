import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/create_member_request_model.dart';
import '../models/member_detail_response_model.dart';
import '../models/members_response_model.dart';
import '../models/update_member_request_model.dart';

class MemberService {
  MemberService._();

  static final MemberService instance = MemberService._();

  static const String _tag = 'MemberService';

  // GET /brands/{brandId}/members
  Future<ApiResult<MembersResponseModel>> members(int brandId) async {
    AppLogger.info(_tag, 'members() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandMembers(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToMembersResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands/{brandId}/members
  Future<ApiResult<MemberDetailResponseModel>> createMember(
    int brandId,
    CreateMemberRequestModel request,
  ) async {
    AppLogger.info(_tag, 'createMember() called — brandId: $brandId');

    final result = await ApiClient.instance.post(
      ApiConstants.brandMembers(brandId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToMemberDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // PATCH /brands/{brandId}/members/{memberId}
  Future<ApiResult<MemberDetailResponseModel>> updateMember(
    int brandId,
    int memberId,
    UpdateMemberRequestModel request,
  ) async {
    AppLogger.info(
      _tag,
      'updateMember() called — brandId: $brandId, memberId: $memberId',
    );

    final result = await ApiClient.instance.patch(
      ApiConstants.brandMemberById(brandId, memberId),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToMemberDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // DELETE /brands/{brandId}/members/{memberId}
  Future<ApiResult<Map<String, dynamic>>> deleteMember(
    int brandId,
    int memberId,
  ) async {
    AppLogger.info(
      _tag,
      'deleteMember() called — brandId: $brandId, memberId: $memberId',
    );

    return ApiClient.instance.delete(
      ApiConstants.brandMemberById(brandId, memberId),
      requiresAuth: true,
    );
  }

  ApiResult<MembersResponseModel> _mapToMembersResponse(
    Map<String, dynamic> data,
  ) {
    try {
      final model = MembersResponseModel.fromJson(data);
      AppLogger.info(
        _tag,
        'Members response parsed. count: ${model.data?.length ?? 0}',
      );
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToMembersResponse', e);
      return ApiFailure(
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }

  ApiResult<MemberDetailResponseModel> _mapToMemberDetail(
    Map<String, dynamic> data,
  ) {
    try {
      final model = MemberDetailResponseModel.fromJson(data);
      AppLogger.info(
        _tag,
        'Member detail response parsed. id: ${model.data?.id}',
      );
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToMemberDetail', e);
      return ApiFailure(
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }
}

