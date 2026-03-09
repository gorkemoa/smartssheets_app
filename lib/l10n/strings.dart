import 'package:flutter/widgets.dart';

/// Tek dosyada tüm çeviriler.
/// Her anahtar için: {'tr': '...', 'en': '...'}
/// Yeni metin eklemek için sadece _data map'ine satır eklenir.
class AppStrings {
  final String _lang;

  const AppStrings._(this._lang);

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AppStrings._(code == 'tr' ? 'tr' : 'en');
  }

  String _t(String key) => _data[key]?[_lang] ?? _data[key]?['en'] ?? key;

  String _tp(String key, Map<String, String> args) {
    var s = _t(key);
    args.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }

  // ─── Onboarding ────────────────────────────────────────────────────────────
  String get onboardingSplashTitle => _t('onboardingSplashTitle');
  String get onboardingPage2Text => _t('onboardingPage2Text');
  String get onboardingPage3Text => _t('onboardingPage3Text');
  String get onboardingBtnExplore => _t('onboardingBtnExplore');
  String get onboardingBtnContinue => _t('onboardingBtnContinue');
  String get onboardingBtnGetStarted => _t('onboardingBtnGetStarted');

  // ─── Login ─────────────────────────────────────────────────────────────────
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginEmailLabel => _t('loginEmailLabel');
  String get loginEmailHint => _t('loginEmailHint');
  String get loginPasswordLabel => _t('loginPasswordLabel');
  String get loginPasswordHint => _t('loginPasswordHint');
  String get loginButton => _t('loginButton');
  String get loginNoAccount => _t('loginNoAccount');
  String get loginSignUp => _t('loginSignUp');
  String loginWelcomeBack(String name) =>
      _tp('loginWelcomeBack', {'name': name});

  // ─── Register ──────────────────────────────────────────────────────────────
  String get registerTitle => _t('registerTitle');
  String get registerSubtitle => _t('registerSubtitle');
  String get registerNameLabel => _t('registerNameLabel');
  String get registerNameHint => _t('registerNameHint');
  String get registerEmailLabel => _t('registerEmailLabel');
  String get registerEmailHint => _t('registerEmailHint');
  String get registerPhoneLabel => _t('registerPhoneLabel');
  String get registerPhoneHint => _t('registerPhoneHint');
  String get registerPasswordLabel => _t('registerPasswordLabel');
  String get registerPasswordHint => _t('registerPasswordHint');
  String get registerPasswordConfirmLabel => _t('registerPasswordConfirmLabel');
  String get registerPasswordConfirmHint => _t('registerPasswordConfirmHint');
  String get registerButton => _t('registerButton');
  String get registerHasAccount => _t('registerHasAccount');
  String get registerSignIn => _t('registerSignIn');
  String registerWelcome(String name) => _tp('registerWelcome', {'name': name});

  // ─── Validators ────────────────────────────────────────────────────────────
  String get validatorEmailEmpty => _t('validatorEmailEmpty');
  String get validatorEmailInvalid => _t('validatorEmailInvalid');
  String get validatorPasswordEmpty => _t('validatorPasswordEmpty');
  String get validatorPasswordTooShort => _t('validatorPasswordTooShort');
  String get validatorPasswordConfirmEmpty =>
      _t('validatorPasswordConfirmEmpty');
  String get validatorPasswordMismatch => _t('validatorPasswordMismatch');
  String get validatorNameEmpty => _t('validatorNameEmpty');
  String get validatorNameTooShort => _t('validatorNameTooShort');
  String get validatorPhoneEmpty => _t('validatorPhoneEmpty');
  String get validatorPhoneInvalid => _t('validatorPhoneInvalid');

  // ─── Home ──────────────────────────────────────────────────────────────────
  String homeGreeting(String name) => _tp('homeGreeting', {'name': name});
  String get homeBrandTitle => _t('homeBrandTitle');
  String get homePlanLabel => _t('homePlanLabel');
  String get homeSubscriptionStatusLabel => _t('homeSubscriptionStatusLabel');
  String get homeSubscriptionActive => _t('homeSubscriptionActive');
  String get homeSubscriptionInactive => _t('homeSubscriptionInactive');
  String get homeSubscriptionExpires => _t('homeSubscriptionExpires');
  String get homeMemberLimitLabel => _t('homeMemberLimitLabel');
  String get homeRoleLabel => _t('homeRoleLabel');
  String get homePermissionsTitle => _t('homePermissionsTitle');
  String get homeLogout => _t('homeLogout');
  String get homeRetry => _t('homeRetry');
  String get homeTimezoneLabel => _t('homeTimezoneLabel');
  String get homePermCreateAppointment => _t('homePermCreateAppointment');
  String get homePermUploadResult => _t('homePermUploadResult');
  String get homePermChangeStatus => _t('homePermChangeStatus');
  String get homePermManageMembers => _t('homePermManageMembers');
  String get homePermManageStatuses => _t('homePermManageStatuses');
  String get homePermManageAppointmentFields =>
      _t('homePermManageAppointmentFields');
  String get homeMembershipsTitle => _t('homeMembershipsTitle');
  String get homeNoMemberships => _t('homeNoMemberships');
  String get homeNoBrandTitle => _t('homeNoBrandTitle');
  String get homeNoBrandSubtitle => _t('homeNoBrandSubtitle');
  String get homeNoBrandButton => _t('homeNoBrandButton');
  String get homeErrorTitle => _t('homeErrorTitle');
  String get homeDashboardQuickActions => _t('homeDashboardQuickActions');
  String get homeQuickAppointments => _t('homeQuickAppointments');
  String get homeQuickBrandInfo => _t('homeQuickBrandInfo');

  // ─── Billing ──────────────────────────────────────────────────────────────
  String get homeBillingTitle => _t('homeBillingTitle');
  String get homeBillingStatusLabel => _t('homeBillingStatusLabel');
  String get homeBillingPlanLabel => _t('homeBillingPlanLabel');
  String get homeBillingExpiresLabel => _t('homeBillingExpiresLabel');
  String get homeBillingTrialLabel => _t('homeBillingTrialLabel');
  String get homeBillingLockedLabel => _t('homeBillingLockedLabel');
  String get homeBillingMemberLimitLabel => _t('homeBillingMemberLimitLabel');
  String get homeBillingPriceLabel => _t('homeBillingPriceLabel');

  // ─── Brand Info page ──────────────────────────────────────────────────
  String get brandInfoTitle => _t('brandInfoTitle');
  String get brandInfoMembers => _t('brandInfoMembers');
  String get brandInfoStatuses => _t('brandInfoStatuses');
  String get brandInfoFields => _t('brandInfoFields');
  String get seeAll => _t('seeAll');

  // ─── Home Stats ────────────────────────────────────────────────────────────
  String get homeStatsTitle => _t('homeStatsTitle');
  String get homeStatsTotalLabel => _t('homeStatsTotalLabel');
  String get homeStatsThisMonthLabel => _t('homeStatsThisMonthLabel');
  String get homeStatsActiveLabel => _t('homeStatsActiveLabel');
  String get homeStatsInvalidLabel => _t('homeStatsInvalidLabel');
  String get homeStatsUpcoming7DaysLabel => _t('homeStatsUpcoming7DaysLabel');
  String get homeStatsMonthlyTitle => _t('homeStatsMonthlyTitle');
  String get homeStatsByStatusTitle => _t('homeStatsByStatusTitle');
  String get homeUpcomingTitle => _t('homeUpcomingTitle');
  String get homeUpcomingEmpty => _t('homeUpcomingEmpty');

  // ─── Navigation ────────────────────────────────────────────────────────────
  String get navHome => _t('navHome');
  String get navAppointments => _t('navAppointments');
  String get navMembers => _t('navMembers');
  String get navProfile => _t('navProfile');
  String get navComingSoon => _t('navComingSoon');

  // ─── Profile ───────────────────────────────────────────────────────────────
  String get profileTitle => _t('profileTitle');
  String get profileEmailLabel => _t('profileEmailLabel');
  String get profilePhoneLabel => _t('profilePhoneLabel');
  String get profileLogout => _t('profileLogout');
  String get profileRetry => _t('profileRetry');
  String get profileMembershipsTitle => _t('profileMembershipsTitle');
  String get profileRoleLabel => _t('profileRoleLabel');
  String get profilePermissionsTitle => _t('profilePermissionsTitle');
  String get profileNoMemberships => _t('profileNoMemberships');

  String get profileSectionAccountHelp => _t('profileSectionAccountHelp');
  String get profileUserInformation => _t('profileUserInformation');
  String get profileChangePassword => _t('profileChangePassword');

  String get profileSubscriptionActive => _t('profileSubscriptionActive');
  String get profileSubscriptionInactive => _t('profileSubscriptionInactive');
  String get profileSubscriptionExpires => _t('profileSubscriptionExpires');
  String get profilePlanLabel => _t('profilePlanLabel');
  String get profileMemberLimitLabel => _t('profileMemberLimitLabel');
  String get profileTimezoneLabel => _t('profileTimezoneLabel');
  String get profilePermCreateAppointment => _t('profilePermCreateAppointment');
  String get profilePermUploadResult => _t('profilePermUploadResult');
  String get profilePermChangeStatus => _t('profilePermChangeStatus');
  String get profilePermManageMembers => _t('profilePermManageMembers');
  String get profilePermManageStatuses => _t('profilePermManageStatuses');
  String get profilePermManageAppointmentFields =>
      _t('profilePermManageAppointmentFields');

  // ─── Brand Form ─────────────────────────────────────────────────────────────
  String get homeBrandCreateTitle => _t('homeBrandCreateTitle');
  String get homeBrandEditTitle => _t('homeBrandEditTitle');
  String get homeBrandNameLabel => _t('homeBrandNameLabel');
  String get homeBrandNameHint => _t('homeBrandNameHint');
  String get homeBrandTimezoneLabel => _t('homeBrandTimezoneLabel');
  String get homeBrandTimezoneHint => _t('homeBrandTimezoneHint');
  String get homeBrandCreateButton => _t('homeBrandCreateButton');
  String get homeBrandSaveButton => _t('homeBrandSaveButton');
  String get homeBrandEditTooltip => _t('homeBrandEditTooltip');
  String get homeBrandNameEmpty => _t('homeBrandNameEmpty');
  String get homeBrandCreateSuccess => _t('homeBrandCreateSuccess');
  String get homeBrandUpdateSuccess => _t('homeBrandUpdateSuccess');

  // ─── Appointments ──────────────────────────────────────────────────────────
  String get appointmentsTitle => _t('appointmentsTitle');

  // ─── Members ───────────────────────────────────────────────────────────────
  String get membersTitle => _t('membersTitle');
  String get membersEmpty => _t('membersEmpty');
  String get membersRetry => _t('membersRetry');
  String get membersSelectBrand => _t('membersSelectBrand');
  String get membersRoleOwner => _t('membersRoleOwner');
  String get membersRoleAdmin => _t('membersRoleAdmin');
  String get membersRoleMember => _t('membersRoleMember');
  String get membersStatusActive => _t('membersStatusActive');
  String get membersStatusInactive => _t('membersStatusInactive');
  String get membersPermissionsTitle => _t('membersPermissionsTitle');
  String get membersPermCreateAppointment => _t('membersPermCreateAppointment');
  String get membersPermUploadResult => _t('membersPermUploadResult');
  String get membersPermChangeStatus => _t('membersPermChangeStatus');
  String get membersPermManageMembers => _t('membersPermManageMembers');
  String get membersPermManageStatuses => _t('membersPermManageStatuses');
  String get membersPermManageAppointmentFields =>
      _t('membersPermManageAppointmentFields');
  // Create / Edit member form
  String get memberFormCreateTitle => _t('memberFormCreateTitle');
  String get memberFormEditTitle => _t('memberFormEditTitle');
  String get memberFormNameLabel => _t('memberFormNameLabel');
  String get memberFormNameHint => _t('memberFormNameHint');
  String get memberFormEmailLabel => _t('memberFormEmailLabel');
  String get memberFormEmailHint => _t('memberFormEmailHint');
  String get memberFormPhoneLabel => _t('memberFormPhoneLabel');
  String get memberFormPhoneHint => _t('memberFormPhoneHint');
  String get memberFormPasswordLabel => _t('memberFormPasswordLabel');
  String get memberFormPasswordHint => _t('memberFormPasswordHint');
  String get memberFormRoleLabel => _t('memberFormRoleLabel');
  String get memberFormStatusLabel => _t('memberFormStatusLabel');
  String get memberFormStatusActive => _t('memberFormStatusActive');
  String get memberFormStatusInactive => _t('memberFormStatusInactive');
  String get memberFormPermissionsTitle => _t('memberFormPermissionsTitle');
  String get memberFormRolePermissionsTitle =>
      _t('memberFormRolePermissionsTitle');
  String get memberFormNextButton => _t('memberFormNextButton');
  String get memberFormBackButton => _t('memberFormBackButton');
  String get memberFormSaveButton => _t('memberFormSaveButton');
  String get memberFormCreateButton => _t('memberFormCreateButton');
  String get memberFormDeleteButton => _t('memberFormDeleteButton');
  String get memberFormDeleteConfirmTitle => _t('memberFormDeleteConfirmTitle');
  String get memberFormDeleteConfirmMessage =>
      _t('memberFormDeleteConfirmMessage');
  String get memberFormDeleteConfirm => _t('memberFormDeleteConfirm');
  String get memberFormDeleteCancel => _t('memberFormDeleteCancel');
  String get memberCreateSuccess => _t('memberCreateSuccess');
  String get memberUpdateSuccess => _t('memberUpdateSuccess');
  String get memberDeleteSuccess => _t('memberDeleteSuccess');

  // ─── Invitations ───────────────────────────────────────────────────────────
  String get invitationsTitle => _t('invitationsTitle');
  String get invitationsEmpty => _t('invitationsEmpty');
  String get invitationsRetry => _t('invitationsRetry');
  String get invitationsNavButton => _t('invitationsNavButton');
  String get invitationEmailLabel => _t('invitationEmailLabel');
  String get invitationEmailHint => _t('invitationEmailHint');
  String get invitationRoleLabel => _t('invitationRoleLabel');
  String get invitationPermissionsTitle => _t('invitationPermissionsTitle');
  String get invitationFormCreateTitle => _t('invitationFormCreateTitle');
  String get invitationFormCreateButton => _t('invitationFormCreateButton');
  String get invitationExpiresLabel => _t('invitationExpiresLabel');
  String get invitationAcceptedLabel => _t('invitationAcceptedLabel');
  String get invitationPendingLabel => _t('invitationPendingLabel');
  String get invitationResendButton => _t('invitationResendButton');
  String get invitationDeleteButton => _t('invitationDeleteButton');
  String get invitationDeleteConfirmTitle => _t('invitationDeleteConfirmTitle');
  String get invitationDeleteConfirmMessage =>
      _t('invitationDeleteConfirmMessage');
  String get invitationDeleteConfirm => _t('invitationDeleteConfirm');
  String get invitationDeleteCancel => _t('invitationDeleteCancel');
  String get invitationCreateSuccess => _t('invitationCreateSuccess');
  String get invitationResendSuccess => _t('invitationResendSuccess');
  String get invitationDeleteSuccess => _t('invitationDeleteSuccess');

  // ─── Appointment Statuses ────────────────────────────────────────────
  String get statusesTitle => _t('statusesTitle');
  String get statusesEmpty => _t('statusesEmpty');
  String get statusesRetry => _t('statusesRetry');
  String get statusesNavButton => _t('statusesNavButton');
  String get statusFormCreateTitle => _t('statusFormCreateTitle');
  String get statusFormEditTitle => _t('statusFormEditTitle');
  String get statusFormNameLabel => _t('statusFormNameLabel');
  String get statusFormNameHint => _t('statusFormNameHint');
  String get statusFormColorLabel => _t('statusFormColorLabel');
  String get statusFormSortOrderLabel => _t('statusFormSortOrderLabel');
  String get statusFormSortOrderHint => _t('statusFormSortOrderHint');
  String get statusFormStatusTypeLabel => _t('statusFormStatusTypeLabel');
  String get statusFormIsDefaultLabel => _t('statusFormIsDefaultLabel');
  String get statusFormIsActiveLabel => _t('statusFormIsActiveLabel');
  String get statusFormCreateButton => _t('statusFormCreateButton');
  String get statusFormSaveButton => _t('statusFormSaveButton');
  String get statusFormDeleteButton => _t('statusFormDeleteButton');
  String get statusFormDeleteConfirmTitle => _t('statusFormDeleteConfirmTitle');
  String get statusFormDeleteConfirmMessage =>
      _t('statusFormDeleteConfirmMessage');
  String get statusFormDeleteConfirm => _t('statusFormDeleteConfirm');
  String get statusFormDeleteCancel => _t('statusFormDeleteCancel');
  String get statusTypeNeutral => _t('statusTypeNeutral');
  String get statusTypeActive => _t('statusTypeActive');
  String get statusTypeInvalid => _t('statusTypeInvalid');
  String get statusDefaultBadge => _t('statusDefaultBadge');
  String get statusCreateSuccess => _t('statusCreateSuccess');
  String get statusUpdateSuccess => _t('statusUpdateSuccess');
  String get statusDeleteSuccess => _t('statusDeleteSuccess');

  // ─── Appointment Custom Fields ───────────────────────────────────────
  String get fieldsTitle => _t('fieldsTitle');
  String get fieldsEmpty => _t('fieldsEmpty');
  String get fieldsRetry => _t('fieldsRetry');
  String get fieldsNavButton => _t('fieldsNavButton');
  String get fieldFormCreateTitle => _t('fieldFormCreateTitle');
  String get fieldFormEditTitle => _t('fieldFormEditTitle');
  String get fieldKeyLabel => _t('fieldKeyLabel');
  String get fieldKeyHint => _t('fieldKeyHint');
  String get fieldLabelLabel => _t('fieldLabelLabel');
  String get fieldLabelHint => _t('fieldLabelHint');
  String get fieldTypeLabel => _t('fieldTypeLabel');
  String get fieldSortOrderLabel => _t('fieldSortOrderLabel');
  String get fieldSortOrderHint => _t('fieldSortOrderHint');
  String get fieldHelpTextLabel => _t('fieldHelpTextLabel');
  String get fieldHelpTextHint => _t('fieldHelpTextHint');
  String get fieldRequiredLabel => _t('fieldRequiredLabel');
  String get fieldIsActiveLabel => _t('fieldIsActiveLabel');
  String get fieldTypeText => _t('fieldTypeText');
  String get fieldTypeNumber => _t('fieldTypeNumber');
  String get fieldTypeSelect => _t('fieldTypeSelect');
  String get fieldTypeCheckbox => _t('fieldTypeCheckbox');
  String get fieldTypeDate => _t('fieldTypeDate');
  String get fieldOptionsTitle => _t('fieldOptionsTitle');
  String get fieldOptionValueLabel => _t('fieldOptionValueLabel');
  String get fieldOptionLabelLabel => _t('fieldOptionLabelLabel');
  String get fieldAddOptionButton => _t('fieldAddOptionButton');
  String get fieldValidationsTitle => _t('fieldValidationsTitle');
  String get fieldValidationMinLabel => _t('fieldValidationMinLabel');
  String get fieldValidationMaxLabel => _t('fieldValidationMaxLabel');
  String get fieldFormCreateButton => _t('fieldFormCreateButton');
  String get fieldFormSaveButton => _t('fieldFormSaveButton');
  String get fieldFormDeleteButton => _t('fieldFormDeleteButton');
  String get fieldFormDeleteConfirmTitle => _t('fieldFormDeleteConfirmTitle');
  String get fieldFormDeleteConfirmMessage =>
      _t('fieldFormDeleteConfirmMessage');
  String get fieldFormDeleteConfirm => _t('fieldFormDeleteConfirm');
  String get fieldFormDeleteCancel => _t('fieldFormDeleteCancel');
  String get fieldCreateSuccess => _t('fieldCreateSuccess');
  String get fieldUpdateSuccess => _t('fieldUpdateSuccess');
  String get fieldDeleteSuccess => _t('fieldDeleteSuccess');

  // ─── Appointments (Calendar & CRUD) ────────────────────────────
  String get appointmentsSelectBrand => _t('appointmentsSelectBrand');
  String get appointmentsEmpty => _t('appointmentsEmpty');
  String get appointmentsRetry => _t('appointmentsRetry');
  String get appointmentsNavButton => _t('appointmentsNavButton');
  // Form
  String get appointmentFormCreateTitle => _t('appointmentFormCreateTitle');
  String get appointmentFormEditTitle => _t('appointmentFormEditTitle');
  String get appointmentTitleLabel => _t('appointmentTitleLabel');
  String get appointmentTitleHint => _t('appointmentTitleHint');
  String get appointmentStartsAtLabel => _t('appointmentStartsAtLabel');
  String get appointmentEndsAtLabel => _t('appointmentEndsAtLabel');
  String get appointmentStatusLabel => _t('appointmentStatusLabel');
  String get appointmentNotesLabel => _t('appointmentNotesLabel');
  String get appointmentNotesHint => _t('appointmentNotesHint');
  String get appointmentResultNotesLabel => _t('appointmentResultNotesLabel');
  String get appointmentResultNotesHint => _t('appointmentResultNotesHint');
  String get appointmentAssigneesLabel => _t('appointmentAssigneesLabel');
  String get appointmentCustomFieldsTitle => _t('appointmentCustomFieldsTitle');
  String get appointmentFormCreateButton => _t('appointmentFormCreateButton');
  String get appointmentFormSaveButton => _t('appointmentFormSaveButton');
  // Detail
  String get appointmentDetailTitle => _t('appointmentDetailTitle');
  String get appointmentDetailNotes => _t('appointmentDetailNotes');
  String get appointmentDetailResultNotes => _t('appointmentDetailResultNotes');
  String get appointmentDetailResultNotesEdit =>
      _t('appointmentDetailResultNotesEdit');
  String get appointmentDetailResultNotesEmpty =>
      _t('appointmentDetailResultNotesEmpty');
  String get appointmentResultNotesSuccess =>
      _t('appointmentResultNotesSuccess');
  String get appointmentDetailAssignees => _t('appointmentDetailAssignees');
  String get appointmentDetailCustomFields =>
      _t('appointmentDetailCustomFields');
  String get appointmentDetailCompletedAt => _t('appointmentDetailCompletedAt');
  String get appointmentDetailEdit => _t('appointmentDetailEdit');
  // Snackbars
  String get appointmentCreateSuccess => _t('appointmentCreateSuccess');
  String get appointmentUpdateSuccess => _t('appointmentUpdateSuccess');
  String get appointmentDeleteSuccess => _t('appointmentDeleteSuccess');
  String get appointmentAssignSuccess => _t('appointmentAssignSuccess');
  // Result files
  String get appointmentResultFilesTitle => _t('appointmentResultFilesTitle');
  String get appointmentResultFilesEmpty => _t('appointmentResultFilesEmpty');
  String get appointmentResultFilesUpload => _t('appointmentResultFilesUpload');
  String get appointmentResultFilesDownload =>
      _t('appointmentResultFilesDownload');
  String get appointmentResultFilesDelete => _t('appointmentResultFilesDelete');
  String get appointmentResultFilesDeleteConfirmTitle =>
      _t('appointmentResultFilesDeleteConfirmTitle');
  String get appointmentResultFilesDeleteConfirmMessage =>
      _t('appointmentResultFilesDeleteConfirmMessage');
  String get appointmentResultFilesDeleteConfirmCancel =>
      _t('appointmentResultFilesDeleteConfirmCancel');
  String get appointmentResultFilesDeleteConfirmAction =>
      _t('appointmentResultFilesDeleteConfirmAction');
  String get appointmentResultFilesDeleteSuccess =>
      _t('appointmentResultFilesDeleteSuccess');
  String get appointmentResultFilesUploadSuccess =>
      _t('appointmentResultFilesUploadSuccess');
  String get appointmentResultFilesDownloadError =>
      _t('appointmentResultFilesDownloadError');
  // PDF Viewer
  String get pdfViewerTitle => _t('pdfViewerTitle');
  String get pdfViewerLoading => _t('pdfViewerLoading');
  String get pdfViewerError => _t('pdfViewerError');
  String get pdfViewerZoomIn => _t('pdfViewerZoomIn');
  String get pdfViewerZoomOut => _t('pdfViewerZoomOut');
  String get pdfViewerOpen => _t('pdfViewerOpen');
  // Delete confirm dialog
  String get appointmentDeleteConfirmTitle =>
      _t('appointmentDeleteConfirmTitle');
  String get appointmentDeleteConfirmMessage =>
      _t('appointmentDeleteConfirmMessage');
  String get appointmentDeleteConfirmCancel =>
      _t('appointmentDeleteConfirmCancel');
  String get appointmentDeleteConfirmAction =>
      _t('appointmentDeleteConfirmAction');
  // Loading
  String get appointmentLoadingFields => _t('appointmentLoadingFields');
  String get appointmentLoadingMembers => _t('appointmentLoadingMembers');
  String get appointmentNoStatus => _t('appointmentNoStatus');
  // Date/time picker helpers
  String get appointmentStartDateButton => _t('appointmentStartDateButton');
  String get appointmentEndDateButton => _t('appointmentEndDateButton');
  String get appointmentStartTimeButton => _t('appointmentStartTimeButton');
  String get appointmentEndTimeButton => _t('appointmentEndTimeButton');
  // Cupertino picker & select box
  String get appointmentPickerDone => _t('appointmentPickerDone');
  String get appointmentSectionBasicInfo => _t('appointmentSectionBasicInfo');
  String get appointmentSectionDateTime => _t('appointmentSectionDateTime');
  String get appointmentAssigneesNoneSelected =>
      _t('appointmentAssigneesNoneSelected');
  String appointmentAssigneesNSelected(int n) =>
      _tp('appointmentAssigneesNSelected', {'n': n.toString()});

  // ─── Translations ──────────────────────────────────────────────────────────
  // Format: 'key': {'tr': '...', 'en': '...'}
  // ──────────────────────────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _data = {
    // Onboarding
    'onboardingSplashTitle': {
      'tr': 'İş süreçlerinizi\nkolaylaştırın.',
      'en': 'Streamline your\nbusiness processes.',
    },
    'onboardingPage2Text': {
      'tr': 'Tüm randevularınızı\ntek yerden yönetin.',
      'en': 'Manage all your\nappointments in one place.',
    },
    'onboardingPage3Text': {
      'tr': 'Müşterilerinizle\nher an bağlantıda kalın.',
      'en': 'Stay connected with\nyour customers anytime.',
    },
    'onboardingBtnExplore': {'tr': 'Keşfet', 'en': 'Explore'},
    'onboardingBtnContinue': {'tr': 'Devam Et', 'en': 'Continue'},
    'onboardingBtnGetStarted': {'tr': 'Başlayalım', 'en': "Let's Begin"},

    // Login
    'loginTitle': {'tr': 'Hoş Geldiniz', 'en': 'Welcome'},
    'loginSubtitle': {
      'tr': 'Hesabınıza giriş yapın',
      'en': 'Sign in to your account',
    },
    'loginEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'loginEmailHint': {'tr': 'ornek@email.com', 'en': 'example@email.com'},
    'loginPasswordLabel': {'tr': 'Şifre', 'en': 'Password'},
    'loginPasswordHint': {'tr': '••••••••', 'en': '••••••••'},
    'loginButton': {'tr': 'Giriş Yap', 'en': 'Sign In'},
    'loginNoAccount': {
      'tr': 'Hesabınız yok mu? ',
      'en': "Don't have an account? ",
    },
    'loginSignUp': {'tr': 'Kayıt Ol', 'en': 'Sign Up'},
    'loginWelcomeBack': {
      'tr': 'Hoş geldiniz, {name}!',
      'en': 'Welcome, {name}!',
    },

    // Register
    'registerTitle': {'tr': 'Hesap Oluştur', 'en': 'Create Account'},
    'registerSubtitle': {
      'tr': 'Ücretsiz hesabınızı şimdi oluşturun',
      'en': 'Create your free account now',
    },
    'registerNameLabel': {'tr': 'Ad Soyad', 'en': 'Full Name'},
    'registerNameHint': {
      'tr': 'Adınızı ve soyadınızı girin',
      'en': 'Enter your full name',
    },
    'registerEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'registerEmailHint': {'tr': 'ornek@email.com', 'en': 'example@email.com'},
    'registerPhoneLabel': {'tr': 'Telefon', 'en': 'Phone'},
    'registerPhoneHint': {'tr': '+905551234567', 'en': '+15551234567'},
    'registerPasswordLabel': {'tr': 'Şifre', 'en': 'Password'},
    'registerPasswordHint': {'tr': '••••••••', 'en': '••••••••'},
    'registerPasswordConfirmLabel': {
      'tr': 'Şifre Tekrar',
      'en': 'Confirm Password',
    },
    'registerPasswordConfirmHint': {'tr': '••••••••', 'en': '••••••••'},
    'registerButton': {'tr': 'Kayıt Ol', 'en': 'Sign Up'},
    'registerHasAccount': {
      'tr': 'Zaten hesabınız var mı? ',
      'en': 'Already have an account? ',
    },
    'registerSignIn': {'tr': 'Giriş Yap', 'en': 'Sign In'},
    'registerWelcome': {
      'tr': 'Hoş geldiniz, {name}!',
      'en': 'Welcome, {name}!',
    },

    // Validators
    'validatorEmailEmpty': {
      'tr': 'E-posta adresi boş olamaz.',
      'en': 'Email cannot be empty.',
    },
    'validatorEmailInvalid': {
      'tr': 'Geçerli bir e-posta adresi girin.',
      'en': 'Please enter a valid email address.',
    },
    'validatorPasswordEmpty': {
      'tr': 'Şifre boş olamaz.',
      'en': 'Password cannot be empty.',
    },
    'validatorPasswordTooShort': {
      'tr': 'Şifre en az 6 karakter olmalıdır.',
      'en': 'Password must be at least 6 characters.',
    },
    'validatorPasswordConfirmEmpty': {
      'tr': 'Şifre tekrarı boş olamaz.',
      'en': 'Password confirmation cannot be empty.',
    },
    'validatorPasswordMismatch': {
      'tr': 'Şifreler eşleşmiyor.',
      'en': 'Passwords do not match.',
    },
    'validatorNameEmpty': {
      'tr': 'Ad Soyad boş olamaz.',
      'en': 'Full name cannot be empty.',
    },
    'validatorNameTooShort': {
      'tr': 'Ad Soyad en az 2 karakter olmalıdır.',
      'en': 'Full name must be at least 2 characters.',
    },
    'validatorPhoneEmpty': {
      'tr': 'Telefon numarası boş olamaz.',
      'en': 'Phone number cannot be empty.',
    },
    'validatorPhoneInvalid': {
      'tr': 'Geçerli bir telefon numarası girin.',
      'en': 'Please enter a valid phone number.',
    },

    // Home
    'homeGreeting': {'tr': 'Merhaba, {name}!', 'en': 'Hello, {name}!'},
    'homeBrandTitle': {'tr': 'Markanız', 'en': 'Your Brand'},
    'homePlanLabel': {'tr': 'Plan', 'en': 'Plan'},
    'homeSubscriptionStatusLabel': {
      'tr': 'Abonelik Durumu',
      'en': 'Subscription Status',
    },
    'homeSubscriptionActive': {'tr': 'Aktif', 'en': 'Active'},
    'homeSubscriptionInactive': {'tr': 'Pasif', 'en': 'Inactive'},
    'homeSubscriptionExpires': {
      'tr': 'Abonelik Bitiyor',
      'en': 'Subscription Expires',
    },
    'homeMemberLimitLabel': {'tr': 'Üye Limiti', 'en': 'Member Limit'},
    'homeRoleLabel': {'tr': 'Rol', 'en': 'Role'},
    'homePermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'homeLogout': {'tr': 'Çıkış Yap', 'en': 'Log Out'},
    'homeRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'homeTimezoneLabel': {'tr': 'Zaman Dilimi', 'en': 'Timezone'},
    'homePermCreateAppointment': {
      'tr': 'Randevu Oluştur',
      'en': 'Create Appointment',
    },
    'homePermUploadResult': {'tr': 'Sonuç Yükle', 'en': 'Upload Result'},
    'homePermChangeStatus': {'tr': 'Durum Değiştir', 'en': 'Change Status'},
    'homePermManageMembers': {'tr': 'Üye Yönet', 'en': 'Manage Members'},
    'homePermManageStatuses': {'tr': 'Durum Yönet', 'en': 'Manage Statuses'},
    'homePermManageAppointmentFields': {
      'tr': 'Randevu Alanları',
      'en': 'Appointment Fields',
    },
    'homeMembershipsTitle': {'tr': 'Üyeliklerim', 'en': 'My Memberships'},
    'homeNoMemberships': {
      'tr': 'Henüz bir üyeliğiniz yok.',
      'en': 'You have no memberships yet.',
    },
    'homeNoBrandTitle': {
      'tr': 'Henüz bir markanız yok',
      'en': 'You don\'t have a brand yet',
    },
    'homeNoBrandSubtitle': {
      'tr': 'Başlamak için ilk markanızı oluşturun.',
      'en': 'Create your first brand to get started.',
    },
    'homeNoBrandButton': {'tr': 'Marka Oluştur', 'en': 'Create Brand'},
    'homeErrorTitle': {'tr': 'Bir hata oluştu', 'en': 'An error occurred'},

    // Home Stats
    'homeStatsTitle': {'tr': 'İstatistikler', 'en': 'Statistics'},
    'homeStatsTotalLabel': {'tr': 'Toplam Randevu', 'en': 'Total Appointments'},
    'homeStatsThisMonthLabel': {'tr': 'Bu Ay', 'en': 'This Month'},
    'homeStatsActiveLabel': {'tr': 'Aktif', 'en': 'Active'},
    'homeStatsInvalidLabel': {'tr': 'İptal', 'en': 'Canceled'},
    'homeStatsUpcoming7DaysLabel': {'tr': '7 Gün İçinde', 'en': 'Next 7 Days'},
    'homeStatsMonthlyTitle': {
      'tr': 'Aylık Randevu',
      'en': 'Monthly Appointments',
    },
    'homeStatsByStatusTitle': {'tr': 'Durum Dağılımı', 'en': 'By Status'},
    'homeUpcomingTitle': {
      'tr': 'Yaklaşan Randevular',
      'en': 'Upcoming Appointments',
    },
    'homeUpcomingEmpty': {
      'tr': 'Yaklaşan randevu yok',
      'en': 'No upcoming appointments',
    },
    'homeDashboardQuickActions': {
      'tr': 'Hızlı İşlemler',
      'en': 'Quick Actions',
    },
    'homeQuickAppointments': {'tr': 'Randevular', 'en': 'Appointments'},
    'homeQuickBrandInfo': {'tr': 'Marka Bilgisi', 'en': 'Brand Info'},
    'homeQuickMembers': {'tr': 'Üyeler', 'en': 'Members'},
    'homeQuickStatuses': {'tr': 'Durumlar', 'en': 'Statuses'},
    'homeQuickFields': {'tr': 'Alanlar', 'en': 'Fields'},
    // Billing
    'homeBillingTitle': {'tr': 'Paket Bilgisi', 'en': 'Subscription'},
    'homeBillingStatusLabel': {'tr': 'Durum', 'en': 'Status'},
    'homeBillingPlanLabel': {'tr': 'Plan', 'en': 'Plan'},
    'homeBillingExpiresLabel': {'tr': 'Bitiş Tarihi', 'en': 'Expires'},
    'homeBillingTrialLabel': {'tr': 'Deneme Sonu', 'en': 'Trial Ends'},
    'homeBillingLockedLabel': {'tr': 'Hesap Kilitli', 'en': 'Account Locked'},
    'homeBillingMemberLimitLabel': {'tr': 'Üye Limiti', 'en': 'Member Limit'},
    'homeBillingPriceLabel': {'tr': 'Fiyat', 'en': 'Price'},
    // Brand Info page
    'brandInfoTitle': {'tr': 'Marka Bilgisi', 'en': 'Brand Info'},
    'brandInfoMembers': {'tr': 'Üyeler', 'en': 'Members'},
    'brandInfoStatuses': {
      'tr': 'Randevu Durumları',
      'en': 'Appointment Statuses',
    },
    'brandInfoFields': {'tr': 'Randevu Alanları', 'en': 'Appointment Fields'},
    'seeAll': {'tr': 'Tümünü Gör', 'en': 'See All'},

    // Navigation
    'navHome': {'tr': 'Anasayfa', 'en': 'Home'},
    'navAppointments': {'tr': 'Randevular', 'en': 'Appointments'},
    'navMembers': {'tr': 'Üyeler', 'en': 'Members'},
    'navProfile': {'tr': 'Profil', 'en': 'Profile'},
    'navComingSoon': {'tr': 'Yakında', 'en': 'Coming Soon'},

    // Profile
    'profileTitle': {'tr': 'Profil', 'en': 'Profile'},
    'profileEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'profilePhoneLabel': {'tr': 'Telefon', 'en': 'Phone'},
    'profileLogout': {'tr': 'Çıkış Yap', 'en': 'Log Out'},
    'profileRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'profileMembershipsTitle': {'tr': 'Üyeliklerim', 'en': 'My Memberships'},
    'profileRoleLabel': {'tr': 'Rol', 'en': 'Role'},
    'profilePermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'profileNoMemberships': {
      'tr': 'Henüz bir üyeliğiniz yok.',
      'en': 'You have no memberships yet.',
    },
    'profileSectionAccountHelp': {'tr': 'Hesap', 'en': 'Account'},
    'profileUserInformation': {
      'tr': 'Kullanıcı Bilgileri',
      'en': 'User Information',
    },
    'profileChangePassword': {'tr': 'Şifre Değiştir', 'en': 'Change Password'},

    'profileSubscriptionActive': {'tr': 'Aktif', 'en': 'Active'},
    'profileSubscriptionInactive': {'tr': 'Pasif', 'en': 'Inactive'},
    'profileSubscriptionExpires': {
      'tr': 'Abonelik Bitiyor',
      'en': 'Subscription Expires',
    },
    'profilePlanLabel': {'tr': 'Plan', 'en': 'Plan'},
    'profileMemberLimitLabel': {'tr': 'Üye Limiti', 'en': 'Member Limit'},
    'profileTimezoneLabel': {'tr': 'Zaman Dilimi', 'en': 'Timezone'},
    'profilePermCreateAppointment': {
      'tr': 'Randevu Oluştur',
      'en': 'Create Appointment',
    },
    'profilePermUploadResult': {'tr': 'Sonuç Yükle', 'en': 'Upload Result'},
    'profilePermChangeStatus': {'tr': 'Durum Değiştir', 'en': 'Change Status'},
    'profilePermManageMembers': {'tr': 'Üye Yönet', 'en': 'Manage Members'},
    'profilePermManageStatuses': {'tr': 'Durum Yönet', 'en': 'Manage Statuses'},
    'profilePermManageAppointmentFields': {
      'tr': 'Randevu Alanları',
      'en': 'Appointment Fields',
    },

    // Brand Form
    'homeBrandCreateTitle': {'tr': 'Marka Oluştur', 'en': 'Create Brand'},
    'homeBrandEditTitle': {'tr': 'Markayı Düzenle', 'en': 'Edit Brand'},
    'homeBrandNameLabel': {'tr': 'Marka Adı', 'en': 'Brand Name'},
    'homeBrandNameHint': {'tr': 'Marka adını girin', 'en': 'Enter brand name'},
    'homeBrandTimezoneLabel': {'tr': 'Zaman Dilimi', 'en': 'Timezone'},
    'homeBrandTimezoneHint': {
      'tr': 'Örn: Europe/Istanbul',
      'en': 'e.g. Europe/Istanbul',
    },
    'homeBrandCreateButton': {'tr': 'Oluştur', 'en': 'Create'},
    'homeBrandSaveButton': {'tr': 'Kaydet', 'en': 'Save'},
    'homeBrandEditTooltip': {'tr': 'Düzenle', 'en': 'Edit'},
    'homeBrandNameEmpty': {
      'tr': 'Marka adı boş olamaz.',
      'en': 'Brand name cannot be empty.',
    },
    'homeBrandCreateSuccess': {
      'tr': 'Marka başarıyla oluşturuldu.',
      'en': 'Brand created successfully.',
    },
    'homeBrandUpdateSuccess': {
      'tr': 'Marka başarıyla güncellendi.',
      'en': 'Brand updated successfully.',
    },

    // Appointments
    'appointmentsTitle': {'tr': 'Randevular', 'en': 'Appointments'},

    // Members
    'membersTitle': {'tr': 'Üyeler', 'en': 'Members'},
    'membersEmpty': {
      'tr': 'Bu markada henüz üye bulunmuyor.',
      'en': 'No members found for this brand.',
    },
    'membersRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'membersSelectBrand': {
      'tr': 'Üyeleri görmek için Anasayfa\'dan bir marka seçin.',
      'en': 'Select a brand from Home to view its members.',
    },
    'membersRoleOwner': {'tr': 'Kurucu', 'en': 'Owner'},
    'membersRoleAdmin': {'tr': 'Yönetici', 'en': 'Admin'},
    'membersRoleMember': {'tr': 'Üye', 'en': 'Member'},
    'membersStatusActive': {'tr': 'Aktif', 'en': 'Active'},
    'membersStatusInactive': {'tr': 'Pasif', 'en': 'Inactive'},
    'membersPermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'membersPermCreateAppointment': {
      'tr': 'Randevu Oluştur',
      'en': 'Create Appointment',
    },
    'membersPermUploadResult': {'tr': 'Sonuç Yükle', 'en': 'Upload Result'},
    'membersPermChangeStatus': {'tr': 'Durum Değiştir', 'en': 'Change Status'},
    'membersPermManageMembers': {'tr': 'Üyeleri Yönet', 'en': 'Manage Members'},
    'membersPermManageStatuses': {
      'tr': 'Durumları Yönet',
      'en': 'Manage Statuses',
    },
    'membersPermManageAppointmentFields': {
      'tr': 'Randevu Alanlarını Yönet',
      'en': 'Manage Appointment Fields',
    },

    // Member Form
    'memberFormCreateTitle': {'tr': 'Yeni Üye Ekle', 'en': 'Add New Member'},
    'memberFormEditTitle': {'tr': 'Üyeyi Düzenle', 'en': 'Edit Member'},
    'memberFormNameLabel': {'tr': 'İsim', 'en': 'Name'},
    'memberFormNameHint': {'tr': 'Demo Üye', 'en': 'Demo Member'},
    'memberFormEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'memberFormEmailHint': {'tr': 'uye@demo.local', 'en': 'member@demo.local'},
    'memberFormPhoneLabel': {
      'tr': 'Telefon (isteğe bağlı)',
      'en': 'Phone (optional)',
    },
    'memberFormPhoneHint': {'tr': '+905550000000', 'en': '+10000000000'},
    'memberFormPasswordLabel': {'tr': 'Şifre', 'en': 'Password'},
    'memberFormPasswordHint': {
      'tr': 'En az 8 karakter',
      'en': 'Min 8 characters',
    },
    'memberFormRoleLabel': {'tr': 'Rol', 'en': 'Role'},
    'memberFormStatusLabel': {'tr': 'Durum', 'en': 'Status'},
    'memberFormStatusActive': {'tr': 'Aktif', 'en': 'Active'},
    'memberFormStatusInactive': {'tr': 'Pasif', 'en': 'Inactive'},
    'memberFormPermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'memberFormRolePermissionsTitle': {
      'tr': 'Rol & İzinler',
      'en': 'Role & Permissions',
    },
    'memberFormNextButton': {'tr': 'İleri', 'en': 'Next'},
    'memberFormBackButton': {'tr': 'Geri', 'en': 'Back'},
    'memberFormSaveButton': {'tr': 'Kaydet', 'en': 'Save'},
    'memberFormCreateButton': {'tr': 'Üye Ekle', 'en': 'Add Member'},
    'memberFormDeleteButton': {'tr': 'Üyeyi Sil', 'en': 'Remove Member'},
    'memberFormDeleteConfirmTitle': {
      'tr': 'Üye Silindi',
      'en': 'Remove Member',
    },
    'memberFormDeleteConfirmMessage': {
      'tr': 'Bu üyeyi silmek istediğinizden emin misiniz?',
      'en': 'Are you sure you want to remove this member?',
    },
    'memberFormDeleteConfirm': {'tr': 'Sil', 'en': 'Remove'},
    'memberFormDeleteCancel': {'tr': 'İptal', 'en': 'Cancel'},
    'memberCreateSuccess': {
      'tr': 'Üye başarıyla eklendi.',
      'en': 'Member added successfully.',
    },
    'memberUpdateSuccess': {
      'tr': 'Üye başarıyla güncellendi.',
      'en': 'Member updated successfully.',
    },
    'memberDeleteSuccess': {
      'tr': 'Üye başarıyla silindi.',
      'en': 'Member removed successfully.',
    },

    // Invitations
    'invitationsTitle': {'tr': 'Davetler', 'en': 'Invitations'},
    'invitationsEmpty': {
      'tr': 'Bu marka için henüz davet bulunmuyor.',
      'en': 'No invitations found for this brand.',
    },
    'invitationsRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'invitationsNavButton': {'tr': 'Davetler', 'en': 'Invitations'},
    'invitationEmailLabel': {'tr': 'E-posta', 'en': 'Email'},
    'invitationEmailHint': {
      'tr': 'davet@ornek.com',
      'en': 'invite@example.com',
    },
    'invitationRoleLabel': {'tr': 'Rol', 'en': 'Role'},
    'invitationPermissionsTitle': {'tr': 'İzinler', 'en': 'Permissions'},
    'invitationFormCreateTitle': {
      'tr': 'Davet Gönder',
      'en': 'Send Invitation',
    },
    'invitationFormCreateButton': {'tr': 'Davet Gönder', 'en': 'Send Invite'},
    'invitationExpiresLabel': {'tr': 'Son Kullanma', 'en': 'Expires'},
    'invitationAcceptedLabel': {'tr': 'Kabul Edildi', 'en': 'Accepted'},
    'invitationPendingLabel': {'tr': 'Bekliyor', 'en': 'Pending'},
    'invitationResendButton': {'tr': 'Yeniden Gönder', 'en': 'Resend'},
    'invitationDeleteButton': {'tr': 'İptal Et', 'en': 'Cancel'},
    'invitationDeleteConfirmTitle': {
      'tr': 'Daveti İptal Et',
      'en': 'Cancel Invitation',
    },
    'invitationDeleteConfirmMessage': {
      'tr': 'Bu daveti iptal etmek istediğinizden emin misiniz?',
      'en': 'Are you sure you want to cancel this invitation?',
    },
    'invitationDeleteConfirm': {'tr': 'İptal Et', 'en': 'Cancel'},
    'invitationDeleteCancel': {'tr': 'Vazgeç', 'en': 'Go Back'},
    'invitationCreateSuccess': {
      'tr': 'Davet başarıyla gönderildi.',
      'en': 'Invitation sent successfully.',
    },
    'invitationResendSuccess': {
      'tr': 'Davet yeniden gönderildi.',
      'en': 'Invitation resent successfully.',
    },
    'invitationDeleteSuccess': {
      'tr': 'Davet başarıyla iptal edildi.',
      'en': 'Invitation cancelled successfully.',
    },

    // Appointment Statuses
    'statusesTitle': {'tr': 'Durum Tanımları', 'en': 'Appointment Statuses'},
    'statusesEmpty': {
      'tr': 'Bu marka için henüz durum tanımı yok.',
      'en': 'No statuses defined for this brand.',
    },
    'statusesRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'statusesNavButton': {'tr': 'Durumlar', 'en': 'Statuses'},
    'statusFormCreateTitle': {'tr': 'Yeni Durum Ekle', 'en': 'Add New Status'},
    'statusFormEditTitle': {'tr': 'Durumu Düzenle', 'en': 'Edit Status'},
    'statusFormNameLabel': {'tr': 'Durum Adı', 'en': 'Status Name'},
    'statusFormNameHint': {'tr': 'Planlandı', 'en': 'Planned'},
    'statusFormColorLabel': {'tr': 'Renk', 'en': 'Color'},
    'statusFormSortOrderLabel': {'tr': 'Sıralama', 'en': 'Sort Order'},
    'statusFormSortOrderHint': {'tr': '1', 'en': '1'},
    'statusFormStatusTypeLabel': {'tr': 'Durum Tipi', 'en': 'Status Type'},
    'statusFormIsDefaultLabel': {'tr': 'Varsayılan', 'en': 'Default Status'},
    'statusFormIsActiveLabel': {'tr': 'Aktif', 'en': 'Active'},
    'statusFormCreateButton': {'tr': 'Ekle', 'en': 'Add'},
    'statusFormSaveButton': {'tr': 'Kaydet', 'en': 'Save'},
    'statusFormDeleteButton': {'tr': 'Durumu Sil', 'en': 'Delete Status'},
    'statusFormDeleteConfirmTitle': {'tr': 'Durum Sil', 'en': 'Delete Status'},
    'statusFormDeleteConfirmMessage': {
      'tr': 'Bu durumu silmek istediğinizden emin misiniz?',
      'en': 'Are you sure you want to delete this status?',
    },
    'statusFormDeleteConfirm': {'tr': 'Sil', 'en': 'Delete'},
    'statusFormDeleteCancel': {'tr': 'İptal', 'en': 'Cancel'},
    'statusTypeNeutral': {'tr': 'Nötr', 'en': 'Neutral'},
    'statusTypeActive': {'tr': 'Aktif', 'en': 'Active'},
    'statusTypeInvalid': {'tr': 'Geçersiz', 'en': 'Invalid'},
    'statusDefaultBadge': {'tr': 'Varsayılan', 'en': 'Default'},
    'statusCreateSuccess': {
      'tr': 'Durum başarıyla eklendi.',
      'en': 'Status added successfully.',
    },
    'statusUpdateSuccess': {
      'tr': 'Durum başarıyla güncellendi.',
      'en': 'Status updated successfully.',
    },
    'statusDeleteSuccess': {
      'tr': 'Durum başarıyla silindi.',
      'en': 'Status deleted successfully.',
    },

    // Appointment Custom Fields
    'fieldsTitle': {'tr': 'Özel Alanlar', 'en': 'Custom Fields'},
    'fieldsEmpty': {
      'tr': 'Bu marka için henüz özel alan tanımlanmamış.',
      'en': 'No custom fields defined for this brand.',
    },
    'fieldsRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'fieldsNavButton': {'tr': 'Özel Alanlar', 'en': 'Custom Fields'},
    'fieldFormCreateTitle': {'tr': 'Yeni Alan Ekle', 'en': 'Add New Field'},
    'fieldFormEditTitle': {'tr': 'Alanı Düzenle', 'en': 'Edit Field'},
    'fieldKeyLabel': {'tr': 'Alan Anahtarı', 'en': 'Field Key'},
    'fieldKeyHint': {'tr': 'ornek_alan', 'en': 'example_field'},
    'fieldLabelLabel': {'tr': 'Etiket', 'en': 'Label'},
    'fieldLabelHint': {'tr': 'Örnek Alan', 'en': 'Example Field'},
    'fieldTypeLabel': {'tr': 'Alan Tipi', 'en': 'Field Type'},
    'fieldSortOrderLabel': {'tr': 'Sıralama', 'en': 'Sort Order'},
    'fieldSortOrderHint': {'tr': '0', 'en': '0'},
    'fieldHelpTextLabel': {'tr': 'Yardım Metni', 'en': 'Help Text'},
    'fieldHelpTextHint': {
      'tr': 'İsteğe bağlı açıklama...',
      'en': 'Optional description...',
    },
    'fieldRequiredLabel': {'tr': 'Zorunlu Alan', 'en': 'Required Field'},
    'fieldIsActiveLabel': {'tr': 'Aktif', 'en': 'Active'},
    'fieldTypeText': {'tr': 'Metin', 'en': 'Text'},
    'fieldTypeNumber': {'tr': 'Sayı', 'en': 'Number'},
    'fieldTypeSelect': {'tr': 'Seçim Listesi', 'en': 'Select'},
    'fieldTypeCheckbox': {'tr': 'Onay Kutusu', 'en': 'Checkbox'},
    'fieldTypeDate': {'tr': 'Tarih', 'en': 'Date'},
    'fieldOptionsTitle': {'tr': 'Seçenekler', 'en': 'Options'},
    'fieldOptionValueLabel': {'tr': 'Değer', 'en': 'Value'},
    'fieldOptionLabelLabel': {'tr': 'Etiket', 'en': 'Label'},
    'fieldAddOptionButton': {'tr': 'Seçenek Ekle', 'en': 'Add Option'},
    'fieldValidationsTitle': {'tr': 'Kısıtlamalar', 'en': 'Validations'},
    'fieldValidationMinLabel': {'tr': 'Min', 'en': 'Min'},
    'fieldValidationMaxLabel': {'tr': 'Maks', 'en': 'Max'},
    'fieldFormCreateButton': {'tr': 'Ekle', 'en': 'Add'},
    'fieldFormSaveButton': {'tr': 'Kaydet', 'en': 'Save'},
    'fieldFormDeleteButton': {'tr': 'Alanı Sil', 'en': 'Delete Field'},
    'fieldFormDeleteConfirmTitle': {'tr': 'Alanı Sil', 'en': 'Delete Field'},
    'fieldFormDeleteConfirmMessage': {
      'tr': 'Bu alanı silmek istediğinizden emin misiniz?',
      'en': 'Are you sure you want to delete this field?',
    },
    'fieldFormDeleteConfirm': {'tr': 'Sil', 'en': 'Delete'},
    'fieldFormDeleteCancel': {'tr': 'İptal', 'en': 'Cancel'},
    'fieldCreateSuccess': {
      'tr': 'Alan başarıyla eklendi.',
      'en': 'Field added successfully.',
    },
    'fieldUpdateSuccess': {
      'tr': 'Alan başarıyla güncellendi.',
      'en': 'Field updated successfully.',
    },
    'fieldDeleteSuccess': {
      'tr': 'Alan başarıyla silindi.',
      'en': 'Field deleted successfully.',
    },

    // Appointments (Calendar & CRUD)
    'appointmentsSelectBrand': {
      'tr': 'Randevuları görmek için ana sayfadan bir marka seçin.',
      'en': 'Select a brand from home to view appointments.',
    },
    'appointmentsEmpty': {
      'tr': 'Bu gün için randevu bulunmuyor.',
      'en': 'No appointments for this day.',
    },
    'appointmentsRetry': {'tr': 'Tekrar Dene', 'en': 'Retry'},
    'appointmentsNavButton': {'tr': 'Randevular', 'en': 'Appointments'},
    'appointmentFormCreateTitle': {
      'tr': 'Yeni Randevu',
      'en': 'New Appointment',
    },
    'appointmentFormEditTitle': {
      'tr': 'Randevuyu Düzenle',
      'en': 'Edit Appointment',
    },
    'appointmentTitleLabel': {'tr': 'Başlık', 'en': 'Title'},
    'appointmentTitleHint': {'tr': 'Saç kesimi', 'en': 'Haircut'},
    'appointmentStartsAtLabel': {'tr': 'Başlangıç', 'en': 'Start'},
    'appointmentEndsAtLabel': {'tr': 'Bitiş', 'en': 'End'},
    'appointmentStatusLabel': {'tr': 'Durum', 'en': 'Status'},
    'appointmentNotesLabel': {'tr': 'Notlar', 'en': 'Notes'},
    'appointmentNotesHint': {
      'tr': 'İsteğe bağlı notlar...',
      'en': 'Optional notes...',
    },
    'appointmentResultNotesLabel': {'tr': 'Sonuç Notu', 'en': 'Result Notes'},
    'appointmentResultNotesHint': {
      'tr': 'Randevu sonucu...',
      'en': 'Appointment result...',
    },
    'appointmentAssigneesLabel': {'tr': 'Atananlar', 'en': 'Assignees'},
    'appointmentCustomFieldsTitle': {
      'tr': 'Özel Alanlar',
      'en': 'Custom Fields',
    },
    'appointmentFormCreateButton': {'tr': 'Oluştur', 'en': 'Create'},
    'appointmentFormSaveButton': {'tr': 'Kaydet', 'en': 'Save'},
    'appointmentDetailTitle': {
      'tr': 'Randevu Detayı',
      'en': 'Appointment Detail',
    },
    'appointmentDetailNotes': {'tr': 'Notlar', 'en': 'Notes'},
    'appointmentDetailResultNotes': {'tr': 'Sonuç Notu', 'en': 'Result Notes'},
    'appointmentDetailResultNotesEdit': {
      'tr': 'Sonuç Notunu Düzenle',
      'en': 'Edit Result Notes',
    },
    'appointmentDetailResultNotesEmpty': {
      'tr': 'Henüz sonuç notu girilmemiş.',
      'en': 'No result notes yet.',
    },
    'appointmentResultNotesSuccess': {
      'tr': 'Sonuç notu başarıyla güncellendi.',
      'en': 'Result notes updated successfully.',
    },
    // Result files
    'appointmentResultFilesTitle': {
      'tr': 'Sonuç Dosyaları',
      'en': 'Result Files',
    },
    'appointmentResultFilesEmpty': {
      'tr': 'Henüz sonuç dosyası eklenmemiş.',
      'en': 'No result files uploaded yet.',
    },
    'appointmentResultFilesUpload': {'tr': 'Dosya Ekle', 'en': 'Upload File'},
    'appointmentResultFilesDownload': {'tr': 'İndir', 'en': 'Download'},
    'appointmentResultFilesDelete': {'tr': 'Sil', 'en': 'Delete'},
    'appointmentResultFilesDeleteConfirmTitle': {
      'tr': 'Dosyayı Sil',
      'en': 'Delete File',
    },
    'appointmentResultFilesDeleteConfirmMessage': {
      'tr': 'Bu dosyayı silmek istediğinizden emin misiniz?',
      'en': 'Are you sure you want to delete this file?',
    },
    'appointmentResultFilesDeleteConfirmCancel': {
      'tr': 'İptal',
      'en': 'Cancel',
    },
    'appointmentResultFilesDeleteConfirmAction': {'tr': 'Sil', 'en': 'Delete'},
    'appointmentResultFilesDeleteSuccess': {
      'tr': 'Dosya başarıyla silindi.',
      'en': 'File deleted successfully.',
    },
    'appointmentResultFilesUploadSuccess': {
      'tr': 'Dosya başarıyla yüklündü.',
      'en': 'File uploaded successfully.',
    },
    'appointmentResultFilesDownloadError': {
      'tr': 'Dosya indirme bağlantısı alınamadı.',
      'en': 'Could not get download link.',
    },
    'appointmentDetailAssignees': {'tr': 'Atananlar', 'en': 'Assignees'},
    'appointmentDetailCustomFields': {
      'tr': 'Özel Alanlar',
      'en': 'Custom Fields',
    },
    'appointmentDetailCompletedAt': {'tr': 'Tamamlandı', 'en': 'Completed At'},
    'appointmentDetailEdit': {'tr': 'Düzenle', 'en': 'Edit'},
    'appointmentCreateSuccess': {
      'tr': 'Randevu başarıyla oluşturuldu.',
      'en': 'Appointment created successfully.',
    },
    'appointmentUpdateSuccess': {
      'tr': 'Randevu başarıyla güncellendi.',
      'en': 'Appointment updated successfully.',
    },
    'appointmentDeleteSuccess': {
      'tr': 'Randevu başarıyla silindi.',
      'en': 'Appointment deleted successfully.',
    },
    'appointmentAssignSuccess': {
      'tr': 'Atamalar başarıyla güncellendi.',
      'en': 'Assignments updated successfully.',
    },
    'appointmentDeleteConfirmTitle': {
      'tr': 'Randevuyu Sil',
      'en': 'Delete Appointment',
    },
    'appointmentDeleteConfirmMessage': {
      'tr':
          'Bu randevuyu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      'en':
          'Are you sure you want to delete this appointment? This action cannot be undone.',
    },
    'appointmentDeleteConfirmCancel': {'tr': 'İptal', 'en': 'Cancel'},
    'appointmentDeleteConfirmAction': {'tr': 'Sil', 'en': 'Delete'},
    'appointmentLoadingFields': {
      'tr': 'Özel alanlar yükleniyor...',
      'en': 'Loading custom fields...',
    },
    'appointmentLoadingMembers': {
      'tr': 'Üyeler yükleniyor...',
      'en': 'Loading members...',
    },
    'appointmentNoStatus': {'tr': 'Durum yok', 'en': 'No status'},
    'appointmentStartDateButton': {'tr': 'Tarih Seç', 'en': 'Select Date'},
    'appointmentEndDateButton': {'tr': 'Tarih Seç', 'en': 'Select Date'},
    'appointmentStartTimeButton': {'tr': 'Saat Seç', 'en': 'Select Time'},
    'appointmentEndTimeButton': {'tr': 'Saat Seç', 'en': 'Select Time'},
    'appointmentPickerDone': {'tr': 'Tamam', 'en': 'Done'},
    'appointmentSectionBasicInfo': {
      'tr': 'Randevu Bilgileri',
      'en': 'Appointment Info',
    },
    'appointmentSectionDateTime': {'tr': 'Tarih ve Saat', 'en': 'Date & Time'},
    'appointmentAssigneesNoneSelected': {
      'tr': 'Seçilmedi',
      'en': 'None selected',
    },
    'appointmentAssigneesNSelected': {
      'tr': '{n} kişi seçildi',
      'en': '{n} selected',
    },
    // PDF Viewer
    'pdfViewerTitle': {'tr': 'PDF Görüntüleyici', 'en': 'PDF Viewer'},
    'pdfViewerLoading': {'tr': 'PDF yükleniyor...', 'en': 'Loading PDF...'},
    'pdfViewerError': {
      'tr': 'PDF dosyası açılamadı. Lütfen tekrar deneyin.',
      'en': 'Could not open PDF file. Please try again.',
    },
    'pdfViewerZoomIn': {'tr': 'Yakınlaştır', 'en': 'Zoom In'},
    'pdfViewerZoomOut': {'tr': 'Uzaklaştır', 'en': 'Zoom Out'},
    'pdfViewerOpen': {'tr': 'Görüntüle', 'en': 'View'},
  };
}
