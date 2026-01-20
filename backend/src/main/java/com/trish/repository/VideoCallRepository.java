package com.trish.repository;

import com.trish.model.User;
import com.trish.model.VideoCall;
import com.trish.model.VideoCall.CallStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VideoCallRepository extends JpaRepository<VideoCall, Long> {
    
    @Query("SELECT v FROM VideoCall v WHERE v.caller = :user OR v.receiver = :user ORDER BY v.startTime DESC")
    Page<VideoCall> findByUser(User user, Pageable pageable);
    
    @Query("SELECT v FROM VideoCall v WHERE (v.caller = :user OR v.receiver = :user) AND v.status = :status ORDER BY v.startTime DESC")
    List<VideoCall> findByUserAndStatus(User user, CallStatus status);
    
    @Query("SELECT COUNT(v) FROM VideoCall v WHERE (v.caller = :user OR v.receiver = :user) AND v.status = 'ANSWERED'")
    long countCompletedCallsByUser(User user);
    
    @Query("SELECT SUM(v.durationSeconds) FROM VideoCall v WHERE (v.caller = :user OR v.receiver = :user) AND v.status = 'ANSWERED'")
    Long getTotalCallDurationByUser(User user);
}
