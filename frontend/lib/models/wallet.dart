class Wallet {
  final int id;
  final int userId;
  final double balance;
  final double totalEarned;
  final double totalSpent;
  final String currency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.currency,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final dynamic user = json['user'];
    final rawUserId = json['userId'] ?? (user is Map ? user['id'] : null);
    final userId = rawUserId is int ? rawUserId : int.tryParse(rawUserId?.toString() ?? '') ?? 0;

    return Wallet(
      id: id,
      userId: userId,
      balance: (json['balance'] ?? 0).toDouble(),
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'INR',
      isActive: json['isActive'] == null ? true : json['isActive'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}

class Transaction {
  final int id;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final String? description;
  final String? referenceId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return Transaction(
      id: id,
      type: TransactionTypeX.fromApi(json['type']),
      amount: (json['amount'] ?? 0).toDouble(),
      status: TransactionStatusX.fromApi(json['status']),
      description: json['description']?.toString(),
      referenceId: json['referenceId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

enum TransactionType { credit, debit, refund, withdrawal, other, giftReceived }

extension TransactionTypeX on TransactionType {
  static TransactionType fromApi(dynamic raw) {
    final value = raw?.toString().toUpperCase();
    switch (value) {
      case 'CREDIT':
        return TransactionType.credit;
      case 'DEBIT':
        return TransactionType.debit;
      case 'REFUND':
        return TransactionType.refund;
      case 'WITHDRAWAL':
        return TransactionType.withdrawal;
      default:
        return TransactionType.other;
    }
  }
}

enum TransactionStatus { pending, completed, failed, cancelled }

extension TransactionStatusX on TransactionStatus {
  static TransactionStatus fromApi(dynamic raw) {
    final value = raw?.toString().toUpperCase();
    switch (value) {
      case 'COMPLETED':
        return TransactionStatus.completed;
      case 'FAILED':
        return TransactionStatus.failed;
      case 'CANCELLED':
        return TransactionStatus.cancelled;
      case 'PENDING':
      default:
        return TransactionStatus.pending;
    }
  }
}
