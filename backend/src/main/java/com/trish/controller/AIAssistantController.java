package com.trish.controller;

import com.trish.service.AIEngineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin(origins = "*")
public class AIAssistantController {

    @Autowired
    private AIEngineService aiEngineService;

    @PostMapping("/chat-suggestions")
    public ResponseEntity<List<Map<String, Object>>> getChatSuggestions(
            @RequestBody Map<String, String> request) {
        return ResponseEntity.ok(aiEngineService.getChatSuggestions(request));
    }

    @GetMapping("/icebreakers")
    public ResponseEntity<List<Map<String, Object>>> getIcebreakers(
            @RequestParam String matchId,
            @RequestParam(required = false) String category) {
        
        // Use AI Engine for icebreakers if available
        List<Map<String, Object>> icebreakers = List.of(
                Map.of("question", "If you could travel anywhere right now, where would you go?", "category", "travel"),
                Map.of("question", "What's the best concert or live event you've been to?", "category", "entertainment"),
                Map.of("question", "What's your go-to comfort food?", "category", "food")
        );
        
        return ResponseEntity.ok(icebreakers);
    }

    @GetMapping("/analyze-conversation/{matchId}")
    public ResponseEntity<Map<String, Object>> analyzeConversation(@PathVariable String matchId) {
        // Implementation would fetch messages and send to AI Engine
        Map<String, Object> analysis = Map.of(
                "sentimentScore", 0.85,
                "engagementLevel", "high",
                "topics", List.of("travel", "food", "movies"),
                "suggestions", List.of("Ask about their favorite travel destination")
        );
        
        return ResponseEntity.ok(analysis);
    }

    @PostMapping("/generate-response")
    public ResponseEntity<Map<String, String>> generateResponse(@RequestBody Map<String, String> request) {
        // Could call AI Engine for text generation
        Map<String, String> response = Map.of(
                "response", "That's really fascinating! I'd love to know more about your experience with that."
        );
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/detect-red-flags")
    public ResponseEntity<Map<String, Object>> detectRedFlags(@RequestBody Map<String, String> request) {
        Map<String, Object> payload = new HashMap<>();
        payload.putAll(request);
        Map<String, Object> result = aiEngineService.analyzeConversationSecurity(payload);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/safety-score/{matchId}")
    public ResponseEntity<Map<String, Object>> getSafetyScore(@PathVariable String matchId) {
        Map<String, Object> safety = Map.of(
                "overallScore", 95,
                "conversationSafety", 100,
                "profileVerification", 90,
                "recommendations", List.of("Continue chatting", "Profile is verified")
        );
        
        return ResponseEntity.ok(safety);
    }

    @GetMapping("/conversation-topics/{matchId}")
    public ResponseEntity<Map<String, Object>> getConversationTopics(@PathVariable String matchId) {
        Map<String, Object> topics = Map.of(
                "topics", List.of("Travel", "Food", "Movies", "Music", "Sports"),
                "sharedInterests", List.of("Travel", "Food")
        );
        
        return ResponseEntity.ok(topics);
    }

    @GetMapping("/relationship-insights/{matchId}")
    public ResponseEntity<Map<String, Object>> getRelationshipInsights(@PathVariable String matchId) {
        Map<String, Object> insights = Map.of(
                "compatibilityScore", 0.87,
                "communicationStyle", "balanced",
                "sharedValues", List.of("adventure", "family", "growth"),
                "growthAreas", List.of("Discuss long-term goals", "Share more about daily life")
        );
        
        return ResponseEntity.ok(insights);
    }

    @PostMapping("/wingman/chat")
    public ResponseEntity<Map<String, Object>> chatWithWingman(@RequestBody Map<String, String> request) {
        return ResponseEntity.ok(aiEngineService.chatWithWingman(request));
    }
}
