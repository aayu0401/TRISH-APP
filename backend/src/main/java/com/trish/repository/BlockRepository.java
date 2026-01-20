package com.trish.repository;

import com.trish.model.Block;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BlockRepository extends JpaRepository<Block, Long> {
    
    List<Block> findByBlocker(User blocker);
    
    List<Block> findByBlocked(User blocked);
    
    boolean existsByBlockerAndBlocked(User blocker, User blocked);
    
    Optional<Block> findByBlockerAndBlocked(User blocker, User blocked);
    
    @Query("SELECT b.blocked.id FROM Block b WHERE b.blocker.id = :userId")
    List<Long> findBlockedUserIds(Long userId);
    
    @Query("SELECT b.blocker.id FROM Block b WHERE b.blocked.id = :userId")
    List<Long> findBlockerUserIds(Long userId);
    
    @Query("SELECT COUNT(b) FROM Block b WHERE b.blocked.id = :userId")
    long countBlocksAgainstUser(Long userId);
}
