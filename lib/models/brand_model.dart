class BrandModel {
  final int? id;
  final int? ownerUserId;
  final String? name;
  final String? timezone;
  final String? trialStartsAt;
  final String? trialEndsAt;
  final String? subscriptionStatus;
  final String? currentPlan;
  final int? memberLimit;
  final String? subscriptionExpiresAt;
  final String? lastBillingCheckAt;
  final String? createdAt;
  final String? updatedAt;

  const BrandModel({
    this.id,
    this.ownerUserId,
    this.name,
    this.timezone,
    this.trialStartsAt,
    this.trialEndsAt,
    this.subscriptionStatus,
    this.currentPlan,
    this.memberLimit,
    this.subscriptionExpiresAt,
    this.lastBillingCheckAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int?,
      ownerUserId: json['owner_user_id'] as int?,
      name: json['name'] as String?,
      timezone: json['timezone'] as String?,
      trialStartsAt: json['trial_starts_at'] as String?,
      trialEndsAt: json['trial_ends_at'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      currentPlan: json['current_plan'] as String?,
      memberLimit: json['member_limit'] as int?,
      subscriptionExpiresAt: json['subscription_expires_at'] as String?,
      lastBillingCheckAt: json['last_billing_check_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'name': name,
      'timezone': timezone,
      'trial_starts_at': trialStartsAt,
      'trial_ends_at': trialEndsAt,
      'subscription_status': subscriptionStatus,
      'current_plan': currentPlan,
      'member_limit': memberLimit,
      'subscription_expires_at': subscriptionExpiresAt,
      'last_billing_check_at': lastBillingCheckAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
