package com.trish.repository;

import com.trish.model.Post;
import com.trish.model.PostLike;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PostLikeRepository extends JpaRepository<PostLike, Long> {
    
    boolean existsByPostAndUser(Post post, User user);
    
    Optional<PostLike> findByPostAndUser(Post post, User user);
    
    long countByPost(Post post);
}
