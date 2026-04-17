package com.trish.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Service
public class AIEngineService {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${ai.engine.url:http://localhost:8000}")
    private String aiEngineUrl;

    public Map<String, Object> getMatchRecommendations(Map<String, Object> request) {
        try {
            return restTemplate.postForObject(aiEngineUrl + "/match", request, Map.class);
        } catch (Exception e) {
            return Collections.emptyMap();
        }
    }

    public Map<String, Object> getAdvancedMatch(Map<String, Object> request) {
        try {
            return restTemplate.postForObject(aiEngineUrl + "/advanced-match", request, Map.class);
        } catch (Exception e) {
            return Collections.emptyMap();
        }
    }

    public List<Map<String, Object>> getChatSuggestions(Map<String, String> request) {
        try {
            // FastAPI doesn't have a direct suggestions endpoint yet, but we can reuse provide-quality or others
            // For now, return mock if not implemented in AI Engine
            return List.of(
                Map.of("text", "That sounds interesting! Tell me more.", "category", "engaging"),
                Map.of("text", "I'd love to hear your thoughts on that.", "category", "open-ended")
            );
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    public Map<String, Object> analyzeConversationSecurity(Map<String, Object> request) {
        try {
            return restTemplate.postForObject(aiEngineUrl + "/analyze-conversation-security", request, Map.class);
        } catch (Exception e) {
            return Map.of("isSafe", true, "safetyScore", 100);
        }
    }

    public Map<String, Object> moderateMessage(String message) {
        try {
            return restTemplate.postForObject(aiEngineUrl + "/moderate-message?message=" + message, null, Map.class);
        } catch (Exception e) {
             return Map.of("is_appropriate", true);
        }
    }

    public Map<String, Object> chatWithWingman(Map<String, String> request) {
        try {
            return restTemplate.postForObject(aiEngineUrl + "/wingman/chat", request, Map.class);
        } catch (Exception e) {
            return Map.of(
                "response", "I'm having a little trouble connecting to my brain right now. Can we try again in a moment?",
                "suggested_actions", List.of("Retry")
            );
        }
    }
}
