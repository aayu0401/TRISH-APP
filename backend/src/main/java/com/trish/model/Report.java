package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "reports", indexes = {
    @Index(name = "idx_reporter", columnList = "reporter_id"),
    @Index(name = "idx_reported", columnList = "reported_id"),
    @Index(name = "idx_report_status", columnList = "status")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Report {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "reporter_id", nullable = false)
    private User reporter;
    
    @ManyToOne
    @JoinColumn(name = "reported_id", nullable = false)
    private User reported;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportCategory category;
    
    @Column(length = 1000, nullable = false)
    private String reason;
    
    @Column(length = 2000)
    private String evidence;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus status = ReportStatus.PENDING;
    
    @Column(length = 1000)
    private String adminNotes;
    
    @Column(nullable = false)
    private LocalDateTime reportedAt;
    
    private LocalDateTime reviewedAt;
    
    @PrePersist
    protected void onCreate() {
        reportedAt = LocalDateTime.now();
    }
    
    public enum ReportCategory {
        HARASSMENT,
        FAKE_PROFILE,
        INAPPROPRIATE_CONTENT,
        SPAM,
        SCAM,
        UNDERAGE,
        VIOLENCE,
        OTHER
    }
    
    public enum ReportStatus {
        PENDING,
        UNDER_REVIEW,
        RESOLVED,
        DISMISSED
    }
}
