package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications", indexes = {
    @Index(name = "idx_user_notifications", columnList = "user_id"),
    @Index(name = "idx_read_status", columnList = "isRead")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;
    
    @Column(nullable = false)
    private String title;
    
    @Column(length = 500, nullable = false)
    private String body;
    
    @Column(length = 1000)
    private String data; // JSON data for navigation
    
    @Column(nullable = false)
    private boolean isRead = false;
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    public enum NotificationType {
        NEW_MATCH,
        NEW_MESSAGE,
        PROFILE_LIKED,
        PROFILE_SUPER_LIKED,
        PROFILE_VIEWED,
        NEW_STORY,
        POST_LIKED,
        POST_COMMENTED,
        VIDEO_CALL_INCOMING,
        VIDEO_CALL_MISSED,
        GIFT_RECEIVED,
        SUBSCRIPTION_EXPIRING,
        VERIFICATION_APPROVED,
        VERIFICATION_REJECTED
    }
}
