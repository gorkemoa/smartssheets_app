import 'appointment_field_option_model.dart';
import 'appointment_field_validations_model.dart';

class CreateAppointmentFieldRequestModel {
  final String key;
  final String label;
  final String type;
  final bool? required;
  final bool? isActive;
  final int? sortOrder;
  final String? helpText;
  final List<AppointmentFieldOptionModel>? optionsJson;
  final AppointmentFieldValidationsModel? validationsJson;

  CreateAppointmentFieldRequestModel({
    required this.key,
    required this.label,
    required this.type,
    this.required,
    this.isActive,
    this.sortOrder,
    this.helpText,
    this.optionsJson,
    this.validationsJson,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'type': type,
        if (required != null) 'required': required,
        if (isActive != null) 'is_active': isActive,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (helpText != null && helpText!.isNotEmpty) 'help_text': helpText,
        if (optionsJson != null && optionsJson!.isNotEmpty)
          'options_json': optionsJson!.map((o) => o.toJson()).toList(),
        if (validationsJson != null)
          'validations_json': validationsJson!.toJson(),
      };
}
