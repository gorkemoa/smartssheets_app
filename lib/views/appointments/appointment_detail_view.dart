import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';
import '../../models/appointment_model.dart';
import '../../models/appointment_result_file_model.dart';
import '../../models/update_result_notes_request_model.dart';
import '../../viewmodels/appointments_view_model.dart';
import 'appointment_form_view.dart';
import 'pdf_viewer_view.dart';

class AppointmentDetailView extends StatelessWidget {
  final int brandId;
  final AppointmentModel appointment;

  const AppointmentDetailView({
    super.key,
    required this.brandId,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return _AppointmentDetailBody(
      brandId: brandId,
      appointment: appointment,
    );
  }
}

class _AppointmentDetailBody extends StatefulWidget {
  final int brandId;
  final AppointmentModel appointment;

  const _AppointmentDetailBody({
    required this.brandId,
    required this.appointment,
  });

  @override
  State<_AppointmentDetailBody> createState() => _AppointmentDetailBodyState();
}

class _AppointmentDetailBodyState extends State<_AppointmentDetailBody> {
  int? _loadingViewFileId;
  int? _loadingDownloadFileId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appointment.id != null) {
        Provider.of<AppointmentsViewModel>(
          context,
          listen: false,
        ).loadResultFiles(widget.appointment.id!);
      }
    });
  }

  Color _statusColor() {
    final color = widget.appointment.status?.color;
    if (color == null) return AppTheme.primary;
    try {
      final hex = color.replaceFirst('#', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final date =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$date $time';
    } catch (_) {
      return iso;
    }
  }

  void _showEditResultNotesSheet(
    BuildContext context,
    AppStrings l10n,
    AppointmentModel appt,
  ) {
    final controller = TextEditingController(text: appt.resultNotes ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.radiusXL),
        ),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: SizeTokens.paddingPage,
          right: SizeTokens.paddingPage,
          top: SizeTokens.paddingXL,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom +
              SizeTokens.paddingXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appointmentDetailResultNotesEdit,
              style: TextStyle(
                fontSize: SizeTokens.fontLG,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceLG),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.appointmentResultNotesLabel,
                hintText: l10n.appointmentResultNotesHint,
              ),
              maxLines: 4,
              autofocus: true,
            ),
            SizedBox(height: SizeTokens.spaceLG),
            Consumer<AppointmentsViewModel>(
              builder: (_, viewModel, __) {
                final error = viewModel.submitError;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: SizeTokens.spaceMD),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: AppTheme.error,
                      fontSize: SizeTokens.fontSM,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: double.infinity,
              child: Consumer<AppointmentsViewModel>(
                builder: (_, viewModel, __) => FilledButton(
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () async {
                          final vm = Provider.of<AppointmentsViewModel>(
                            context,
                            listen: false,
                          );
                          final success = await vm.updateResultNotes(
                            appt.id!,
                            UpdateResultNotesRequestModel(
                              resultNotes: controller.text.trim().isEmpty
                                  ? null
                                  : controller.text.trim(),
                            ),
                          );
                          if (success && context.mounted) {
                            Navigator.of(sheetCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.appointmentResultNotesSuccess),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.of(context).pop(true);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: SizeTokens.paddingMD,
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
                          l10n.appointmentFormSaveButton,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
            SizedBox(height: SizeTokens.spaceSM),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFiles(
    BuildContext context,
    AppStrings l10n,
    AppointmentsViewModel viewModel,
  ) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;

    final files = result.files
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();

    if (files.isEmpty) return;

    final appointmentId = widget.appointment.id;
    if (appointmentId == null) return;

    final success = await viewModel.uploadResultFiles(appointmentId, files);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appointmentResultFilesUploadSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (viewModel.submitError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.submitError!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
          ),
        );
        viewModel.clearSubmitError();
      }
    }
  }

  Future<void> _openPdfFile(
    BuildContext context,
    AppStrings l10n,
    AppointmentsViewModel viewModel,
    AppointmentResultFileModel file,
  ) async {
    if (file.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _loadingViewFileId = file.id);
    final url = await viewModel.getResultFileDownloadUrl(
      widget.appointment.id!,
      file.id!,
    );
    if (!mounted) return;
    setState(() => _loadingViewFileId = null);
    if (url == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.appointmentResultFilesDownloadError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    navigator.push(
      MaterialPageRoute(
        builder: (_) => PdfViewerView(
          url: url,
          fileName: file.originalName,
        ),
      ),
    );
  }

  Future<void> _downloadFile(
    BuildContext context,
    AppStrings l10n,
    AppointmentsViewModel viewModel,
    AppointmentResultFileModel file,
  ) async {
    if (file.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loadingDownloadFileId = file.id);
    final url = await viewModel.getResultFileDownloadUrl(
      widget.appointment.id!,
      file.id!,
    );
    if (!mounted) return;
    setState(() => _loadingDownloadFileId = null);
    if (url == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.appointmentResultFilesDownloadError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.appointmentResultFilesDownloadError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _deleteFile(
    BuildContext context,
    AppStrings l10n,
    AppointmentsViewModel viewModel,
    AppointmentResultFileModel file,
  ) async {
    if (file.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.appointmentResultFilesDeleteConfirmTitle),
        content: Text(l10n.appointmentResultFilesDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.appointmentResultFilesDeleteConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.appointmentResultFilesDeleteConfirmAction,
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await viewModel.deleteResultFile(
      widget.appointment.id!,
      file.id!,
    );
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appointmentResultFilesDeleteSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (viewModel.submitError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.submitError!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
          ),
        );
        viewModel.clearSubmitError();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);
    final statusColor = _statusColor();
    final customFields = widget.appointment.customFields;
    final assignees = widget.appointment.assignees ?? [];

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
          widget.appointment.title ?? l10n.appointmentDetailTitle,
          style: TextStyle(
            fontSize: SizeTokens.fontLG,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<AppointmentsViewModel>(context, listen: false);
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: AppointmentFormView(
                      brandId: widget.brandId,
                      appointment: widget.appointment,
                    ),
                  ),
                ),
              );
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.appointmentUpdateSuccess),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop(true);
              }
            },
            icon: Icon(
              Icons.edit_rounded,
              size: SizeTokens.iconMD,
              color: AppTheme.primary,
            ),
            tooltip: l10n.appointmentDetailEdit,
          ),
          IconButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<AppointmentsViewModel>(context, listen: false);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: Text(l10n.appointmentDeleteConfirmTitle),
                  content: Text(l10n.appointmentDeleteConfirmMessage),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(dialogCtx).pop(false),
                      child:
                          Text(l10n.appointmentDeleteConfirmCancel),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(dialogCtx).pop(true),
                      child: Text(
                        l10n.appointmentDeleteConfirmAction,
                        style: TextStyle(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              final success = await viewModel
                  .deleteAppointment(widget.appointment.id!);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.appointmentDeleteSuccess),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop(true);
                } else if (viewModel.submitError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.submitError!),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.error,
                    ),
                  );
                  viewModel.clearSubmitError();
                }
              }
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              size: SizeTokens.iconMD,
              color: AppTheme.error,
            ),
            tooltip: l10n.appointmentDeleteConfirmTitle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeTokens.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status + time card ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.paddingXL),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  if (widget.appointment.status != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spaceSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusSM),
                      ),
                      child: Text(
                        widget.appointment.status!.name ?? '—',
                        style: TextStyle(
                          fontSize: SizeTokens.fontSM,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  SizedBox(height: SizeTokens.spaceMD),
                  // Start time
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: l10n.appointmentStartsAtLabel,
                    value: _formatDateTime(widget.appointment.startsAt),
                  ),
                  SizedBox(height: SizeTokens.spaceSM),
                  // End time
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: l10n.appointmentEndsAtLabel,
                    value: _formatDateTime(widget.appointment.endsAt),
                  ),
                  // Completed at
                  if (widget.appointment.completedAt != null) ...[
                    SizedBox(height: SizeTokens.spaceSM),
                    _DetailRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: l10n.appointmentDetailCompletedAt,
                      value: _formatDateTime(widget.appointment.completedAt),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: SizeTokens.spaceMD),

            // ── Assignees ────────────────────────────────────────────
            if (assignees.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailAssignees,
                child: Wrap(
                  spacing: SizeTokens.spaceSM,
                  runSpacing: SizeTokens.spaceSM,
                  children: assignees
                      .map(
                        (a) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor:
                                AppTheme.primary.withValues(alpha: 0.15),
                            child: Text(
                              (a.name ?? '?').substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: SizeTokens.fontXS,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          label: Text(
                            a.name ?? a.email ?? '—',
                            style: TextStyle(
                              fontSize: SizeTokens.fontSM,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          backgroundColor: AppTheme.surfaceVariant,
                          side: BorderSide(color: AppTheme.border),
                        ),
                      )
                      .toList(),
                ),
              ),

            if (assignees.isNotEmpty) SizedBox(height: SizeTokens.spaceMD),

            // ── Notes ────────────────────────────────────────────────
            if (widget.appointment.notes != null && widget.appointment.notes!.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailNotes,
                child: Text(
                  widget.appointment.notes!,
                  style: TextStyle(
                    fontSize: SizeTokens.fontMD,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

            if (widget.appointment.notes != null && widget.appointment.notes!.isNotEmpty)
              SizedBox(height: SizeTokens.spaceMD),

            // ── Result notes ─────────────────────────────────────────
            _SectionCard(
              title: l10n.appointmentDetailResultNotes,
              onEdit: () => _showEditResultNotesSheet(
                  context, l10n, widget.appointment),
              child: Text(
                (widget.appointment.resultNotes != null &&
                        widget.appointment.resultNotes!.isNotEmpty)
                    ? widget.appointment.resultNotes!
                    : l10n.appointmentDetailResultNotesEmpty,
                style: TextStyle(
                  fontSize: SizeTokens.fontMD,
                  color: (widget.appointment.resultNotes != null &&
                          widget.appointment.resultNotes!.isNotEmpty)
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),

            SizedBox(height: SizeTokens.spaceMD),

            // ── Result files ─────────────────────────────────
            Consumer<AppointmentsViewModel>(
              builder: (_, viewModel, __) {
                return _SectionCard(
                  title: l10n.appointmentResultFilesTitle,
                  trailingAction: viewModel.isUploadingFiles
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.upload_file_rounded,
                            size: SizeTokens.iconSM,
                            color: AppTheme.primary,
                          ),
                          tooltip: l10n.appointmentResultFilesUpload,
                          onPressed: () => _pickAndUploadFiles(
                            context,
                            l10n,
                            viewModel,
                          ),
                        ),
                  child: viewModel.isLoadingFiles
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : viewModel.filesError != null
                          ? Text(
                              viewModel.filesError!,
                              style: TextStyle(
                                fontSize: SizeTokens.fontSM,
                                color: AppTheme.error,
                              ),
                            )
                          : viewModel.resultFiles.isEmpty
                              ? Text(
                                  l10n.appointmentResultFilesEmpty,
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontMD,
                                    color: AppTheme.textSecondary,
                                  ),
                                )
                              : Column(
                                  children: viewModel.resultFiles
                                      .map(
                                        (file) => _ResultFileTile(
                                          file: file,
                                          l10n: l10n,
                                          isLoadingView: _loadingViewFileId == file.id,
                                          isLoadingDownload: _loadingDownloadFileId == file.id,
                                          onView: () => _openPdfFile(
                                              context, l10n, viewModel, file),
                                          onDownload: () => _downloadFile(
                                              context, l10n, viewModel, file),
                                          onDelete: () => _deleteFile(
                                              context, l10n, viewModel, file),
                                        ),
                                      )
                                      .toList(),
                                ),
                );
              },
            ),

            SizedBox(height: SizeTokens.spaceMD),

            // ── Custom fields ────────────────────────────────────────
            if (customFields != null && customFields.isNotEmpty)
              _SectionCard(
                title: l10n.appointmentDetailCustomFields,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: customFields.entries.map((entry) {
                    final value = entry.value;
                    final displayValue = value is List
                        ? value.join(', ')
                        : value?.toString() ?? '—';
                    return Padding(
                      padding: EdgeInsets.only(bottom: SizeTokens.spaceSM),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.spaceXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(SizeTokens.radiusXS),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          SizedBox(width: SizeTokens.spaceSM),
                          Expanded(
                            child: Text(
                              displayValue,
                              style: TextStyle(
                                fontSize: SizeTokens.fontMD,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: SizeTokens.spaceXXL),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final Widget? trailingAction;

  const _SectionCard({
    required this.title,
    required this.child,
    this.onEdit,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.paddingXL),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusXL),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: SizeTokens.fontSM,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (trailingAction != null) trailingAction!,
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_rounded,
                      size: SizeTokens.iconSM,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: SizeTokens.spaceMD),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: SizeTokens.iconSM, color: AppTheme.textSecondary),
        SizedBox(width: SizeTokens.spaceSM),
        Text(
          '$label:  ',
          style: TextStyle(
            fontSize: SizeTokens.fontSM,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultFileTile extends StatelessWidget {
  final AppointmentResultFileModel file;
  final AppStrings l10n;
  final bool isLoadingView;
  final bool isLoadingDownload;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _ResultFileTile({
    required this.file,
    required this.l10n,
    required this.isLoadingView,
    required this.isLoadingDownload,
    required this.onView,
    required this.onDownload,
    required this.onDelete,
  });

  bool get _isBusy => isLoadingView || isLoadingDownload;

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  bool get _isPdf {
    if (file.mime == 'application/pdf') return true;
    return (file.originalName ?? '').toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeTokens.spaceSM),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(SizeTokens.radiusSM),
          border: Border.all(color: AppTheme.border),
        ),
        child: ListTile(
          onTap: _isBusy ? null : (_isPdf ? onView : onDownload),
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingMD,
            vertical: SizeTokens.spaceXS,
          ),
          leading: Icon(
            _isPdf
                ? Icons.picture_as_pdf_rounded
                : Icons.insert_drive_file_rounded,
            size: SizeTokens.iconMD,
            color: _isPdf ? AppTheme.error : AppTheme.primary,
          ),
          title: Text(
            file.originalName ?? '—',
            style: TextStyle(
              fontSize: SizeTokens.fontSM,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: file.sizeBytes != null
              ? Text(
                  _formatSize(file.sizeBytes),
                  style: TextStyle(
                    fontSize: SizeTokens.fontXS,
                    color: AppTheme.textSecondary,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PDF: görüntüle butonu
              if (_isPdf) ...
                [
                  if (isLoadingView)
                    SizedBox(
                      width: SizeTokens.iconSM,
                      height: SizeTokens.iconSM,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.visibility_rounded,
                        size: SizeTokens.iconSM,
                        color: AppTheme.primary,
                      ),
                      tooltip: l10n.pdfViewerOpen,
                      onPressed: _isBusy ? null : onView,
                    ),
                ],
              // İndir butonu (her zaman)
              if (isLoadingDownload)
                SizedBox(
                  width: SizeTokens.iconSM,
                  height: SizeTokens.iconSM,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textSecondary,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.download_rounded,
                    size: SizeTokens.iconSM,
                    color: AppTheme.primary,
                  ),
                  tooltip: l10n.appointmentResultFilesDownload,
                  onPressed: _isBusy ? null : onDownload,
                ),
              SizedBox(width: SizeTokens.spaceXS),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: SizeTokens.iconSM,
                  color: AppTheme.error,
                ),
                tooltip: l10n.appointmentResultFilesDelete,
                onPressed: _isBusy ? null : onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
