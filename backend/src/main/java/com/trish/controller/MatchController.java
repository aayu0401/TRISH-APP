package com.trish.controller;

import com.trish.dto.SwipeRequest;
import com.trish.model.Match;
import com.trish.model.User;
import com.trish.service.MatchService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class MatchController {
    
    @Autowired
    private MatchService matchService;
    
    @PostMapping("/swipes")
    public ResponseEntity<Map<String, Object>> swipe(
            Authentication authentication,
            @Valid @RequestBody SwipeRequest request) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            Match match = matchService.processSwipe(userId, request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("matched", match != null);
            if (match != null) {
                response.put("match", match);
            }
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping("/matches")
    public ResponseEntity<List<Match>> getMatches(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<Match> matches = matchService.getUserMatches(userId);
        return ResponseEntity.ok(matches);
    }
    
    @GetMapping("/recommendations")
    public ResponseEntity<List<User>> getRecommendations(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<User> recommendations = matchService.getRecommendations(userId);
        return ResponseEntity.ok(recommendations);
    }
}
