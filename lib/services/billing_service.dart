import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/billing_plans_response_model.dart';
import '../models/billing_status_model.dart';

class BillingService {
  BillingService._();

  static final BillingService instance = BillingService._();

  static const String _tag = 'BillingService';

  // GET /brands/{id}/billing/plans
  Future<ApiResult<BillingPlansResponseModel>> getPlans(int brandId) async {
    AppLogger.info(_tag, 'getPlans() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandBillingPlans(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToPlans(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // GET /brands/{id}/billing/status
  Future<ApiResult<BillingStatusModel>> getBillingStatus(int brandId) async {
    AppLogger.info(_tag, 'getBillingStatus() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandBillingStatus(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToStatus(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  ApiResult<BillingPlansResponseModel> _mapToPlans(
    Map<String, dynamic> data,
  ) {
    try {
      final model = BillingPlansResponseModel.fromJson(data);
      AppLogger.info(_tag, 'Billing plans parsed. count: ${model.data?.length}');
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToPlans', e);
      return const ApiFailure(
        ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }

  ApiResult<BillingStatusModel> _mapToStatus(
    Map<String, dynamic> data,
  ) {
    try {
      final model = BillingStatusModel.fromJson(data);
      AppLogger.info(_tag, 'Billing status parsed. status: ${model.status}');
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToStatus', e);
      return const ApiFailure(
        ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }
}
