package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_streaks", indexes = {
    @Index(name = "idx_user_streak", columnList = "user_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserStreak {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;
    
    @Column(nullable = false)
    private Integer currentStreak = 0;
    
    @Column(nullable = false)
    private Integer longestStreak = 0;
    
    private LocalDate lastLoginDate;
    
    @Column(nullable = false)
    private Integer freezeCount = 0;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public void updateStreak() {
        LocalDate today = LocalDate.now();
        
        if (lastLoginDate == null) {
            currentStreak = 1;
            lastLoginDate = today;
        } else if (lastLoginDate.equals(today)) {
            // Already logged in today
            return;
        } else if (lastLoginDate.equals(today.minusDays(1))) {
            // Consecutive day
            currentStreak++;
        } else if (lastLoginDate.isBefore(today.minusDays(1))) {
            // Streak broken
            if (freezeCount > 0) {
                freezeCount--;
            } else {
                currentStreak = 1;
            }
        }
        
        lastLoginDate = today;
        
        if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
        }
    }
}
