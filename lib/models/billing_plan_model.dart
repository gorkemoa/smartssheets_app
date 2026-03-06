class BillingPlanModel {
  final String? id;
  final String? name;
  final int? memberLimit;
  final String? priceDisplay;

  const BillingPlanModel({
    this.id,
    this.name,
    this.memberLimit,
    this.priceDisplay,
  });

  factory BillingPlanModel.fromJson(Map<String, dynamic> json) {
    return BillingPlanModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      memberLimit: json['member_limit'] as int?,
      priceDisplay: json['price_display'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'member_limit': memberLimit,
        'price_display': priceDisplay,
      };
}
