import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/appointment_field_model.dart';
import '../../models/appointment_model.dart';
import '../../models/appointment_status_model.dart';
import '../../models/create_appointment_request_model.dart';
import '../../models/membership_model.dart';
import '../../models/update_appointment_request_model.dart';
import '../../services/appointment_field_service.dart';
import '../../services/appointment_status_service.dart';
import '../../services/member_service.dart';
import '../../viewmodels/appointments_view_model.dart';
import '../../core/network/api_result.dart';

class AppointmentFormView extends StatefulWidget {
  final int brandId;
  final AppointmentModel? appointment;

  const AppointmentFormView({
    super.key,
    required this.brandId,
    this.appointment,
  });

  bool get _isEditing => appointment != null;

  @override
  State<AppointmentFormView> createState() => _AppointmentFormViewState();
}

class _AppointmentFormViewState extends State<AppointmentFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _resultNotesController;

  late DateTime _startDateTime;
  late DateTime _endDateTime;

  int? _selectedStatusId;
  final Set<int> _selectedMembershipIds = {};

  // Custom field values: key → dynamic (String, num, or List<String>)
  final Map<String, dynamic> _customFieldValues = {};

  // Loaded data
  bool _isLoadingData = true;
  String? _loadError;
  List<AppointmentStatusModel> _statuses = [];
  List<MembershipModel> _members = [];
  List<AppointmentFieldModel> _fields = [];

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    _titleController = TextEditingController(text: a?.title ?? '');
    _notesController = TextEditingController(text: a?.notes ?? '');
    _resultNotesController =
        TextEditingController(text: a?.resultNotes ?? '');

    final now = DateTime.now();
    _startDateTime = a?.startsAtDateTime ??
        DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    _endDateTime = a?.endsAtDateTime ??
        DateTime(now.year, now.month, now.day, now.hour + 2, 0);

    _selectedStatusId = a?.status?.id;

    // Pre-fill assignees
    if (a?.assignees != null) {
      for (final assignee in a!.assignees!) {
        if (assignee.membershipId != null) {
          _selectedMembershipIds.add(assignee.membershipId!);
        }
      }
    }

    // Pre-fill custom fields
    if (a?.customFields != null) {
      _customFieldValues.addAll(a!.customFields!);
    }

    _loadFormData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _resultNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });

    final results = await Future.wait([
      AppointmentStatusService.instance.statuses(widget.brandId),
      MemberService.instance.members(widget.brandId),
      AppointmentFieldService.instance.fields(widget.brandId),
    ]);

    if (!mounted) return;

    final statusResult = results[0];
    final memberResult = results[1];
    final fieldResult = results[2];

    String? error;

    if (statusResult case ApiSuccess(:final data)) {
      _statuses = (data as dynamic).statuses as List<AppointmentStatusModel>;
    } else if (statusResult case ApiFailure(:final exception)) {
      error = exception.message;
    }

    if (memberResult case ApiSuccess(:final data)) {
      _members = (data as dynamic).data as List<MembershipModel>? ?? [];
    } else if (memberResult case ApiFailure(:final exception)) {
      error ??= exception.message;
    }

    if (fieldResult case ApiSuccess(:final data)) {
      _fields = (data as dynamic).fields as List<AppointmentFieldModel>;
      // Initialize custom field values not yet set
      for (final field in _fields) {
        if (field.key != null && !_customFieldValues.containsKey(field.key)) {
          if (field.type == 'checkbox') {
            _customFieldValues[field.key!] = <String>[];
          } else {
            _customFieldValues[field.key!] = null;
          }
        }
      }
    } else if (fieldResult case ApiFailure(:final exception)) {
      error ??= exception.message;
    }

    setState(() {
      _isLoadingData = false;
      _loadError = error;
    });
  }

  String _fmtDT(DateTime dt) {
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:00';
  }

  String _displayDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _displayTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _displayDateForPicker(DateTime dt) =>
      '${_displayDate(dt)}  ${_displayTime(dt)}';

  Future<void> _pickStartDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _startDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEndDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDateTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _endDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Map<String, dynamic>? _buildCustomFields() {
    if (_fields.isEmpty) return null;
    final result = <String, dynamic>{};
    for (final entry in _customFieldValues.entries) {
      if (entry.value != null) {
        if (entry.value is List && (entry.value as List).isEmpty) continue;
        result[entry.key] = entry.value;
      }
    }
    return result.isEmpty ? null : result;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel =
        Provider.of<AppointmentsViewModel>(context, listen: false);
    final customFields = _buildCustomFields();
    final assignmentIds = _selectedMembershipIds.isEmpty
        ? null
        : _selectedMembershipIds.toList();

    bool success;

    if (widget._isEditing) {
      success = await viewModel.updateAppointment(
        widget.appointment!.id!,
        UpdateAppointmentRequestModel(
          title: _titleController.text.trim(),
          startsAt: _fmtDT(_startDateTime),
          endsAt: _fmtDT(_endDateTime),
          statusId: _selectedStatusId,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          resultNotes: _resultNotesController.text.trim().isEmpty
              ? null
              : _resultNotesController.text.trim(),
          assignmentMembershipIds: assignmentIds,
          customFields: customFields,
        ),
      );
    } else {
      success = await viewModel.createAppointment(
        CreateAppointmentRequestModel(
          title: _titleController.text.trim(),
          startsAt: _fmtDT(_startDateTime),
          endsAt: _fmtDT(_endDateTime),
          statusId: _selectedStatusId,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          assignmentMembershipIds: assignmentIds,
          customFields: customFields,
        ),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return Consumer<AppointmentsViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: AppTheme.surfaceVariant,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(SizeConfig.h(1)),
              child: Container(
                height: SizeConfig.h(1),
                color: AppTheme.divider,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: SizeTokens.iconMD,
              ),
            ),
            title: Text(
              widget._isEditing
                  ? l10n.appointmentFormEditTitle
                  : l10n.appointmentFormCreateTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontLG,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          body: _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
                  ? _ErrorReload(message: _loadError!, onRetry: _loadFormData)
                  : _buildForm(context, l10n, viewModel),
        );
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppStrings l10n,
    AppointmentsViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SizeTokens.paddingPage),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Submit error
              if (viewModel.submitError != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: SizeTokens.spaceLG),
                  padding: EdgeInsets.all(SizeTokens.paddingMD),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                  ),
                  child: Text(
                    viewModel.submitError!,
                    style: TextStyle(
                      color: AppTheme.error,
                      fontSize: SizeTokens.fontSM,
                    ),
                  ),
                ),

              // ── Title ──────────────────────────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.appointmentTitleLabel,
                  hintText: l10n.appointmentTitleHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? l10n.appointmentTitleLabel
                        : null,
              ),
              SizedBox(height: SizeTokens.spaceLG),

              // ── Start date/time ────────────────────────────────────
              _DateTimeTile(
                label: l10n.appointmentStartsAtLabel,
                value: _displayDateForPicker(_startDateTime),
                onTap: _pickStartDateTime,
              ),
              SizedBox(height: SizeTokens.spaceMD),

              // ── End date/time ──────────────────────────────────────
              _DateTimeTile(
                label: l10n.appointmentEndsAtLabel,
                value: _displayDateForPicker(_endDateTime),
                onTap: _pickEndDateTime,
              ),
              SizedBox(height: SizeTokens.spaceLG),

              // ── Status ─────────────────────────────────────────────
              if (_statuses.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: _selectedStatusId,
                  decoration: InputDecoration(
                    labelText: l10n.appointmentStatusLabel,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        l10n.appointmentNoStatus,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    ..._statuses.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(s.name ?? '—'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedStatusId = v),
                ),

              if (_statuses.isNotEmpty) SizedBox(height: SizeTokens.spaceLG),

              // ── Notes ──────────────────────────────────────────────
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.appointmentNotesLabel,
                  hintText: l10n.appointmentNotesHint,
                ),
                maxLines: 3,
              ),
              SizedBox(height: SizeTokens.spaceLG),

              // ── Result notes (edit only) ───────────────────────────
              if (widget._isEditing) ...[
                TextFormField(
                  controller: _resultNotesController,
                  decoration: InputDecoration(
                    labelText: l10n.appointmentResultNotesLabel,
                    hintText: l10n.appointmentResultNotesHint,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: SizeTokens.spaceLG),
              ],

              // ── Assignees ──────────────────────────────────────────
              if (_members.isNotEmpty) ...[
                Text(
                  l10n.appointmentAssigneesLabel,
                  style: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: SizeTokens.spaceSM),
                Wrap(
                  spacing: SizeTokens.spaceSM,
                  runSpacing: SizeTokens.spaceSM,
                  children: _members.map((m) {
                    final id = m.id;
                    if (id == null) return const SizedBox.shrink();
                    final selected = _selectedMembershipIds.contains(id);
                    final name =
                        m.user?.name ?? m.user?.email ?? '?';
                    return FilterChip(
                      label: Text(name),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedMembershipIds.add(id);
                          } else {
                            _selectedMembershipIds.remove(id);
                          }
                        });
                      },
                      selectedColor:
                          AppTheme.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppTheme.primary,
                      side: BorderSide(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.border,
                      ),
                      labelStyle: TextStyle(
                        fontSize: SizeTokens.fontSM,
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: SizeTokens.spaceLG),
              ],

              // ── Custom fields ──────────────────────────────────────
              if (_fields.isNotEmpty) ...[
                Text(
                  l10n.appointmentCustomFieldsTitle,
                  style: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: SizeTokens.spaceSM),
                ..._fields.map((field) {
                  if (field.key == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(bottom: SizeTokens.spaceLG),
                    child: _buildCustomFieldInput(field, l10n),
                  );
                }),
              ],

              SizedBox(height: SizeTokens.spaceXL),

              // ── Submit ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: viewModel.isSubmitting ? null : _submit,
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
                          widget._isEditing
                              ? l10n.appointmentFormSaveButton
                              : l10n.appointmentFormCreateButton,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: SizeTokens.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFieldInput(
    AppointmentFieldModel field,
    AppStrings l10n,
  ) {
    final key = field.key!;
    final label = field.label ?? key;

    switch (field.type) {
      case 'number':
        return TextFormField(
          initialValue: _customFieldValues[key]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: label,
            hintText: field.helpText,
          ),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (v) {
            _customFieldValues[key] = v.isEmpty ? null : num.tryParse(v) ?? v;
          },
        );

      case 'select':
        final options = field.optionsJson ?? [];
        final current = _customFieldValues[key] as String?;
        return DropdownButtonFormField<String?>(
          value: options.any((o) => o.value == current) ? current : null,
          decoration: InputDecoration(labelText: label),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                '—',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ...options.map(
              (o) => DropdownMenuItem<String?>(
                value: o.value,
                child: Text(o.label ?? o.value ?? '—'),
              ),
            ),
          ],
          onChanged: (v) {
            setState(() => _customFieldValues[key] = v);
          },
        );

      case 'checkbox':
        final options = field.optionsJson ?? [];
        final selected = (_customFieldValues[key] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.fontSM,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceXS),
            Wrap(
              spacing: SizeTokens.spaceSM,
              runSpacing: SizeTokens.spaceSM,
              children: options.map((o) {
                final val = o.value ?? '';
                final isSelected = selected.contains(val);
                return FilterChip(
                  label: Text(o.label ?? val),
                  selected: isSelected,
                  onSelected: (v) {
                    setState(() {
                      final list = List<String>.from(selected);
                      if (v) {
                        list.add(val);
                      } else {
                        list.remove(val);
                      }
                      _customFieldValues[key] = list;
                    });
                  },
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primary,
                  side: BorderSide(
                    color:
                        isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 'date':
        final dateVal = _customFieldValues[key] as String?;
        return _DatePickerField(
          label: label,
          value: dateVal,
          onChanged: (v) => setState(() => _customFieldValues[key] = v),
        );

      default: // text and fallback
        return TextFormField(
          initialValue: _customFieldValues[key]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: label,
            hintText: field.helpText,
          ),
          onChanged: (v) {
            _customFieldValues[key] = v.isEmpty ? null : v;
          },
        );
    }
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _DateTimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingMD,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          color: AppTheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: SizeTokens.iconSM,
              color: AppTheme.textSecondary,
            ),
            SizedBox(width: SizeTokens.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              size: SizeTokens.iconSM,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? '—';
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        DateTime? initial;
        if (value != null) {
          try {
            initial = DateTime.parse(value!);
          } catch (_) {}
        }
        final picked = await showDatePicker(
          context: context,
          initialDate: initial ?? now,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked == null) return;
        final formatted =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        onChanged(formatted);
      },
      borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingMD,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
          color: AppTheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: SizeTokens.iconSM,
              color: AppTheme.textSecondary,
            ),
            SizedBox(width: SizeTokens.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: SizeTokens.fontXS,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorReload extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorReload({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.paddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.fontMD,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceLG),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
