import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../responsive/size_config.dart';
import '../responsive/size_tokens.dart';

/// Onaylı paylaşılan widget — tüm ana ekranlar tarafından kullanılır.
/// Bkz. README: ONAYLANAN ORTAK WİDGETLAR
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomBarItem> items;

  /// Orta indeksteki item FAB olarak render edilir.
  final int centerIndex;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerIndex = 2,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = SizeConfig.h(72);
    final fabSize = SizeConfig.r(56);
    // Total bar height grows to hold safe area padding at the bottom
    final totalBarHeight = barHeight + bottomPadding;

    return SizedBox(
      height: totalBarHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Bar background ─────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: totalBarHeight,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SizeTokens.radiusXL),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: SizeConfig.r(24),
                    offset: Offset(0, SizeConfig.h(-4)),
                  ),
                ],
              ),
              // Items only occupy barHeight — safe area stays empty below
              child: Column(
                children: [
                  SizedBox(
                    height: barHeight,
                    child: Row(
                      children: List.generate(items.length, (i) {
                        if (i == centerIndex) {
                          // Space for FAB
                          return Expanded(child: SizedBox(width: fabSize));
                        }
                        return Expanded(
                          child: _BarItem(
                            item: items[i],
                            isActive: i == currentIndex,
                            onTap: () => onTap(i),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Safe area gap — transparent, keeps home indicator clear
                  SizedBox(height: bottomPadding),
                ],
              ),
            ),
          ),

          // ── Center FAB ─────────────────────────────────────────────────────
          Positioned(
            bottom: (barHeight / 2) + bottomPadding,
            child: GestureDetector(
              onTap: () => onTap(centerIndex),
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: SizeConfig.r(16),
                      offset: Offset(0, SizeConfig.h(6)),
                    ),
                  ],
                ),
                child: Icon(
                  items[centerIndex].activeIcon,
                  color: AppTheme.textOnPrimary,
                  size: SizeTokens.iconLG,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bar Item (non-center)
// ─────────────────────────────────────────────────────────────────────────────

class _BarItem extends StatelessWidget {
  final AppBottomBarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _BarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : AppTheme.textHint;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Active indicator line ─────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? SizeConfig.w(24) : 0,
            height: SizeConfig.h(3),
            margin: EdgeInsets.only(bottom: SizeTokens.spaceXXS),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
            ),
          ),
          // ── Icon ─────────────────────────────────────────
          Icon(
            isActive ? item.activeIcon : item.inactiveIcon,
            size: SizeTokens.iconLG,
            color: color,
          ),
          SizedBox(height: SizeTokens.spaceXXS),
          // ── Label ────────────────────────────────────────
          Text(
            item.label,
            style: TextStyle(
              fontSize: SizeTokens.fontXS,
              fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model for each tab item
// ─────────────────────────────────────────────────────────────────────────────

class AppBottomBarItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const AppBottomBarItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}
