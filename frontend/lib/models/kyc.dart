class KYCVerification {
  final String id;
  final String userId;
  final KYCStatus status;
  final KYCType type;
  final Map<String, dynamic> documentData;
  final List<String> documentImages;
  final String? selfieImage;
  final String? videoVerificationUrl;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final int attemptCount;
  final Map<String, dynamic>? verificationMetadata;

  KYCVerification({
    required this.id,
    required this.userId,
    required this.status,
    required this.type,
    required this.documentData,
    required this.documentImages,
    this.selfieImage,
    this.videoVerificationUrl,
    this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
    this.attemptCount = 0,
    this.verificationMetadata,
  });

  factory KYCVerification.fromJson(Map<String, dynamic> json) {
    return KYCVerification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      status: KYCStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => KYCStatus.notStarted,
      ),
      type: KYCType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => KYCType.aadhar,
      ),
      documentData: json['documentData'] ?? {},
      documentImages: List<String>.from(json['documentImages'] ?? []),
      selfieImage: json['selfieImage'],
      videoVerificationUrl: json['videoVerificationUrl'],
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      rejectionReason: json['rejectionReason'],
      attemptCount: json['attemptCount'] ?? 0,
      verificationMetadata: json['verificationMetadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'documentData': documentData,
      'documentImages': documentImages,
      'selfieImage': selfieImage,
      'videoVerificationUrl': videoVerificationUrl,
      'submittedAt': submittedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'attemptCount': attemptCount,
      'verificationMetadata': verificationMetadata,
    };
  }

  bool get isVerified => status == KYCStatus.verified;
  bool get isPending => status == KYCStatus.pending;
  bool get isRejected => status == KYCStatus.rejected;
}

enum KYCStatus {
  notStarted,
  inProgress,
  pending,
  verified,
  rejected,
  expired,
}

enum KYCType {
  aadhar,
  pan,
  passport,
  drivingLicense,
  voterId,
}

class SafetyVerification {
  final String userId;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isKYCVerified;
  final bool isFaceVerified;
  final bool isBackgroundChecked;
  final int trustScore;
  final List<String> badges;
  final DateTime lastVerifiedAt;

  SafetyVerification({
    required this.userId,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.isKYCVerified = false,
    this.isFaceVerified = false,
    this.isBackgroundChecked = false,
    this.trustScore = 0,
    required this.badges,
    required this.lastVerifiedAt,
  });

  factory SafetyVerification.fromJson(Map<String, dynamic> json) {
    return SafetyVerification(
      userId: json['userId'] ?? '',
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isKYCVerified: json['isKYCVerified'] ?? false,
      isFaceVerified: json['isFaceVerified'] ?? false,
      isBackgroundChecked: json['isBackgroundChecked'] ?? false,
      trustScore: json['trustScore'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      lastVerifiedAt: DateTime.parse(json['lastVerifiedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'isKYCVerified': isKYCVerified,
      'isFaceVerified': isFaceVerified,
      'isBackgroundChecked': isBackgroundChecked,
      'trustScore': trustScore,
      'badges': badges,
      'lastVerifiedAt': lastVerifiedAt.toIso8601String(),
    };
  }

  bool get isFullyVerified =>
      isPhoneVerified && isEmailVerified && isKYCVerified && isFaceVerified;
}
