package com.trish.repository;

import com.trish.model.Comment;
import com.trish.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    
    List<Comment> findByPostOrderByCreatedAtDesc(Post post);
    
    long countByPost(Post post);
}
