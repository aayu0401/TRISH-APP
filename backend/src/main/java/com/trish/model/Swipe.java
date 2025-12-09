package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "swipes", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"swiper_id", "swiped_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Swipe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "swiper_id", nullable = false)
    private User swiper;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "swiped_id", nullable = false)
    private User swiped;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SwipeType type;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime swipedAt;
    
    public enum SwipeType {
        LIKE, PASS, SUPER_LIKE
    }
}
