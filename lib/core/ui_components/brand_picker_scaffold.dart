import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/brand_model.dart';
import '../../viewmodels/home_view_model.dart';
import 'main_app_bar.dart';

/// Reusable screen shown when a bottom-tab view requires a brand selection.
/// Reads [HomeViewModel] from the widget tree and shows the brands list.
/// [onBrandSelected] is called with the tapped brand.
class BrandPickerScaffold extends StatelessWidget {
  final String title;
  final void Function(BrandModel brand) onBrandSelected;

  const BrandPickerScaffold({
    super.key,
    required this.title,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      appBar: MainAppBar(title: title),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final brands = vm.brandsResponse?.data ?? [];

          if (brands.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingPage),
                child: Text(
                  l10n.homeNoMemberships,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeTokens.fontLG,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(SizeTokens.paddingPage),
            itemCount: brands.length,
            separatorBuilder: (_, __) => SizedBox(height: SizeTokens.spaceMD),
            itemBuilder: (_, i) {
              final brand = brands[i];
              return Material(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
                child: InkWell(
                  borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
                  onTap: () => onBrandSelected(brand),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingXL,
                      vertical: SizeTokens.paddingLG,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            brand.name ?? '—',
                            style: TextStyle(
                              fontSize: SizeTokens.fontLG,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: SizeTokens.iconMD,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
