package com.trish.repository;

import com.trish.model.FCMToken;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FCMTokenRepository extends JpaRepository<FCMToken, Long> {
    
    List<FCMToken> findByUser(User user);
    
    Optional<FCMToken> findByToken(String token);
    
    void deleteByToken(String token);
}
