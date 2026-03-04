import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_constants.dart';
import '../core/utils/logger.dart';

class OnboardingViewModel extends ChangeNotifier {
  static const String _tag = 'OnboardingViewModel';

  int _currentPage = 0;
  final int totalPages = 3;

  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == totalPages - 1;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPage() {
    if (!isLastPage) {
      _currentPage++;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    AppLogger.info(_tag, 'Onboarding completed.');
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }
}
