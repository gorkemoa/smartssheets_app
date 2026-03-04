import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/appointment_field_model.dart';
import '../../../models/appointment_field_option_model.dart';
import '../../../models/appointment_field_validations_model.dart';
import '../../../viewmodels/appointment_fields_view_model.dart';

enum FieldFormResult { created, updated, deleted }

class AppointmentFieldFormBottomSheet extends StatefulWidget {
  final AppointmentFieldModel? field;

  const AppointmentFieldFormBottomSheet({super.key, this.field});

  bool get _isEditing => field != null;

  static Future<FieldFormResult?> show(
    BuildContext context, {
    AppointmentFieldModel? field,
  }) {
    final viewModel =
        Provider.of<AppointmentFieldsViewModel>(context, listen: false);
    return showModalBottomSheet<FieldFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: AppointmentFieldFormBottomSheet(field: field),
      ),
    );
  }

  @override
  State<AppointmentFieldFormBottomSheet> createState() =>
      _AppointmentFieldFormBottomSheetState();
}

class _AppointmentFieldFormBottomSheetState
    extends State<AppointmentFieldFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keyController;
  late final TextEditingController _labelController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _helpTextController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  late String _selectedType;
  late bool _isRequired;
  late bool _isActive;

  // Dynamic options for select/checkbox
  final List<TextEditingController> _optionValueControllers = [];
  final List<TextEditingController> _optionLabelControllers = [];

  static const List<String> _fieldTypes = [
    'text',
    'number',
    'select',
    'checkbox',
    'date',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.field;
    _keyController = TextEditingController(text: f?.key ?? '');
    _labelController = TextEditingController(text: f?.label ?? '');
    _sortOrderController =
        TextEditingController(text: f?.sortOrder?.toString() ?? '0');
    _helpTextController = TextEditingController(text: f?.helpText ?? '');
    _minController = TextEditingController(
      text: f?.validationsJson?.min?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: f?.validationsJson?.max?.toString() ?? '',
    );
    _selectedType = f?.type ?? 'text';
    _isRequired = f?.required ?? false;
    _isActive = f?.isActive ?? true;

    // Pre-fill options if editing
    if (f?.optionsJson != null) {
      for (final opt in f!.optionsJson!) {
        _optionValueControllers.add(
          TextEditingController(text: opt.value ?? ''),
        );
        _optionLabelControllers.add(
          TextEditingController(text: opt.label ?? ''),
        );
      }
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _labelController.dispose();
    _sortOrderController.dispose();
    _helpTextController.dispose();
    _minController.dispose();
    _maxController.dispose();
    for (final c in _optionValueControllers) {
      c.dispose();
    }
    for (final c in _optionLabelControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionValueControllers.add(TextEditingController());
      _optionLabelControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionValueControllers[index].dispose();
      _optionLabelControllers[index].dispose();
      _optionValueControllers.removeAt(index);
      _optionLabelControllers.removeAt(index);
    });
  }

  bool get _showOptions =>
      _selectedType == 'select' || _selectedType == 'checkbox';
  bool get _showValidations => _selectedType == 'number';

  List<AppointmentFieldOptionModel> _buildOptions() {
    final result = <AppointmentFieldOptionModel>[];
    for (int i = 0; i < _optionValueControllers.length; i++) {
      final val = _optionValueControllers[i].text.trim();
      final lbl = _optionLabelControllers[i].text.trim();
      if (val.isNotEmpty || lbl.isNotEmpty) {
        result.add(AppointmentFieldOptionModel(value: val, label: lbl));
      }
    }
    return result;
  }

  AppointmentFieldValidationsModel? _buildValidations() {
    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();
    if (minText.isEmpty && maxText.isEmpty) return null;
    return AppointmentFieldValidationsModel(
      min: minText.isNotEmpty ? num.tryParse(minText) : null,
      max: maxText.isNotEmpty ? num.tryParse(maxText) : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel =
        context.read<AppointmentFieldsViewModel>();
    final options = _showOptions ? _buildOptions() : null;
    final validations = _showValidations ? _buildValidations() : null;
    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    bool success;

    if (widget._isEditing) {
      success = await viewModel.updateField(
        widget.field!.id!,
        label: _labelController.text.trim(),
        type: _selectedType,
        required: _isRequired,
        isActive: _isActive,
        sortOrder: sortOrder,
        helpText: _helpTextController.text.trim().isEmpty
            ? null
            : _helpTextController.text.trim(),
        optionsJson: options,
        validationsJson: validations,
      );
      if (success && mounted) {
        Navigator.of(context).pop(FieldFormResult.updated);
      }
    } else {
      success = await viewModel.createField(
        key: _keyController.text.trim(),
        label: _labelController.text.trim(),
        type: _selectedType,
        required: _isRequired,
        isActive: _isActive,
        sortOrder: sortOrder,
        helpText: _helpTextController.text.trim().isEmpty
            ? null
            : _helpTextController.text.trim(),
        optionsJson: options,
        validationsJson: validations,
      );
      if (success && mounted) {
        Navigator.of(context).pop(FieldFormResult.created);
      }
    }
  }

  Future<void> _confirmDelete(AppStrings l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.fieldFormDeleteConfirmTitle,
          style: TextStyle(
            fontSize: SizeTokens.fontLG,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(l10n.fieldFormDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.fieldFormDeleteCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.fieldFormDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final viewModel = context.read<AppointmentFieldsViewModel>();
      final success = await viewModel.deleteField(widget.field!.id!);
      if (success && mounted) {
        Navigator.of(context).pop(FieldFormResult.deleted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);
    final isEditing = widget._isEditing;

    return Consumer<AppointmentFieldsViewModel>(
      builder: (context, viewModel, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SizeTokens.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  // drag handle
                  Padding(
                    padding: EdgeInsets.only(top: SizeTokens.spaceMD),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // title
                  Padding(
                    padding: EdgeInsets.all(SizeTokens.paddingXL),
                    child: Text(
                      isEditing
                          ? l10n.fieldFormEditTitle
                          : l10n.fieldFormCreateTitle,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXL,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  // error
                  if (viewModel.submitError != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.paddingPage,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(SizeTokens.paddingMD),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusMD),
                        ),
                        child: Text(
                          viewModel.submitError!,
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: SizeTokens.fontSM,
                          ),
                        ),
                      ),
                    ),
                  // form
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.all(SizeTokens.paddingPage),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Key (only when creating) ─────────────
                            if (!isEditing) ...[
                              TextFormField(
                                controller: _keyController,
                                decoration: InputDecoration(
                                  labelText: l10n.fieldKeyLabel,
                                  hintText: l10n.fieldKeyHint,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? l10n.fieldKeyLabel
                                    : null,
                              ),
                              SizedBox(height: SizeTokens.spaceLG),
                            ],
                            // ── Label ────────────────────────────────
                            TextFormField(
                              controller: _labelController,
                              decoration: InputDecoration(
                                labelText: l10n.fieldLabelLabel,
                                hintText: l10n.fieldLabelHint,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.fieldLabelLabel
                                  : null,
                            ),
                            SizedBox(height: SizeTokens.spaceLG),

                            // ── Type ─────────────────────────────────
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                labelText: l10n.fieldTypeLabel,
                              ),
                              items: _fieldTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(_typeLabel(t, l10n)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedType = v);
                                }
                              },
                            ),
                            SizedBox(height: SizeTokens.spaceLG),

                            // ── Sort order ───────────────────────────
                            TextFormField(
                              controller: _sortOrderController,
                              decoration: InputDecoration(
                                labelText: l10n.fieldSortOrderLabel,
                                hintText: l10n.fieldSortOrderHint,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: SizeTokens.spaceLG),

                            // ── Help text ─────────────────────────────
                            TextFormField(
                              controller: _helpTextController,
                              decoration: InputDecoration(
                                labelText: l10n.fieldHelpTextLabel,
                                hintText: l10n.fieldHelpTextHint,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: SizeTokens.spaceLG),

                            // ── Toggles row ──────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      l10n.fieldRequiredLabel,
                                      style: TextStyle(
                                        fontSize: SizeTokens.fontSM,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    value: _isRequired,
                                    onChanged: (v) =>
                                        setState(() => _isRequired = v),
                                    activeColor: AppTheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      l10n.fieldIsActiveLabel,
                                      style: TextStyle(
                                        fontSize: SizeTokens.fontSM,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    value: _isActive,
                                    onChanged: (v) =>
                                        setState(() => _isActive = v),
                                    activeColor: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),

                            // ── Validations (number only) ─────────────
                            if (_showValidations) ...[
                              SizedBox(height: SizeTokens.spaceLG),
                              Text(
                                l10n.fieldValidationsTitle,
                                style: TextStyle(
                                  fontSize: SizeTokens.fontMD,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: SizeTokens.spaceSM),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _minController,
                                      decoration: InputDecoration(
                                        labelText: l10n.fieldValidationMinLabel,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: SizeTokens.spaceMD),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _maxController,
                                      decoration: InputDecoration(
                                        labelText: l10n.fieldValidationMaxLabel,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // ── Options (select/checkbox only) ────────
                            if (_showOptions) ...[
                              SizedBox(height: SizeTokens.spaceLG),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.fieldOptionsTitle,
                                    style: TextStyle(
                                      fontSize: SizeTokens.fontMD,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _addOption,
                                    icon: const Icon(Icons.add_rounded,
                                        size: 16),
                                    label: Text(l10n.fieldAddOptionButton),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: SizeTokens.spaceSM),
                              if (_optionValueControllers.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: SizeTokens.spaceMD,
                                  ),
                                  child: Text(
                                    '—',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: SizeTokens.fontSM,
                                    ),
                                  ),
                                ),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _optionValueControllers.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: SizeTokens.spaceSM),
                                itemBuilder: (_, i) => Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _optionValueControllers[i],
                                        decoration: InputDecoration(
                                          labelText:
                                              l10n.fieldOptionValueLabel,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: SizeTokens.spaceSM),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _optionLabelControllers[i],
                                        decoration: InputDecoration(
                                          labelText:
                                              l10n.fieldOptionLabelLabel,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeOption(i),
                                      icon: Icon(
                                        Icons.remove_circle_outline_rounded,
                                        color: AppTheme.error,
                                        size: SizeTokens.iconMD,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: SizeTokens.spaceXXL),

                            // ── Submit button ─────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: viewModel.isSubmitting
                                    ? null
                                    : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  padding: EdgeInsets.symmetric(
                                    vertical: SizeTokens.paddingMD,
                                  ),
                                ),
                                child: viewModel.isSubmitting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isEditing
                                            ? l10n.fieldFormSaveButton
                                            : l10n.fieldFormCreateButton,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            // ── Delete button (edit mode only) ────────
                            if (isEditing) ...[
                              SizedBox(height: SizeTokens.spaceMD),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: viewModel.isSubmitting
                                      ? null
                                      : () => _confirmDelete(l10n),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.error,
                                    side: BorderSide(color: AppTheme.error),
                                    padding: EdgeInsets.symmetric(
                                      vertical: SizeTokens.paddingMD,
                                    ),
                                  ),
                                  child: Text(
                                    l10n.fieldFormDeleteButton,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            SizedBox(height: SizeTokens.spaceXXL),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _typeLabel(String type, AppStrings l10n) {
    switch (type) {
      case 'number':
        return l10n.fieldTypeNumber;
      case 'select':
        return l10n.fieldTypeSelect;
      case 'checkbox':
        return l10n.fieldTypeCheckbox;
      case 'date':
        return l10n.fieldTypeDate;
      default:
        return l10n.fieldTypeText;
    }
  }
}
