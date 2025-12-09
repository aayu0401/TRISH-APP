package com.trish.repository;

import com.trish.model.Match;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MatchRepository extends JpaRepository<Match, Long> {
    
    @Query("SELECT m FROM Match m WHERE m.isActive = true AND (m.user1.id = :userId OR m.user2.id = :userId) ORDER BY m.matchedAt DESC")
    List<Match> findActiveMatchesByUserId(@Param("userId") Long userId);
    
    @Query("SELECT m FROM Match m WHERE m.isActive = true AND " +
           "((m.user1.id = :user1Id AND m.user2.id = :user2Id) OR (m.user1.id = :user2Id AND m.user2.id = :user1Id))")
    Optional<Match> findMatchBetweenUsers(@Param("user1Id") Long user1Id, @Param("user2Id") Long user2Id);
    
    boolean existsByUser1AndUser2(User user1, User user2);
}
