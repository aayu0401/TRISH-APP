package com.trish.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "video_calls", indexes = {
    @Index(name = "idx_caller", columnList = "caller_id"),
    @Index(name = "idx_receiver", columnList = "receiver_id"),
    @Index(name = "idx_video_call_status", columnList = "status")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VideoCall {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "caller_id", nullable = false)
    private User caller;
    
    @ManyToOne
    @JoinColumn(name = "receiver_id", nullable = false)
    private User receiver;
    
    @Column(nullable = false)
    private String channelName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CallStatus status;
    
    private Integer durationSeconds;
    
    @Column(nullable = false)
    private LocalDateTime startTime;
    
    private LocalDateTime endTime;
    
    private LocalDateTime answeredAt;
    
    @Column(length = 500)
    private String endReason;
    
    @PrePersist
    protected void onCreate() {
        startTime = LocalDateTime.now();
        status = CallStatus.INITIATED;
    }
    
    public enum CallStatus {
        INITIATED,
        RINGING,
        ANSWERED,
        ENDED,
        MISSED,
        REJECTED,
        FAILED
    }
}
