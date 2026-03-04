import 'package:flutter/material.dart';
import 'package:smartssheets_app/l10n/strings.dart';
import 'package:provider/provider.dart';
import 'package:smartssheets_app/app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/onboarding_view_model.dart';
import '../login/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin(BuildContext context) {
    final vm = context.read<OnboardingViewModel>();
    vm.completeOnboarding().then((_) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    });
  }

  void _onNext(BuildContext context, OnboardingViewModel vm) {
    if (vm.isLastPage) {
      _goToLogin(context);
    } else {
      _pageController.animateToPage(
        vm.currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, vm, _) {
          // Pre-compute overlay height so pages can add matching bottom padding.
          final overlayContentHeight = 3 +
              SizeTokens.spaceLG +
              SizeTokens.buttonHeight +
              SizeTokens.spaceXXXL;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // ── Sliding pages (image + text only, no controls) ──
                PageView(
                  controller: _pageController,
                  onPageChanged: vm.onPageChanged,
                  children: [
                    _SplashPage(bottomReserve: overlayContentHeight),
                    _ContentPage(
                      imagePath: 'assets/onb/pexels-ian-panelo-7059605.jpg',
                      text: AppStrings.of(context).onboardingPage2Text,
                      bottomReserve: overlayContentHeight,
                    ),
                    _ContentPage(
                      imagePath: 'assets/onb/pexels-leeloothefirst-5417662.jpg',
                      text: AppStrings.of(context).onboardingPage3Text,
                      bottomReserve: overlayContentHeight,
                    ),
                  ],
                ),

                // ── Fixed overlay: indicator + button (stays put on swipe) ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        SizeTokens.paddingPage,
                        0,
                        SizeTokens.paddingPage,
                        SizeTokens.spaceXXXL,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LineIndicator(
                            total: vm.totalPages,
                            current: vm.currentPage,
                          ),
                          SizedBox(height: SizeTokens.spaceLG),
                          SizedBox(
                            width: double.infinity,
                            height: SizeTokens.buttonHeight,
                            child: ElevatedButton(
                              onPressed: () => _onNext(context, vm),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      SizeTokens.radiusCircle),
                                ),
                              ),
                              child: Text(
                                vm.currentPage == 0
                                    ? AppStrings.of(context).onboardingBtnExplore
                                    : vm.isLastPage
                                        ? AppStrings.of(context).onboardingBtnGetStarted
                                        : AppStrings.of(context).onboardingBtnContinue,
                                style: TextStyle(
                                  fontSize: SizeTokens.fontLG,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash Page (screen 1 — full-bleed image with branding)
// ─────────────────────────────────────────────────────────────────────────────
class _SplashPage extends StatelessWidget {
  final double bottomReserve;

  const _SplashPage({required this.bottomReserve});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/onb/pexels-scottwebb-174054.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x44000000),
                Colors.transparent,
                Color(0xF0000000),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingPage),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeTokens.spaceLG),
                Image.asset(
                  'assets/smartmetrics-logo.png',
                  width: SizeTokens.logoSize * 2.5,
                  height: SizeTokens.logoSize * 2.5,
                  color: Colors.white,
                ),
                const Spacer(),
                Text(
                  AppStrings.of(context).onboardingSplashTitle,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXXL * 1.3,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                // Reserve space so text never hides under the fixed overlay.
                SizedBox(height: bottomReserve),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content Page (screens 2-3 — full-bleed image, text bottom, line indicator)
// ─────────────────────────────────────────────────────────────────────────────
class _ContentPage extends StatelessWidget {
  final String imagePath;
  final String text;
  final double bottomReserve;

  const _ContentPage({
    required this.imagePath,
    required this.text,
    required this.bottomReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imagePath, fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x22000000),
                Colors.transparent,
                Color(0xF0000000),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingPage),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXXL * 1.3,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                // Reserve space so text never hides under the fixed overlay.
                SizedBox(height: bottomReserve),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Line Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _LineIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _LineIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index == current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(right: index < total - 1 ? SizeTokens.spaceXS : 0),
            height: 3,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blob Clippers
// ─────────────────────────────────────────────────────────────────────────────
