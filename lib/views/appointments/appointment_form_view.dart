import 'package:flutter/cupertino.dart';
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
    final l10n = AppStrings.of(context);
    await _showCupertinoDateTimePicker(
      label: l10n.appointmentStartsAtLabel,
      initial: _startDateTime,
      onDone: (dt) => setState(() => _startDateTime = dt),
    );
  }

  Future<void> _pickEndDateTime() async {
    final l10n = AppStrings.of(context);
    await _showCupertinoDateTimePicker(
      label: l10n.appointmentEndsAtLabel,
      initial: _endDateTime,
      onDone: (dt) => setState(() => _endDateTime = dt),
    );
  }

  Future<void> _showCupertinoDateTimePicker({
    required String label,
    required DateTime initial,
    required void Function(DateTime) onDone,
  }) async {
    DateTime temp = initial;
    final l10n = AppStrings.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeTokens.radiusXL),
              topRight: Radius.circular(SizeTokens.radiusXL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: SizeTokens.spaceMD),
              Container(
                width: SizeConfig.w(40),
                height: SizeConfig.h(4),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius:
                      BorderRadius.circular(SizeTokens.radiusCircle),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingPage,
                  vertical: SizeTokens.spaceMD,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: SizeTokens.fontXL,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onDone(temp);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        l10n.appointmentPickerDone,
                        style: TextStyle(
                          fontSize: SizeTokens.fontMD,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppTheme.divider),
              SizedBox(
                height: SizeConfig.h(240),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initial,
                  use24hFormat: true,
                  minuteInterval: 5,
                  onDateTimeChanged: (dt) {
                    temp = dt;
                  },
                ),
              ),
              SizedBox(height: SizeConfig.h(32)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAssigneesSheet(AppStrings l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeTokens.radiusXL),
                  topRight: Radius.circular(SizeTokens.radiusXL),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: SizeTokens.spaceMD),
                  Container(
                    width: SizeConfig.w(40),
                    height: SizeConfig.h(4),
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius:
                          BorderRadius.circular(SizeTokens.radiusCircle),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingPage,
                      vertical: SizeTokens.spaceMD,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.appointmentAssigneesLabel,
                          style: TextStyle(
                            fontSize: SizeTokens.fontXL,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Text(
                            l10n.appointmentPickerDone,
                            style: TextStyle(
                              fontSize: SizeTokens.fontMD,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppTheme.divider),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _members.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: AppTheme.divider),
                      itemBuilder: (_, i) {
                        final m = _members[i];
                        final id = m.id;
                        if (id == null) return const SizedBox.shrink();
                        final name =
                            m.user?.name ?? m.user?.email ?? '?';
                        final email = m.user?.name != null
                            ? (m.user?.email ?? '')
                            : '';
                        final selected =
                            _selectedMembershipIds.contains(id);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (selected) {
                                _selectedMembershipIds.remove(id);
                              } else {
                                _selectedMembershipIds.add(id);
                              }
                            });
                            setState(() {});
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingPage,
                              vertical: SizeTokens.paddingMD,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: SizeTokens.avatarMD,
                                  height: SizeTokens.avatarMD,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? AppTheme.primary
                                        : AppTheme.surfaceVariant,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: SizeTokens.fontMD,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: SizeTokens.spaceMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: SizeTokens.fontMD,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (email.isNotEmpty)
                                        Text(
                                          email,
                                          style: TextStyle(
                                            fontSize: SizeTokens.fontSM,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: SizeTokens.iconMD,
                                  color: selected
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(36)),
                ],
              ),
            );
          },
        );
      },
    );
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

              // ── Section: Randevu Bilgileri ──────────────────────────
              _SectionLabel(l10n.appointmentSectionBasicInfo),
              _FormCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingMD,
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.appointmentTitleLabel,
                      hintText: l10n.appointmentTitleHint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? l10n.appointmentTitleLabel
                            : null,
                  ),
                ),
              ),
              SizedBox(height: SizeTokens.spaceLG),

              // ── Section: Tarih ve Saat ───────────────────────────────
              _SectionLabel(l10n.appointmentSectionDateTime),
              _FormCard(
                child: Column(
                  children: [
                    _DateTimeTile(
                      label: l10n.appointmentStartsAtLabel,
                      value: _displayDateForPicker(_startDateTime),
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickStartDateTime,
                    ),
                    Divider(height: 1, color: AppTheme.divider),
                    _DateTimeTile(
                      label: l10n.appointmentEndsAtLabel,
                      value: _displayDateForPicker(_endDateTime),
                      icon: Icons.event_rounded,
                      onTap: _pickEndDateTime,
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeTokens.spaceLG),

              // ── Section: Durum ───────────────────────────────────────
              if (_statuses.isNotEmpty) ...[
                _FormCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingMD,
                    ),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedStatusId,
                      decoration: InputDecoration(
                        labelText: l10n.appointmentStatusLabel,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            l10n.appointmentNoStatus,
                            style:
                                TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                        ..._statuses.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(s.name ?? '—'),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedStatusId = v),
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.spaceLG),
              ],

              // ── Section: Atananlar ───────────────────────────────────
              if (_members.isNotEmpty) ...[
                _FormCard(
                  child: _AssigneesSelectTile(
                    label: l10n.appointmentAssigneesLabel,
                    members: _members,
                    selectedIds: _selectedMembershipIds,
                    noneLabel: l10n.appointmentAssigneesNoneSelected,
                    nSelectedLabel: (n) =>
                        l10n.appointmentAssigneesNSelected(n),
                    onTap: () => _showAssigneesSheet(l10n),
                  ),
                ),
                SizedBox(height: SizeTokens.spaceLG),
              ],

              // ── Section: Notlar ──────────────────────────────────────
              _FormCard(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.paddingMD,
                      ),
                      child: TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: l10n.appointmentNotesLabel,
                          hintText: l10n.appointmentNotesHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        maxLines: 3,
                      ),
                    ),
                    if (widget._isEditing) ...[
                      Divider(height: 1, color: AppTheme.divider),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.paddingMD,
                        ),
                        child: TextFormField(
                          controller: _resultNotesController,
                          decoration: InputDecoration(
                            labelText: l10n.appointmentResultNotesLabel,
                            hintText: l10n.appointmentResultNotesHint,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: SizeTokens.spaceLG),

              // ── Section: Özel Alanlar ────────────────────────────────
              if (_fields.isNotEmpty) ...[
                _SectionLabel(l10n.appointmentCustomFieldsTitle),
                _FormCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < _fields.length; i++) ...[
                        if (_fields[i].key != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingMD,
                            ),
                            child: _buildCustomFieldInput(
                              _fields[i],
                              l10n,
                              noBorder: true,
                            ),
                          ),
                        if (i < _fields.length - 1 &&
                            _fields[i].key != null)
                          Divider(height: 1, color: AppTheme.divider),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: SizeTokens.spaceLG),
              ],

              SizedBox(height: SizeTokens.spaceXL),

              // ── Submit ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: viewModel.isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: SizeTokens.paddingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SizeTokens.radiusMD),
                    ),
                  ),
                  child: viewModel.isSubmitting
                      ? const SizedBox(
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
    AppStrings l10n, {
    bool noBorder = false,
  }) {
    final key = field.key!;
    final label = field.label ?? key;
    final border = noBorder ? InputBorder.none : null;

    switch (field.type) {
      case 'number':
        return TextFormField(
          initialValue: _customFieldValues[key]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: label,
            hintText: field.helpText,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
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
          decoration: InputDecoration(
            labelText: label,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
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
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
          onChanged: (v) {
            _customFieldValues[key] = v.isEmpty ? null : v;
          },
        );
    }
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeTokens.spaceXS,
        bottom: SizeTokens.spaceSM,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: SizeTokens.fontXS,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingMD,
        ),
        child: Row(
          children: [
            Icon(
              icon,
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
                  SizedBox(height: SizeConfig.h(2)),
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
              Icons.chevron_right_rounded,
              size: SizeTokens.iconSM,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssigneesSelectTile extends StatelessWidget {
  final String label;
  final List<MembershipModel> members;
  final Set<int> selectedIds;
  final String noneLabel;
  final String Function(int) nSelectedLabel;
  final VoidCallback onTap;

  const _AssigneesSelectTile({
    required this.label,
    required this.members,
    required this.selectedIds,
    required this.noneLabel,
    required this.nSelectedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = selectedIds.length;
    final String subtitle;
    if (count == 0) {
      subtitle = noneLabel;
    } else {
      final names = members
          .where((m) => m.id != null && selectedIds.contains(m.id))
          .map((m) => m.user?.name ?? m.user?.email ?? '?')
          .toList();
      subtitle =
          names.isEmpty ? nSelectedLabel(count) : names.join(', ');
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingMD,
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
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
                  SizedBox(height: SizeConfig.h(2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: count > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: count > 0
                          ? AppTheme.textPrimary
                          : AppTheme.textHint,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (count > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingXS,
                  vertical: SizeTokens.spaceXXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(SizeTokens.radiusCircle),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXS,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spaceXS),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: SizeTokens.iconSM,
              color: AppTheme.textSecondary,
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeTokens.paddingMD,
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
                  SizedBox(height: SizeConfig.h(2)),
                  Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? AppTheme.textPrimary
                          : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: SizeTokens.iconSM,
              color: AppTheme.textSecondary,
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
    final l10n = AppStrings.of(context);
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
              child: Text(l10n.appointmentsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
