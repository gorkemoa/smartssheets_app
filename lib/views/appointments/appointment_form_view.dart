import 'package:flutter/material.dart';
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
    _resultNotesController = TextEditingController(text: a?.resultNotes ?? '');

    final now = DateTime.now();
    _startDateTime =
        a?.startsAtDateTime ??
        DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    _endDateTime =
        a?.endsAtDateTime ??
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

  // Uses Material DateRangePicker followed by TimePickers for a unified flow
  Future<void> _pickDateTimeRange() async {
    final l10n = AppStrings.of(context);
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDateTime, end: _endDateTime),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (range == null || !mounted) return;

    // Pick start time
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
      helpText: l10n.appointmentStartsAtLabel,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );

    if (startTime == null || !mounted) return;

    // Pick end time
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDateTime),
      helpText: l10n.appointmentEndsAtLabel,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );

    if (endTime == null) return;

    setState(() {
      _startDateTime = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
        startTime.hour,
        startTime.minute,
      );
      _endDateTime = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        endTime.hour,
        endTime.minute,
      );
    });
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
                      borderRadius: BorderRadius.circular(
                        SizeTokens.radiusCircle,
                      ),
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
                        final name = m.user?.name ?? m.user?.email ?? '?';
                        final email = m.user?.name != null
                            ? (m.user?.email ?? '')
                            : '';
                        final selected = _selectedMembershipIds.contains(id);
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

    final viewModel = Provider.of<AppointmentsViewModel>(
      context,
      listen: false,
    );
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
              icon: Icon(Icons.arrow_back_ios_rounded, size: SizeTokens.iconMD),
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
    final String startDisplay = _displayDateForPicker(_startDateTime);
    final String endDisplay = _displayDateForPicker(_endDateTime);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingMD,
          SizeTokens.spaceLG,
          SizeTokens.paddingMD,
          SizeTokens.spaceXXXL,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Submit error ───────────────────────────────────────
              if (viewModel.submitError != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(SizeTokens.paddingMD),
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight,
                    borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: SizeTokens.iconMD,
                        color: AppTheme.error,
                      ),
                      SizedBox(width: SizeTokens.spaceXS),
                      Expanded(
                        child: Text(
                          viewModel.submitError!,
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: SizeTokens.fontSM,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeTokens.spaceLG),
              ],

              // ── Başlık ───────────────────────────────────────────
              _SectionHeader(
                icon: Icons.text_fields_rounded,
                label: l10n.appointmentSectionBasicInfo,
              ),
              _InputCard(
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.appointmentTitleLabel,
                    hintText: l10n.appointmentTitleHint,
                    hintStyle: TextStyle(color: AppTheme.textHint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingMD,
                      vertical: SizeTokens.paddingSM,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.appointmentTitleLabel
                      : null,
                ),
              ),
              SizedBox(height: SizeTokens.spaceXL),

              // ── Tarih & Saat (Başlangıç / Bitiş) ────────────────
              _SectionHeader(
                icon: Icons.calendar_month_rounded,
                label: l10n.appointmentSectionDateTime,
              ),
              _InputCard(
                child: Column(
                  children: [
                    // Başlangıç
                    _DateTimePickerRow(
                      icon: Icons.date_range_rounded,
                      label: l10n.appointmentSectionDateTime,
                      value: '$startDisplay - $endDisplay',
                      onTap: _pickDateTimeRange,
                      iconColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeTokens.spaceXL),

              // ── Durum ─────────────────────────────────────────────
              if (_statuses.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.flag_outlined,
                  label: l10n.appointmentStatusLabel,
                ),
                _InputCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingMD,
                    ),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedStatusId,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: SizeTokens.fontMD,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.appointmentNoStatus,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeTokens.paddingSM,
                        ),
                      ),
                      icon: Icon(
                        Icons.expand_more_rounded,
                        color: AppTheme.textSecondary,
                        size: SizeTokens.iconMD,
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            l10n.appointmentNoStatus,
                            style: TextStyle(
                              color: AppTheme.textHint,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        ..._statuses.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Row(
                              children: [
                                if (s.color != null) ...[
                                  Container(
                                    width: SizeTokens.spaceXS,
                                    height: SizeTokens.spaceXS,
                                    margin: EdgeInsets.only(
                                      right: SizeTokens.spaceXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _hexColor(s.color),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                Text(s.name ?? '—'),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedStatusId = v),
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.spaceXL),
              ],

              // ── Atananlar ────────────────────────────────────────
              if (_members.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.people_outline_rounded,
                  label: l10n.appointmentAssigneesLabel,
                ),
                _InputCard(
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
                SizedBox(height: SizeTokens.spaceXL),
              ],

              // ── Notlar ───────────────────────────────────────────
              _SectionHeader(
                icon: Icons.notes_rounded,
                label: l10n.appointmentNotesLabel,
              ),
              _InputCard(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.paddingMD,
                      ),
                      child: TextFormField(
                        controller: _notesController,
                        minLines: 3,
                        maxLines: 6,
                        style: TextStyle(
                          fontSize: SizeTokens.fontMD,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.appointmentNotesHint,
                          hintStyle: TextStyle(color: AppTheme.textHint),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: SizeTokens.paddingSM,
                          ),
                        ),
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
                          minLines: 2,
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: SizeTokens.fontMD,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.appointmentResultNotesHint,
                            labelText: l10n.appointmentResultNotesLabel,
                            hintStyle: TextStyle(color: AppTheme.textHint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: SizeTokens.paddingSM,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Özel Alanlar ─────────────────────────────────────
              if (_fields.isNotEmpty) ...[
                SizedBox(height: SizeTokens.spaceXL),
                _SectionHeader(
                  icon: Icons.tune_rounded,
                  label: l10n.appointmentCustomFieldsTitle,
                ),
                _InputCard(
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
                        if (i < _fields.length - 1 && _fields[i].key != null)
                          Divider(height: 1, color: AppTheme.divider),
                      ],
                    ],
                  ),
                ),
              ],

              SizedBox(height: SizeTokens.spaceXXL),

              // ── Kaydet / Oluştur ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: SizeTokens.buttonHeight,
                child: FilledButton(
                  onPressed: viewModel.isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
                    ),
                  ),
                  child: viewModel.isSubmitting
                      ? SizedBox(
                          width: SizeTokens.iconMD,
                          height: SizeTokens.iconMD,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget._isEditing
                              ? l10n.appointmentFormSaveButton
                              : l10n.appointmentFormCreateButton,
                          style: TextStyle(
                            fontSize: SizeTokens.fontLG,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  static Color _hexColor(String? hex) {
    if (hex == null) return Colors.transparent;
    final h = hex.replaceAll('#', '');
    if (h.length == 6) {
      try {
        return Color(int.parse('FF$h', radix: 16));
      } catch (_) {}
    }
    return Colors.transparent;
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
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
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
              child: Text('—', style: TextStyle(color: AppTheme.textSecondary)),
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
        final selected =
            (_customFieldValues[key] as List?)
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
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
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

// Clean input card with subtle elevation
class _InputCard extends StatelessWidget {
  final Widget child;

  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.6)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        child: child,
      ),
    );
  }
}

// Section header with icon
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeTokens.spaceSM),
      child: Row(
        children: [
          Icon(icon, size: SizeTokens.iconSM, color: AppTheme.primary),
          SizedBox(width: SizeTokens.spaceXS),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Date-time picker tile row (start/end)
class _DateTimePickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color iconColor;

  const _DateTimePickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingSM,
        ),
        child: Row(
          children: [
            Icon(icon, size: SizeTokens.iconMD, color: iconColor),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(3)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: SizeTokens.fontMD,
                      fontWeight: FontWeight.w600,
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
      subtitle = names.isEmpty ? nSelectedLabel(count) : names.join(', ');
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMD,
          vertical: SizeTokens.paddingSM,
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
                      fontWeight: count > 0 ? FontWeight.w500 : FontWeight.w400,
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
                  borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
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
        padding: EdgeInsets.symmetric(vertical: SizeTokens.paddingSM),
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
            TextButton(onPressed: onRetry, child: Text(l10n.appointmentsRetry)),
          ],
        ),
      ),
    );
  }
}
