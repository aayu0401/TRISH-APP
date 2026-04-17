package com.trish.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "kyc_verifications")
@Data
public class KYCVerification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Enumerated(EnumType.STRING)
    private KYCType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VerificationStatus status = VerificationStatus.PENDING;

    private String documentNumber;

    private String documentImageUrl;

    private String selfieImageUrl;

    private Boolean phoneVerified = false;

    private Boolean emailVerified = false;

    private Boolean faceVerified = false;

    private Boolean governmentIdVerified = false;

    @Column(length = 1000)
    private String rejectionReason;

    private LocalDateTime verifiedAt;

    private LocalDateTime expiresAt;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum KYCType {
        AADHAR, PAN, PASSPORT, DRIVERS_LICENSE, VOTER_ID
    }

    public enum VerificationStatus {
        PENDING, SUBMITTED, UNDER_REVIEW, VERIFIED, REJECTED, EXPIRED
    }
}
