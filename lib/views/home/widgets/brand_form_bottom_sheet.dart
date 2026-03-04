import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/brand_model.dart';
import '../../../viewmodels/home_view_model.dart';

class BrandFormBottomSheet extends StatefulWidget {
  final BrandModel? brand;

  const BrandFormBottomSheet({super.key, this.brand});

  bool get _isEditing => brand != null;

  static Future<bool?> show(BuildContext context, {BrandModel? brand}) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: BrandFormBottomSheet(brand: brand),
      ),
    );
  }

  @override
  State<BrandFormBottomSheet> createState() => _BrandFormBottomSheetState();
}

class _BrandFormBottomSheetState extends State<BrandFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _timezoneController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.brand?.name ?? '');
    _timezoneController =
        TextEditingController(text: widget.brand?.timezone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(HomeViewModel viewModel, AppStrings l10n) async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (widget._isEditing) {
      success = await viewModel.updateBrand(
        widget.brand!.id!,
        name: _nameController.text.trim(),
        timezone: _timezoneController.text.trim(),
      );
    } else {
      success = await viewModel.createBrand(
        name: _nameController.text.trim(),
        timezone: _timezoneController.text.trim(),
      );
    }

    if (!mounted) return;
    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);
    final viewModel = context.watch<HomeViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeTokens.radiusXL),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingPage,
          SizeTokens.spaceXL,
          SizeTokens.paddingPage,
          SizeTokens.spaceXXXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Center(
              child: Container(
                width: SizeConfig.w(40),
                height: SizeConfig.h(4),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.spaceXL),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              widget._isEditing ? l10n.homeBrandEditTitle : l10n.homeBrandCreateTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontXXL,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: SizeTokens.spaceXL),

            // ── Form ──────────────────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _BrandTextField(
                    controller: _nameController,
                    label: l10n.homeBrandNameLabel,
                    hint: l10n.homeBrandNameHint,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.homeBrandNameEmpty
                        : null,
                  ),
                  SizedBox(height: SizeTokens.spaceMD),
                  _BrandTextField(
                    controller: _timezoneController,
                    label: l10n.homeBrandTimezoneLabel,
                    hint: l10n.homeBrandTimezoneHint,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onSubmit(
                      context.read<HomeViewModel>(),
                      l10n,
                    ),
                  ),
                ],
              ),
            ),

            // ── Submit error ──────────────────────────────────────────────
            if (viewModel.submitError != null) ...[
              SizedBox(height: SizeTokens.spaceMD),
              Text(
                viewModel.submitError!,
                style: TextStyle(
                  fontSize: SizeTokens.fontSM,
                  color: AppTheme.error,
                ),
              ),
            ],
            SizedBox(height: SizeTokens.spaceXXL),

            // ── Submit button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: SizeTokens.buttonHeight,
              child: ElevatedButton(
                onPressed: viewModel.isSubmitting
                    ? null
                    : () => _onSubmit(viewModel, l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SizeTokens.radiusLG),
                  ),
                ),
                child: viewModel.isSubmitting
                    ? SizedBox(
                        width: SizeTokens.iconMD,
                        height: SizeTokens.iconMD,
                        child: CircularProgressIndicator(
                          strokeWidth: SizeConfig.w(2),
                          color: AppTheme.textOnPrimary,
                        ),
                      )
                    : Text(
                        widget._isEditing
                            ? l10n.homeBrandSaveButton
                            : l10n.homeBrandCreateButton,
                        style: TextStyle(
                          fontSize: SizeTokens.fontLG,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable text field for brand form (used only within this screen)
// ─────────────────────────────────────────────────────────────────────────────

class _BrandTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _BrandTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: TextStyle(
        fontSize: SizeTokens.fontLG,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.inputFill,
        labelStyle: TextStyle(
          fontSize: SizeTokens.fontMD,
          color: AppTheme.textSecondary,
        ),
        hintStyle: TextStyle(
          fontSize: SizeTokens.fontMD,
          color: AppTheme.textHint,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingSM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.borderFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
      ),
    );
  }
}
