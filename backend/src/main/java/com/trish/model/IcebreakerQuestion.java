package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "icebreaker_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class IcebreakerQuestion {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(length = 500, nullable = false)
    private String question;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;
    
    @Column(nullable = false)
    private boolean isActive = true;
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    public enum Category {
        FUN("Fun & Lighthearted"),
        DEEP("Deep & Meaningful"),
        RANDOM("Random & Quirky"),
        TRAVEL("Travel & Adventure"),
        FOOD("Food & Dining"),
        HOBBIES("Hobbies & Interests"),
        LIFE("Life & Goals"),
        FAVORITES("Favorites");
        
        private final String displayName;
        
        Category(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
}
