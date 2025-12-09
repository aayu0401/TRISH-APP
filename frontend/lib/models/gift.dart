class Gift {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final String? animationUrl;
  final GiftCategory category;
  final GiftType type;
  final bool isAvailable;
  final int? stockQuantity;
  final Map<String, dynamic>? metadata;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'INR',
    required this.imageUrl,
    this.animationUrl,
    required this.category,
    required this.type,
    this.isAvailable = true,
    this.stockQuantity,
    this.metadata,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      imageUrl: json['imageUrl'] ?? '',
      animationUrl: json['animationUrl'],
      category: GiftCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => GiftCategory.other,
      ),
      type: GiftType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => GiftType.virtual,
      ),
      isAvailable: json['isAvailable'] ?? true,
      stockQuantity: json['stockQuantity'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrl': imageUrl,
      'animationUrl': animationUrl,
      'category': category.toString().split('.').last,
      'type': type.toString().split('.').last,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'metadata': metadata,
    };
  }
}

class GiftTransaction {
  final String id;
  final String senderId;
  final String receiverId;
  final Gift gift;
  final String? message;
  final GiftTransactionStatus status;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;

  GiftTransaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.gift,
    this.message,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.trackingNumber,
  });

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    return GiftTransaction(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      gift: Gift.fromJson(json['gift'] ?? {}),
      message: json['message'],
      status: GiftTransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => GiftTransactionStatus.pending,
      ),
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'gift': gift.toJson(),
      'message': message,
      'status': status.toString().split('.').last,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
    };
  }
}

enum GiftCategory {
  flowers,
  chocolates,
  jewelry,
  gadgets,
  experiences,
  subscription,
  virtual,
  other,
}

enum GiftType {
  virtual,
  physical,
}

enum GiftTransactionStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}
