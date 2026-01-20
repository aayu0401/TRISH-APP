package com.trish.service;

import com.trish.model.User;
import com.trish.model.VideoCall;
import com.trish.model.VideoCall.CallStatus;
import com.trish.repository.UserRepository;
import com.trish.repository.VideoCallRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VideoCallService {
    
    private final VideoCallRepository videoCallRepository;
    private final UserRepository userRepository;
    
    // In production, use actual Agora/Twilio SDK
    // This is a simplified token generation
    public Map<String, Object> generateCallToken(Long callerId, Long receiverId) {
        User caller = userRepository.findById(callerId)
            .orElseThrow(() -> new RuntimeException("Caller not found"));
        User receiver = userRepository.findById(receiverId)
            .orElseThrow(() -> new RuntimeException("Receiver not found"));
        
        // Generate unique channel name
        String channelName = "trish_call_" + UUID.randomUUID().toString();
        
        // In production, integrate with Agora/Twilio to generate actual token
        String token = "mock_token_" + UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("channelName", channelName);
        response.put("token", token);
        response.put("appId", "YOUR_AGORA_APP_ID"); // Replace with actual App ID
        response.put("uid", callerId);
        
        return response;
    }
    
    @Transactional
    public VideoCall initiateCall(Long callerId, Long receiverId) {
        User caller = userRepository.findById(callerId)
            .orElseThrow(() -> new RuntimeException("Caller not found"));
        User receiver = userRepository.findById(receiverId)
            .orElseThrow(() -> new RuntimeException("Receiver not found"));
        
        String channelName = "trish_call_" + UUID.randomUUID().toString();
        
        VideoCall call = new VideoCall();
        call.setCaller(caller);
        call.setReceiver(receiver);
        call.setChannelName(channelName);
        call.setStatus(CallStatus.INITIATED);
        
        return videoCallRepository.save(call);
    }
    
    @Transactional
    public VideoCall answerCall(Long callId) {
        VideoCall call = videoCallRepository.findById(callId)
            .orElseThrow(() -> new RuntimeException("Call not found"));
        
        call.setStatus(CallStatus.ANSWERED);
        call.setAnsweredAt(LocalDateTime.now());
        
        return videoCallRepository.save(call);
    }
    
    @Transactional
    public VideoCall endCall(Long callId, String endReason) {
        VideoCall call = videoCallRepository.findById(callId)
            .orElseThrow(() -> new RuntimeException("Call not found"));
        
        call.setStatus(CallStatus.ENDED);
        call.setEndTime(LocalDateTime.now());
        call.setEndReason(endReason);
        
        // Calculate duration if call was answered
        if (call.getAnsweredAt() != null) {
            Duration duration = Duration.between(call.getAnsweredAt(), call.getEndTime());
            call.setDurationSeconds((int) duration.getSeconds());
        }
        
        return videoCallRepository.save(call);
    }
    
    @Transactional
    public VideoCall rejectCall(Long callId) {
        VideoCall call = videoCallRepository.findById(callId)
            .orElseThrow(() -> new RuntimeException("Call not found"));
        
        call.setStatus(CallStatus.REJECTED);
        call.setEndTime(LocalDateTime.now());
        
        return videoCallRepository.save(call);
    }
    
    public Page<VideoCall> getCallHistory(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        return videoCallRepository.findByUser(user, pageable);
    }
    
    public Map<String, Object> getCallStatistics(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        long totalCalls = videoCallRepository.countCompletedCallsByUser(user);
        Long totalDuration = videoCallRepository.getTotalCallDurationByUser(user);
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCalls", totalCalls);
        stats.put("totalDurationSeconds", totalDuration != null ? totalDuration : 0);
        stats.put("averageDurationSeconds", totalCalls > 0 ? (totalDuration != null ? totalDuration / totalCalls : 0) : 0);
        
        return stats;
    }
}
