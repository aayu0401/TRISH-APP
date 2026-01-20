package com.trish.repository;

import com.trish.model.Story;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StoryRepository extends JpaRepository<Story, Long> {
    
    @Query("SELECT s FROM Story s WHERE s.expiresAt > :now ORDER BY s.createdAt DESC")
    List<Story> findActiveStories(LocalDateTime now);
    
    @Query("SELECT s FROM Story s WHERE s.user = :user AND s.expiresAt > :now ORDER BY s.createdAt DESC")
    List<Story> findActiveStoriesByUser(User user, LocalDateTime now);
    
    @Query("SELECT s FROM Story s WHERE s.expiresAt <= :now")
    List<Story> findExpiredStories(LocalDateTime now);
    
    List<Story> findByUserOrderByCreatedAtDesc(User user);
}
