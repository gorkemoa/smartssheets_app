class BillingStatusModel {
  final String? status;
  final String? plan;
  final String? trialEndsAt;
  final String? expiresAt;
  final bool? locked;

  const BillingStatusModel({
    this.status,
    this.plan,
    this.trialEndsAt,
    this.expiresAt,
    this.locked,
  });

  factory BillingStatusModel.fromJson(Map<String, dynamic> json) {
    return BillingStatusModel(
      status: json['status'] as String?,
      plan: json['plan'] as String?,
      trialEndsAt: json['trial_ends_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      locked: json['locked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'plan': plan,
        'trial_ends_at': trialEndsAt,
        'expires_at': expiresAt,
        'locked': locked,
      };
}
