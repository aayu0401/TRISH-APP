class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final double price;
  final String currency;
  final List<String> features;
  final Map<String, dynamic>? metadata;

  Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.autoRenew = true,
    required this.price,
    this.currency = 'INR',
    required this.features,
    this.metadata,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.toString().split('.').last == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SubscriptionStatus.inactive,
      ),
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      autoRenew: json['autoRenew'] ?? true,
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      features: List<String>.from(json['features'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'autoRenew': autoRenew,
      'price': price,
      'currency': currency,
      'features': features,
      'metadata': metadata,
    };
  }

  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);
  bool get isPremium => plan != SubscriptionPlan.free;
}

enum SubscriptionPlan {
  free,
  basic,
  premium,
  platinum,
}

enum SubscriptionStatus {
  active,
  inactive,
  cancelled,
  expired,
  suspended,
}

class PremiumFeature {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final List<SubscriptionPlan> availableIn;
  final bool isPopular;

  PremiumFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.availableIn,
    this.isPopular = false,
  });

  factory PremiumFeature.fromJson(Map<String, dynamic> json) {
    return PremiumFeature(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      availableIn: (json['availableIn'] as List?)
              ?.map((p) => SubscriptionPlan.values.firstWhere(
                    (e) => e.toString().split('.').last == p,
                    orElse: () => SubscriptionPlan.free,
                  ))
              .toList() ??
          [],
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'availableIn': availableIn.map((p) => p.toString().split('.').last).toList(),
      'isPopular': isPopular,
    };
  }
}
