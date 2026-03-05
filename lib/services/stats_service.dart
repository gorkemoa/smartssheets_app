import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/stats_monthly_response_model.dart';
import '../models/stats_summary_model.dart';

class StatsService {
  StatsService._();

  static final StatsService instance = StatsService._();

  static const String _tag = 'StatsService';

  // GET /brands/{id}/stats/summary
  Future<ApiResult<StatsSummaryModel>> getStatsSummary(int brandId) async {
    AppLogger.info(_tag, 'getStatsSummary() called — brandId: $brandId');

    final result = await ApiClient.instance.get(
      ApiConstants.brandStatsSummary(brandId),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToStatsSummary(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // GET /brands/{id}/stats/monthly?months=12
  Future<ApiResult<StatsMonthlyResponseModel>> getStatsMonthly(
    int brandId, {
    int months = 12,
  }) async {
    AppLogger.info(
      _tag,
      'getStatsMonthly() called — brandId: $brandId, months: $months',
    );

    final result = await ApiClient.instance.get(
      ApiConstants.brandStatsMonthly(brandId),
      requiresAuth: true,
      queryParams: {'months': months.toString()},
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToStatsMonthly(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  ApiResult<StatsSummaryModel> _mapToStatsSummary(
    Map<String, dynamic> data,
  ) {
    try {
      final model = StatsSummaryModel.fromJson(data);
      AppLogger.info(
        _tag,
        'Stats summary parsed. total_appointments: ${model.totalAppointments}',
      );
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToStatsSummary', e);
      return const ApiFailure(
        ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }

  ApiResult<StatsMonthlyResponseModel> _mapToStatsMonthly(
    Map<String, dynamic> data,
  ) {
    try {
      final model = StatsMonthlyResponseModel.fromJson(data);
      AppLogger.info(
        _tag,
        'Stats monthly parsed. count: ${model.data?.length ?? 0}',
      );
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToStatsMonthly', e);
      return const ApiFailure(
        ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }
}
