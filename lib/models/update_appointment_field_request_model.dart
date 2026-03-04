import 'appointment_field_option_model.dart';
import 'appointment_field_validations_model.dart';

class UpdateAppointmentFieldRequestModel {
  final String? label;
  final String? type;
  final bool? required;
  final bool? isActive;
  final int? sortOrder;
  final String? helpText;
  final List<AppointmentFieldOptionModel>? optionsJson;
  final AppointmentFieldValidationsModel? validationsJson;

  UpdateAppointmentFieldRequestModel({
    this.label,
    this.type,
    this.required,
    this.isActive,
    this.sortOrder,
    this.helpText,
    this.optionsJson,
    this.validationsJson,
  });

  Map<String, dynamic> toJson() => {
        if (label != null) 'label': label,
        if (type != null) 'type': type,
        if (required != null) 'required': required,
        if (isActive != null) 'is_active': isActive,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (helpText != null) 'help_text': helpText,
        if (optionsJson != null)
          'options_json': optionsJson!.map((o) => o.toJson()).toList(),
        if (validationsJson != null)
          'validations_json': validationsJson!.toJson(),
      };
}
