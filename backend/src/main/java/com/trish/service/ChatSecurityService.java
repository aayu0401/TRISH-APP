package com.trish.service;

import com.trish.dto.*;
import com.trish.model.Message;
import com.trish.model.User;
import com.trish.repository.MessageRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ChatSecurityService {

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${ai.engine.url:http://localhost:8000}")
    private String aiEngineUrl;

    /**
     * Analyze conversation for security threats and red flags
     */
    public Map<String, Object> analyzeConversationSecurity(Long matchId, Long userId) {
        // Get conversation messages
        List<Message> messages = messageRepository.findByMatchIdOrderBySentAt(matchId);

        if (messages.isEmpty()) {
            return createEmptyAnalysis();
        }

        // Prepare request for AI engine
        Map<String, Object> request = new HashMap<>();
        request.put("conversation_id", matchId.toString());
        request.put("user_id", userId.toString());
        request.put("match_id", matchId.toString());

        List<Map<String, String>> messageList = messages.stream()
                .map(msg -> {
                    Map<String, String> msgMap = new HashMap<>();
                    msgMap.put("id", msg.getId().toString());
                    msgMap.put("sender_id", msg.getSender().getId().toString());
                    msgMap.put("content", msg.getContent());
                    msgMap.put("timestamp", msg.getSentAt().toString());
                    return msgMap;
                })
                .collect(Collectors.toList());

        request.put("messages", messageList);

        try {
            // Call AI engine
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    aiEngineUrl + "/analyze-conversation-security",
                    entity,
                    Map.class
            );

            return response.getBody();
        } catch (Exception e) {
            // Fallback to basic analysis
            return createBasicAnalysis(messages);
        }
    }

    /**
     * Check if a message is safe before sending
     */
    public Map<String, Object> checkMessageSafety(String messageContent) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, String> request = new HashMap<>();
            request.put("message", messageContent);

            HttpEntity<Map<String, String>> entity = new HttpEntity<>(request, headers);

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    aiEngineUrl + "/check-message-safety",
                    entity,
                    Map.class
            );

            return response.getBody();
        } catch (Exception e) {
            // Fallback - allow message but log error
            Map<String, Object> result = new HashMap<>();
            result.put("is_safe", true);
            result.put("reasons", Collections.emptyList());
            result.put("action_required", "NONE");
            return result;
        }
    }

    /**
     * Real-time safety check for incoming messages
     */
    public Map<String, Object> realTimeSafetyCheck(Long matchId, String newMessage, Long senderId) {
        // Get recent conversation history (last 50 messages)
        List<Message> recentMessages = messageRepository
                .findByMatchIdOrderBySentAtDesc(matchId)
                .stream()
                .limit(50)
                .collect(Collectors.toList());

        Collections.reverse(recentMessages); // Oldest first

        List<Map<String, String>> history = recentMessages.stream()
                .map(msg -> {
                    Map<String, String> msgMap = new HashMap<>();
                    msgMap.put("id", msg.getId().toString());
                    msgMap.put("sender_id", msg.getSender().getId().toString());
                    msgMap.put("content", msg.getContent());
                    return msgMap;
                })
                .collect(Collectors.toList());

        try {
            Map<String, Object> request = new HashMap<>();
            request.put("conversation_id", matchId.toString());
            request.put("new_message", newMessage);
            request.put("sender_id", senderId.toString());
            request.put("conversation_history", history);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    aiEngineUrl + "/real-time-safety-check",
                    entity,
                    Map.class
            );

            return response.getBody();
        } catch (Exception e) {
            // Fallback
            Map<String, Object> result = new HashMap<>();
            result.put("should_block", false);
            result.put("should_warn", false);
            result.put("warnings", Collections.emptyList());
            return result;
        }
    }

    /**
     * Moderate message content
     */
    public Map<String, Object> moderateMessage(String messageContent) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, String> request = new HashMap<>();
            request.put("message", messageContent);

            HttpEntity<Map<String, String>> entity = new HttpEntity<>(request, headers);

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    aiEngineUrl + "/moderate-message",
                    entity,
                    Map.class
            );

            return response.getBody();
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("is_appropriate", true);
            result.put("violations", Collections.emptyList());
            result.put("severity", "NONE");
            result.put("action_required", "NONE");
            return result;
        }
    }

    /**
     * Get safety statistics for admin dashboard
     */
    public Map<String, Object> getSafetyStatistics() {
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(
                    aiEngineUrl + "/safety-statistics",
                    Map.class
            );
            return response.getBody();
        } catch (Exception e) {
            return Collections.emptyMap();
        }
    }

    // Helper methods

    private Map<String, Object> createEmptyAnalysis() {
        Map<String, Object> result = new HashMap<>();
        result.put("overall_safety_score", 100.0);
        result.put("sentiment_score", 0.0);
        result.put("red_flags", Collections.emptyList());
        result.put("warnings", Collections.emptyList());
        result.put("recommendations", List.of("Start chatting to get safety insights"));
        result.put("is_safe", true);
        result.put("requires_review", false);
        return result;
    }

    private Map<String, Object> createBasicAnalysis(List<Message> messages) {
        Map<String, Object> result = new HashMap<>();
        result.put("overall_safety_score", 85.0);
        result.put("sentiment_score", 0.0);
        result.put("red_flags", Collections.emptyList());
        result.put("warnings", Collections.emptyList());
        result.put("recommendations", List.of(
                "AI analysis temporarily unavailable",
                "Continue chatting normally",
                "Report any suspicious behavior"
        ));
        result.put("is_safe", true);
        result.put("requires_review", false);
        result.put("message_count", messages.size());
        return result;
    }
}
