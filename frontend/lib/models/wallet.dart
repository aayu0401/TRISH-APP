class Wallet {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final List<Transaction> transactions;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'INR',
    required this.transactions,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      transactions: (json['transactions'] as List?)
              ?.map((t) => Transaction.fromJson(t))
              .toList() ??
          [],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Transaction {
  final String id;
  final String walletId;
  final TransactionType type;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String? description;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.description,
    this.referenceId,
    this.metadata,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      walletId: json['walletId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.other,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      description: json['description'],
      referenceId: json['referenceId'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'description': description,
      'referenceId': referenceId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum TransactionType {
  credit,
  debit,
  refund,
  giftPurchase,
  giftReceived,
  subscription,
  boost,
  superLike,
  other,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  refunded,
}
