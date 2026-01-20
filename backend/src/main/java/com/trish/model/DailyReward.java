package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_rewards", indexes = {
    @Index(name = "idx_user_daily_reward", columnList = "user_id"),
    @Index(name = "idx_reward_date", columnList = "rewardDate")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyReward {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(nullable = false)
    private LocalDate rewardDate;
    
    @Column(nullable = false)
    private Integer dayNumber; // Day 1, 2, 3, etc.
    
    @Column(nullable = false)
    private Integer coinsAwarded;
    
    @Column(nullable = false)
    private boolean claimed = false;
    
    private LocalDateTime claimedAt;
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    public static int getRewardForDay(int dayNumber) {
        // Increasing rewards for consecutive days
        if (dayNumber % 7 == 0) {
            return 100; // Bonus on day 7, 14, 21, etc.
        } else if (dayNumber % 30 == 0) {
            return 500; // Big bonus on day 30, 60, etc.
        } else {
            return 10 + (dayNumber * 2); // Base + incremental
        }
    }
}
