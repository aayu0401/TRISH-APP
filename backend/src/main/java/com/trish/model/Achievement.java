package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "achievements", indexes = {
    @Index(name = "idx_user_achievements", columnList = "user_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Achievement {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AchievementType type;
    
    @Column(nullable = false)
    private boolean unlocked = false;
    
    private Integer progress = 0;
    
    private Integer target;
    
    private LocalDateTime unlockedAt;
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    public enum AchievementType {
        FIRST_MATCH("First Match", "Get your first match", 1, 10),
        TEN_MATCHES("Social Butterfly", "Get 10 matches", 10, 50),
        FIFTY_MATCHES("Popular", "Get 50 matches", 50, 100),
        HUNDRED_MATCHES("Superstar", "Get 100 matches", 100, 200),
        
        FIRST_MESSAGE("Ice Breaker", "Send your first message", 1, 10),
        HUNDRED_MESSAGES("Conversationalist", "Send 100 messages", 100, 50),
        THOUSAND_MESSAGES("Chatterbox", "Send 1000 messages", 1000, 100),
        
        WEEK_STREAK("Dedicated", "Login for 7 days straight", 7, 30),
        MONTH_STREAK("Committed", "Login for 30 days straight", 30, 100),
        
        COMPLETE_PROFILE("All Set", "Complete your profile 100%", 100, 20),
        VERIFIED("Verified", "Get verified", 1, 50),
        
        FIRST_GIFT("Generous", "Send your first gift", 1, 25),
        TEN_GIFTS("Gift Giver", "Send 10 gifts", 10, 75),
        
        PREMIUM_MEMBER("Premium", "Subscribe to premium", 1, 100);
        
        private final String title;
        private final String description;
        private final int target;
        private final int rewardCoins;
        
        AchievementType(String title, String description, int target, int rewardCoins) {
            this.title = title;
            this.description = description;
            this.target = target;
            this.rewardCoins = rewardCoins;
        }
        
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public int getTarget() { return target; }
        public int getRewardCoins() { return rewardCoins; }
    }
}
