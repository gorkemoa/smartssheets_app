import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/brand_detail_response_model.dart';
import '../models/brands_response_model.dart';
import '../models/create_brand_request_model.dart';
import '../models/update_brand_request_model.dart';

class BrandService {
  BrandService._();

  static final BrandService instance = BrandService._();

  static const String _tag = 'BrandService';

  // GET /brands
  Future<ApiResult<BrandsResponseModel>> brands() async {
    AppLogger.info(_tag, 'brands() called');

    final result = await ApiClient.instance.get(
      ApiConstants.brands,
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToBrandsResponse(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // POST /brands
  Future<ApiResult<BrandDetailResponseModel>> createBrand(
    CreateBrandRequestModel request,
  ) async {
    AppLogger.info(_tag, 'createBrand() called — name: ${request.name}');

    final result = await ApiClient.instance.post(
      ApiConstants.brands,
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToBrandDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // GET /brands/{id}
  Future<ApiResult<BrandDetailResponseModel>> getBrandById(int id) async {
    AppLogger.info(_tag, 'getBrandById() called — id: $id');

    final result = await ApiClient.instance.get(
      ApiConstants.brandById(id),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToBrandDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  // PATCH /brands/{id}
  Future<ApiResult<BrandDetailResponseModel>> updateBrand(
    int id,
    UpdateBrandRequestModel request,
  ) async {
    AppLogger.info(_tag, 'updateBrand() called — id: $id');

    final result = await ApiClient.instance.patch(
      ApiConstants.brandById(id),
      body: request.toJson(),
      requiresAuth: true,
    );

    return switch (result) {
      ApiSuccess(:final data) => _mapToBrandDetail(data),
      ApiFailure(:final exception) => ApiFailure(exception),
    };
  }

  ApiResult<BrandsResponseModel> _mapToBrandsResponse(
    Map<String, dynamic> data,
  ) {
    try {
      final model = BrandsResponseModel.fromJson(data);
      AppLogger.info(
        _tag,
        'Brands response parsed. count: ${model.data?.length ?? 0}',
      );
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToBrandsResponse', e);
      return ApiFailure(
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }

  ApiResult<BrandDetailResponseModel> _mapToBrandDetail(
    Map<String, dynamic> data,
  ) {
    try {
      final model = BrandDetailResponseModel.fromJson(data);
      AppLogger.info(
        _tag,
        'Brand detail response parsed. id: ${model.data?.id}',
      );
      return ApiSuccess(model);
    } catch (e) {
      AppLogger.error(_tag, 'Parse error in _mapToBrandDetail', e);
      return ApiFailure(
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Veri işlenirken bir hata oluştu.',
        ),
      );
    }
  }
}
