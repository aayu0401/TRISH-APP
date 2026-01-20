package com.trish.repository;

import com.trish.model.Story;
import com.trish.model.StoryView;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StoryViewRepository extends JpaRepository<StoryView, Long> {
    
    List<StoryView> findByStoryOrderByViewedAtDesc(Story story);
    
    boolean existsByStoryAndViewer(Story story, User viewer);
    
    Optional<StoryView> findByStoryAndViewer(Story story, User viewer);
    
    long countByStory(Story story);
}
