import '../utils/url_utils.dart';
import 'user.dart';

class Gift {
  final int id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final GiftCategory category;
  final GiftType type;
  final bool isAvailable;
  final int? stockQuantity;
  final int popularityScore;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'INR',
    required this.imageUrl,
    required this.category,
    required this.type,
    this.isAvailable = true,
    this.stockQuantity,
    this.popularityScore = 0,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return Gift(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'INR',
      imageUrl: resolveMediaUrl(json['imageUrl']?.toString()),
      category: GiftCategoryX.fromApi(json['category']),
      type: GiftTypeX.fromApi(json['type']),
      isAvailable: json['isAvailable'] == null ? true : json['isAvailable'] == true,
      stockQuantity: json['stockQuantity'] is int ? json['stockQuantity'] : int.tryParse(json['stockQuantity']?.toString() ?? ''),
      popularityScore: json['popularityScore'] is int
          ? json['popularityScore']
          : int.tryParse(json['popularityScore']?.toString() ?? '') ?? 0,
    );
  }
}

class GiftTransaction {
  final int id;
  final User sender;
  final User receiver;
  final Gift gift;
  final double amount;
  final String? message;
  final GiftTransactionStatus status;
  final String? deliveryAddress;
  final String? trackingNumber;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  GiftTransaction({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.gift,
    required this.amount,
    this.message,
    required this.status,
    this.deliveryAddress,
    this.trackingNumber,
    this.deliveredAt,
    required this.createdAt,
  });

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return GiftTransaction(
      id: id,
      sender: User.fromJson(
        json['sender'] is Map ? Map<String, dynamic>.from(json['sender'] as Map) : const <String, dynamic>{},
      ),
      receiver: User.fromJson(
        json['receiver'] is Map ? Map<String, dynamic>.from(json['receiver'] as Map) : const <String, dynamic>{},
      ),
      gift: Gift.fromJson(
        json['gift'] is Map ? Map<String, dynamic>.from(json['gift'] as Map) : const <String, dynamic>{},
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      message: json['message']?.toString(),
      status: GiftTransactionStatusX.fromApi(json['status']),
      deliveryAddress: json['deliveryAddress']?.toString(),
      trackingNumber: json['trackingNumber']?.toString(),
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt'].toString()) : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

enum GiftCategory { flowers, chocolates, jewelry, perfume, gadgets, experiences, virtual, other }

extension GiftCategoryX on GiftCategory {
  static GiftCategory fromApi(dynamic raw) {
    final value = raw?.toString().toUpperCase();
    switch (value) {
      case 'FLOWERS':
        return GiftCategory.flowers;
      case 'CHOCOLATES':
        return GiftCategory.chocolates;
      case 'JEWELRY':
        return GiftCategory.jewelry;
      case 'PERFUME':
        return GiftCategory.perfume;
      case 'GADGETS':
        return GiftCategory.gadgets;
      case 'EXPERIENCES':
        return GiftCategory.experiences;
      case 'VIRTUAL':
        return GiftCategory.virtual;
      default:
        return GiftCategory.other;
    }
  }

  String get apiValue {
    switch (this) {
      case GiftCategory.flowers:
        return 'FLOWERS';
      case GiftCategory.chocolates:
        return 'CHOCOLATES';
      case GiftCategory.jewelry:
        return 'JEWELRY';
      case GiftCategory.perfume:
        return 'PERFUME';
      case GiftCategory.gadgets:
        return 'GADGETS';
      case GiftCategory.experiences:
        return 'EXPERIENCES';
      case GiftCategory.virtual:
        return 'VIRTUAL';
      case GiftCategory.other:
        return 'OTHER';
    }
  }
}

enum GiftType { physical, virtual }

extension GiftTypeX on GiftType {
  static GiftType fromApi(dynamic raw) {
    final value = raw?.toString().toUpperCase();
    switch (value) {
      case 'PHYSICAL':
        return GiftType.physical;
      case 'VIRTUAL':
      default:
        return GiftType.virtual;
    }
  }

  String get apiValue => this == GiftType.physical ? 'PHYSICAL' : 'VIRTUAL';
}

enum GiftTransactionStatus { pending, processing, shipped, delivered, cancelled, refunded, accepted }

extension GiftTransactionStatusX on GiftTransactionStatus {
  static GiftTransactionStatus fromApi(dynamic raw) {
    final value = raw?.toString().toUpperCase();
    switch (value) {
      case 'PENDING':
        return GiftTransactionStatus.pending;
      case 'PROCESSING':
        return GiftTransactionStatus.processing;
      case 'SHIPPED':
        return GiftTransactionStatus.shipped;
      case 'DELIVERED':
        return GiftTransactionStatus.delivered;
      case 'CANCELLED':
        return GiftTransactionStatus.cancelled;
      case 'REFUNDED':
        return GiftTransactionStatus.refunded;
      case 'ACCEPTED':
        return GiftTransactionStatus.accepted;
      default:
        return GiftTransactionStatus.pending;
    }
  }
}
