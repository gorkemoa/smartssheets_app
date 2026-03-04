import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/appointment_status_model.dart';
import '../../../viewmodels/appointment_statuses_view_model.dart';

enum StatusFormResult { created, updated, deleted }

class AppointmentStatusFormBottomSheet extends StatefulWidget {
  final AppointmentStatusModel? status;

  const AppointmentStatusFormBottomSheet({super.key, this.status});

  bool get _isEditing => status != null;

  static Future<StatusFormResult?> show(
    BuildContext context, {
    AppointmentStatusModel? status,
  }) {
    final viewModel =
        Provider.of<AppointmentStatusesViewModel>(context, listen: false);
    return showModalBottomSheet<StatusFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: AppointmentStatusFormBottomSheet(status: status),
      ),
    );
  }

  @override
  State<AppointmentStatusFormBottomSheet> createState() =>
      _AppointmentStatusFormBottomSheetState();
}

class _AppointmentStatusFormBottomSheetState
    extends State<AppointmentStatusFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sortOrderController;

  late Color _pickedColor;
  late String _selectedStatusType;
  late bool _isDefault;
  late bool _isActive;

  static const List<String> _statusTypes = ['neutral', 'active', 'invalid'];

  Color _parseHex(String? hex) {
    try {
      final h = (hex ?? '#4C6EF5').replaceFirst('#', '');
      return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) {
      return const Color(0xFF4C6EF5);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.r.round().toRadixString(16).padLeft(2, '0')}'
        '${color.g.round().toRadixString(16).padLeft(2, '0')}'
        '${color.b.round().toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    final s = widget.status;
    _nameController = TextEditingController(text: s?.name ?? '');
    _sortOrderController =
        TextEditingController(text: s?.sortOrder?.toString() ?? '');
    _pickedColor = _parseHex(s?.color);
    _selectedStatusType = s?.statusType ?? 'neutral';
    _isDefault = s?.isDefault ?? false;
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _openColorPicker(BuildContext context) async {
    Color tempColor = _pickedColor;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.of(context).statusFormColorLabel,
          style: TextStyle(
            fontSize: SizeTokens.fontLG,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _pickedColor = tempColor);
    }
  }

  Future<void> _onSubmit(
    AppointmentStatusesViewModel viewModel,
    AppStrings l10n,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 1;
    final colorHex = _colorToHex(_pickedColor);
    bool success;

    if (widget._isEditing) {
      success = await viewModel.updateStatus(
        widget.status!.id!,
        name: _nameController.text.trim(),
        color: colorHex,
        sortOrder: sortOrder,
        isDefault: _isDefault,
        isActive: _isActive,
        statusType: _selectedStatusType,
      );
      if (success && mounted) {
        Navigator.of(context).pop(StatusFormResult.updated);
      }
    } else {
      success = await viewModel.createStatus(
        name: _nameController.text.trim(),
        color: colorHex,
        sortOrder: sortOrder,
        isDefault: _isDefault,
        isActive: _isActive,
        statusType: _selectedStatusType,
      );
      if (success && mounted) {
        Navigator.of(context).pop(StatusFormResult.created);
      }
    }
  }

  Future<void> _onDelete(
    AppointmentStatusesViewModel viewModel,
    AppStrings l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.statusFormDeleteConfirmTitle),
        content: Text(l10n.statusFormDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.statusFormDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.statusFormDeleteConfirm,
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await viewModel.deleteStatus(widget.status!.id!);
    if (success && mounted) {
      Navigator.of(context).pop(StatusFormResult.deleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Consumer<AppointmentStatusesViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXL),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.paddingXL,
                SizeTokens.paddingLG,
                SizeTokens.paddingXL,
                SizeTokens.paddingXL,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Handle ─────────────────────────────────────
                    Center(
                      child: Container(
                        width: SizeConfig.w(10),
                        height: SizeTokens.spaceXS,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusCircle),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Title ──────────────────────────────────────
                    Text(
                      widget._isEditing
                          ? l10n.statusFormEditTitle
                          : l10n.statusFormCreateTitle,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXL,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Name field ─────────────────────────────────
                    _FieldLabel(label: l10n.statusFormNameLabel),
                    SizedBox(height: SizeTokens.spaceXS),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.statusFormNameHint,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.validatorNameEmpty;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    // ── Color picker swatch  ───────────────────────
                    _FieldLabel(label: l10n.statusFormColorLabel),
                    SizedBox(height: SizeTokens.spaceXS),
                    GestureDetector(
                      onTap: () => _openColorPicker(context),
                      child: Container(
                        height: SizeTokens.avatarLG,
                        decoration: BoxDecoration(
                          color: _pickedColor,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusMD),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.colorize_rounded,
                              color: _pickedColor.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white70,
                              size: SizeTokens.iconMD,
                            ),
                            SizedBox(width: SizeTokens.spaceXS),
                            Text(
                              _colorToHex(_pickedColor),
                              style: TextStyle(
                                fontSize: SizeTokens.fontMD,
                                fontWeight: FontWeight.w600,
                                color: _pickedColor.computeLuminance() > 0.5
                                    ? Colors.black54
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    // ── Sort order ─────────────────────────────────
                    _FieldLabel(label: l10n.statusFormSortOrderLabel),
                    SizedBox(height: SizeTokens.spaceXS),
                    TextFormField(
                      controller: _sortOrderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.statusFormSortOrderHint,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    // ── Status type dropdown ───────────────────────
                    _FieldLabel(label: l10n.statusFormStatusTypeLabel),
                    SizedBox(height: SizeTokens.spaceXS),
                    DropdownButtonFormField<String>(
                      value: _selectedStatusType,
                      decoration: const InputDecoration(),
                      items: _statusTypes.map((t) {
                        final label = switch (t) {
                          'active' => l10n.statusTypeActive,
                          'invalid' => l10n.statusTypeInvalid,
                          _ => l10n.statusTypeNeutral,
                        };
                        return DropdownMenuItem(value: t, child: Text(label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedStatusType = v);
                        }
                      },
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    // ── Toggles ────────────────────────────────────
                    _ToggleRow(
                      label: l10n.statusFormIsDefaultLabel,
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),
                    _ToggleRow(
                      label: l10n.statusFormIsActiveLabel,
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    // ── Submit error ───────────────────────────────
                    if (viewModel.submitError != null) ...[
                      SizedBox(height: SizeTokens.spaceMD),
                      Container(
                        padding: EdgeInsets.all(SizeTokens.paddingMD),
                        decoration: BoxDecoration(
                          color: AppTheme.errorLight,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusMD),
                          border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: AppTheme.error,
                                size: SizeTokens.iconMD),
                            SizedBox(width: SizeTokens.spaceXS),
                            Expanded(
                              child: Text(
                                viewModel.submitError!,
                                style: TextStyle(
                                  fontSize: SizeTokens.fontSM,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: SizeTokens.spaceLG),
                    // ── Submit button ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isSubmitting
                            ? null
                            : () => _onSubmit(viewModel, l10n),
                        child: viewModel.isSubmitting
                            ? SizedBox(
                                width: SizeTokens.iconMD,
                                height: SizeTokens.iconMD,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Text(
                                widget._isEditing
                                    ? l10n.statusFormSaveButton
                                    : l10n.statusFormCreateButton,
                              ),
                      ),
                    ),
                    // ── Delete button (edit only) ──────────────────
                    if (widget._isEditing) ...[
                      SizedBox(height: SizeTokens.spaceSM),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: viewModel.isSubmitting
                              ? null
                              : () => _onDelete(viewModel, l10n),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: BorderSide(
                                color: AppTheme.error.withValues(alpha: 0.5)),
                          ),
                          child: Text(l10n.statusFormDeleteButton),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: SizeTokens.fontSM,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
      ],
    );
  }
}
