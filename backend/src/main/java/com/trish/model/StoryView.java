package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "story_views", indexes = {
    @Index(name = "idx_story_views", columnList = "story_id"),
    @Index(name = "idx_story_view_viewer", columnList = "viewer_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StoryView {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "story_id", nullable = false)
    private Story story;
    
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
