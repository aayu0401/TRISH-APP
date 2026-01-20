package com.trish.controller;

import com.trish.model.VideoCall;
import com.trish.security.JwtUtil;
import com.trish.service.VideoCallService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/video")
@RequiredArgsConstructor
public class VideoCallController {
    
    private final VideoCallService videoCallService;
    private final JwtUtil jwtUtil;
    
    @PostMapping("/token")
    public ResponseEntity<?> generateToken(
            @RequestHeader("Authorization") String token,
            @RequestParam Long receiverId) {
        try {
            Long callerId = jwtUtil.extractUserId(token.substring(7));
            Map<String, Object> tokenData = videoCallService.generateCallToken(callerId, receiverId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", tokenData
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PostMapping("/start")
    public ResponseEntity<?> startCall(
            @RequestHeader("Authorization") String token,
            @RequestParam Long receiverId) {
        try {
            Long callerId = jwtUtil.extractUserId(token.substring(7));
            VideoCall call = videoCallService.initiateCall(callerId, receiverId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "call", call
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PostMapping("/{callId}/answer")
    public ResponseEntity<?> answerCall(@PathVariable Long callId) {
        try {
            VideoCall call = videoCallService.answerCall(callId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "call", call
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PostMapping("/{callId}/end")
    public ResponseEntity<?> endCall(
            @PathVariable Long callId,
            @RequestParam(required = false) String reason) {
        try {
            VideoCall call = videoCallService.endCall(callId, reason);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "call", call
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PostMapping("/{callId}/reject")
    public ResponseEntity<?> rejectCall(@PathVariable Long callId) {
        try {
            VideoCall call = videoCallService.rejectCall(callId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "call", call
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/history")
    public ResponseEntity<?> getCallHistory(
            @RequestHeader("Authorization") String token,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Long userId = jwtUtil.extractUserId(token.substring(7));
            Page<VideoCall> history = videoCallService.getCallHistory(userId, PageRequest.of(page, size));
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "history", history.getContent(),
                "totalPages", history.getTotalPages(),
                "totalElements", history.getTotalElements()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/statistics")
    public ResponseEntity<?> getStatistics(@RequestHeader("Authorization") String token) {
        try {
            Long userId = jwtUtil.extractUserId(token.substring(7));
            Map<String, Object> stats = videoCallService.getCallStatistics(userId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "statistics", stats
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
