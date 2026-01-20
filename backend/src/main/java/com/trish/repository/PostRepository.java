package com.trish.repository;

import com.trish.model.Post;
import com.trish.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    
    Page<Post> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
    
    Page<Post> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    @Query("SELECT p FROM Post p ORDER BY SIZE(p.likes) DESC, p.createdAt DESC")
    Page<Post> findTrendingPosts(Pageable pageable);
}
