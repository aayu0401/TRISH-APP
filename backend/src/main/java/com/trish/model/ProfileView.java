package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "profile_views", indexes = {
    @Index(name = "idx_profile_viewed", columnList = "viewed_user_id"),
    @Index(name = "idx_viewer", columnList = "viewer_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfileView {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "viewed_user_id", nullable = false)
    private User viewedUser;
    
    @ManyToOne
    @JoinColumn(name = "viewer_id", nullable = false)
    private User viewer;
    
    @Column(nullable = false)
    private LocalDateTime viewedAt;
    
    @PrePersist
    protected void onCreate() {
        viewedAt = LocalDateTime.now();
    }
}
