package com.trish.repository;

import com.trish.model.Message;
import com.trish.model.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    
    @Query("SELECT m FROM Message m WHERE m.match.id = :matchId ORDER BY m.sentAt ASC")
    List<Message> findByMatchIdOrderBySentAt(@Param("matchId") Long matchId);

    @Query("SELECT m FROM Message m WHERE m.match.id = :matchId ORDER BY m.sentAt DESC")
    List<Message> findByMatchIdOrderBySentAtDesc(@Param("matchId") Long matchId);
    
    @Query("SELECT m FROM Message m WHERE m.receiver.id = :userId AND m.isRead = false")
    List<Message> findUnreadMessagesByReceiver(@Param("userId") Long userId);
    
    @Query("SELECT COUNT(m) FROM Message m WHERE m.receiver.id = :userId AND m.isRead = false")
    long countUnreadMessagesByReceiver(@Param("userId") Long userId);
}
