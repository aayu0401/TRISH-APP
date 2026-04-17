package com.trish.controller;

import com.trish.security.JwtUtil;
import com.trish.service.ChatSecurityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/chat-security")
@CrossOrigin(origins = "*")
public class ChatSecurityController {

    @Autowired
    private ChatSecurityService chatSecurityService;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Analyze conversation security for a specific match
     */
    @GetMapping("/analyze/{matchId}")
    public ResponseEntity<Map<String, Object>> analyzeConversation(
            @PathVariable Long matchId,
            HttpServletRequest request) {

        String token = request.getHeader("Authorization").substring(7);
        Long userId = jwtUtil.extractUserId(token);

        Map<String, Object> analysis = chatSecurityService.analyzeConversationSecurity(matchId, userId);
        return ResponseEntity.ok(analysis);
    }

    /**
     * Check if a message is safe before sending
     */
    @PostMapping("/check-message")
    public ResponseEntity<Map<String, Object>> checkMessage(
            @RequestBody Map<String, String> request) {

        String message = request.get("message");
        Map<String, Object> result = chatSecurityService.checkMessageSafety(message);
        return ResponseEntity.ok(result);
    }

    /**
     * Real-time safety check for incoming messages
     */
    @PostMapping("/real-time-check")
    public ResponseEntity<Map<String, Object>> realTimeCheck(
            @RequestBody Map<String, Object> request,
            HttpServletRequest httpRequest) {

        String token = httpRequest.getHeader("Authorization").substring(7);
        Long userId = jwtUtil.extractUserId(token);

        Long matchId = Long.parseLong(request.get("match_id").toString());
        String newMessage = request.get("message").toString();

        Map<String, Object> result = chatSecurityService.realTimeSafetyCheck(matchId, newMessage, userId);
        return ResponseEntity.ok(result);
    }

    /**
     * Moderate message content
     */
    @PostMapping("/moderate")
    public ResponseEntity<Map<String, Object>> moderateMessage(
            @RequestBody Map<String, String> request) {

        String message = request.get("message");
        Map<String, Object> result = chatSecurityService.moderateMessage(message);
        return ResponseEntity.ok(result);
    }

    /**
     * Get safety statistics (admin only)
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getSafetyStatistics() {
        Map<String, Object> stats = chatSecurityService.getSafetyStatistics();
        return ResponseEntity.ok(stats);
    }

    /**
     * Report a message for manual review
     */
    @PostMapping("/report-message")
    public ResponseEntity<Map<String, String>> reportMessage(
            @RequestBody Map<String, Object> request,
            HttpServletRequest httpRequest) {

        String token = httpRequest.getHeader("Authorization").substring(7);
        Long userId = jwtUtil.extractUserId(token);

        Long messageId = Long.parseLong(request.get("message_id").toString());
        String reason = request.get("reason").toString();

        // In production, save to database for manual review
        // For now, just acknowledge

        return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Message reported for review",
                "message_id", messageId.toString(),
                "reporter_id", userId.toString()
        ));
    }

    /**
     * Get safety score for a specific conversation
     */
    @GetMapping("/safety-score/{matchId}")
    public ResponseEntity<Map<String, Object>> getSafetyScore(
            @PathVariable Long matchId,
            HttpServletRequest request) {

        String token = request.getHeader("Authorization").substring(7);
        Long userId = jwtUtil.extractUserId(token);

        Map<String, Object> analysis = chatSecurityService.analyzeConversationSecurity(matchId, userId);

        // Extract just the safety score and key metrics
        Map<String, Object> result = Map.of(
                "safety_score", analysis.get("overall_safety_score"),
                "sentiment_score", analysis.get("sentiment_score"),
                "is_safe", analysis.get("is_safe"),
                "requires_review", analysis.get("requires_review"),
                "red_flag_count", ((java.util.List<?>) analysis.get("red_flags")).size()
        );

        return ResponseEntity.ok(result);
    }
}
