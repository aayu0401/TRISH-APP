package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "fcm_tokens", indexes = {
    @Index(name = "idx_user_token", columnList = "user_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FCMToken {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(nullable = false, unique = true)
    private String token;
    
    @Column(nullable = false)
    private String deviceType; // ANDROID, IOS, WEB
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime lastUsedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        lastUsedAt = LocalDateTime.now();
    }
}
