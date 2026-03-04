import 'appointment_field_option_model.dart';
import 'appointment_field_validations_model.dart';

class AppointmentFieldModel {
  final int? id;
  final int? brandId;
  final String? key;
  final String? label;
  final String? type;
  final bool? required;
  final bool? isActive;
  final int? sortOrder;
  final List<AppointmentFieldOptionModel>? optionsJson;
  final String? helpText;
  final AppointmentFieldValidationsModel? validationsJson;
  final int? createdByMembershipId;
  final String? createdAt;
  final String? updatedAt;

  const AppointmentFieldModel({
    this.id,
    this.brandId,
    this.key,
    this.label,
    this.type,
    this.required,
    this.isActive,
    this.sortOrder,
    this.optionsJson,
    this.helpText,
    this.validationsJson,
    this.createdByMembershipId,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentFieldModel.fromJson(Map<String, dynamic> json) {
    List<AppointmentFieldOptionModel>? options;
    if (json['options_json'] != null) {
      options = (json['options_json'] as List<dynamic>)
          .map((e) => AppointmentFieldOptionModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
    }

    AppointmentFieldValidationsModel? validations;
    if (json['validations_json'] != null) {
      validations = AppointmentFieldValidationsModel.fromJson(
          json['validations_json'] as Map<String, dynamic>);
    }

    return AppointmentFieldModel(
      id: json['id'] as int?,
      brandId: json['brand_id'] as int?,
      key: json['key'] as String?,
      label: json['label'] as String?,
      type: json['type'] as String?,
      required: json['required'] as bool?,
      isActive: json['is_active'] as bool?,
      sortOrder: json['sort_order'] as int?,
      optionsJson: options,
      helpText: json['help_text'] as String?,
      validationsJson: validations,
      createdByMembershipId: json['created_by_membership_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (brandId != null) 'brand_id': brandId,
        if (key != null) 'key': key,
        if (label != null) 'label': label,
        if (type != null) 'type': type,
        if (required != null) 'required': required,
        if (isActive != null) 'is_active': isActive,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (optionsJson != null)
          'options_json': optionsJson!.map((o) => o.toJson()).toList(),
        if (helpText != null) 'help_text': helpText,
        if (validationsJson != null)
          'validations_json': validationsJson!.toJson(),
        if (createdByMembershipId != null)
          'created_by_membership_id': createdByMembershipId,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };
}
