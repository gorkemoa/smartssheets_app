import 'package:flutter/foundation.dart';
import '../core/network/api_result.dart';
import '../models/brands_response_model.dart';
import '../models/create_brand_request_model.dart';
import '../models/me_response_model.dart';
import '../models/stats_monthly_response_model.dart';
import '../models/stats_summary_model.dart';
import '../models/update_brand_request_model.dart';
import '../services/auth_service.dart';
import '../services/brand_service.dart';
import '../services/stats_service.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  MeResponseModel? _meResponse;
  BrandsResponseModel? _brandsResponse;
  bool _isSubmitting = false;
  String? _submitError;
  final Map<int, StatsSummaryModel> _statsSummaryMap = {};
  final Map<int, StatsMonthlyResponseModel> _statsMonthlyMap = {};
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MeResponseModel? get meResponse => _meResponse;
  BrandsResponseModel? get brandsResponse => _brandsResponse;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  Map<int, StatsSummaryModel> get statsSummaryMap =>
      Map.unmodifiable(_statsSummaryMap);
  Map<int, StatsMonthlyResponseModel> get statsMonthlyMap =>
      Map.unmodifiable(_statsMonthlyMap);
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
    _setLoading(true);
    _setError(null);
    await Future.wait([_fetchMe(), _fetchBrands()]);
    await _fetchStatsForAllBrands();
    _setLoading(false);
  }

  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);
    await Future.wait([_fetchMe(), _fetchBrands()]);
    await _fetchStatsForAllBrands();
    _setLoading(false);
  }

  Future<void> onRetry() async {
    await init();
  }

  // Brands list has no pagination — method satisfies ViewModel contract
  Future<void> loadMore() async {}

  Future<void> _fetchMe() async {
    final result = await AuthService.instance.me();
    switch (result) {
      case ApiSuccess(:final data):
        _meResponse = data;
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<void> _fetchBrands() async {
    final result = await BrandService.instance.brands();
    switch (result) {
      case ApiSuccess(:final data):
        _brandsResponse = data;
        notifyListeners();
      case ApiFailure(:final exception):
        _setError(exception.message);
    }
  }

  Future<void> _fetchStatsForAllBrands() async {
    final brands = _brandsResponse?.data;
    if (brands == null || brands.isEmpty) return;
    await Future.wait(
      brands.where((b) => b.id != null).map((b) async {
        final id = b.id!;
        await Future.wait([
          _fetchStatsSummary(id),
          _fetchStatsMonthly(id),
        ]);
      }),
    );
  }

  Future<void> _fetchStatsSummary(int brandId) async {
    final result = await StatsService.instance.getStatsSummary(brandId);
    if (result case ApiSuccess(:final data)) {
      _statsSummaryMap[brandId] = data;
      notifyListeners();
    }
    // Stats errors are non-fatal — home still renders without stats
  }

  Future<void> _fetchStatsMonthly(int brandId) async {
    final result = await StatsService.instance.getStatsMonthly(brandId);
    if (result case ApiSuccess(:final data)) {
      _statsMonthlyMap[brandId] = data;
      notifyListeners();
    }
    // Stats errors are non-fatal — home still renders without stats
  }

  Future<bool> createBrand({required String name, String? timezone}) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await BrandService.instance.createBrand(
      CreateBrandRequestModel(
        name: name,
        timezone: timezone?.isEmpty == true ? null : timezone,
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchBrands();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateBrand(int id, {String? name, String? timezone}) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final result = await BrandService.instance.updateBrand(
      id,
      UpdateBrandRequestModel(
        name: name,
        timezone: timezone?.isEmpty == true ? null : timezone,
      ),
    );

    _isSubmitting = false;
    switch (result) {
      case ApiSuccess():
        await _fetchBrands();
        notifyListeners();
        return true;
      case ApiFailure(:final exception):
        _submitError = exception.message;
        notifyListeners();
        return false;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
  }
}
