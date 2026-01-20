package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "blocks", indexes = {
    @Index(name = "idx_blocker", columnList = "blocker_id"),
    @Index(name = "idx_blocked", columnList = "blocked_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Block {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "blocker_id", nullable = false)
    private User blocker;
    
    @ManyToOne
    @JoinColumn(name = "blocked_id", nullable = false)
    private User blocked;
    
    @Column(length = 500)
    private String reason;
    
    @Column(nullable = false)
    private LocalDateTime blockedAt;
    
    @PrePersist
    protected void onCreate() {
        blockedAt = LocalDateTime.now();
    }
}
