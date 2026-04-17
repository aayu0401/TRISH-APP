package com.trish.controller;

import com.trish.model.*;
import com.trish.service.PersonalityService;
import com.trish.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/personality")
@CrossOrigin(origins = "*")
public class PersonalityController {

    @Autowired
    private PersonalityService personalityService;

    @Autowired
    private JwtUtil jwtUtil;

    @GetMapping("/profile")
    public ResponseEntity<PersonalityProfile> getPersonalityProfile(
            @RequestParam(required = false) Long userId,
            HttpServletRequest httpRequest) {
        
        if (userId != null) {
            return personalityService.getPersonalityProfileByUserId(userId)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        }
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return personalityService.getPersonalityProfile(user)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/profile")
    public ResponseEntity<PersonalityProfile> updatePersonalityProfile(
            @RequestBody Map<String, Object> profileData,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        PersonalityProfile profile = personalityService.updatePersonalityProfile(user, profileData);
        return ResponseEntity.ok(profile);
    }

    @PostMapping("/test")
    public ResponseEntity<PersonalityProfile> takePersonalityTest(
            @RequestBody Map<String, Object> request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        String testType = (String) request.get("testType");
        Map<String, Object> answers = (Map<String, Object>) request.get("answers");
        
        PersonalityProfile profile = personalityService.takePersonalityTest(user, testType, answers);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/compatibility/{userId}")
    public ResponseEntity<Map<String, Object>> getCompatibilityAnalysis(
            @PathVariable Long userId,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        Map<String, Object> analysis = personalityService.getCompatibilityAnalysis(user, userId);
        return ResponseEntity.ok(analysis);
    }

    @GetMapping("/insights")
    public ResponseEntity<List<Map<String, Object>>> getPersonalityInsights(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(personalityService.getPersonalityInsights(user));
    }

    @GetMapping("/mbti")
    public ResponseEntity<Map<String, Object>> getMBTIProfile(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return personalityService.getPersonalityProfile(user)
                .map(profile -> ResponseEntity.ok(Map.<String, Object>of(
                        "type", profile.getMbtiType() != null ? profile.getMbtiType() : "Not completed",
                        "completed", profile.getTestCompleted()
                )))
                .orElse(ResponseEntity.ok(Map.<String, Object>of("completed", false)));
    }

    @GetMapping("/enneagram")
    public ResponseEntity<Map<String, Object>> getEnneagramProfile(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return personalityService.getPersonalityProfile(user)
                .map(profile -> ResponseEntity.ok(Map.<String, Object>of(
                        "type", profile.getEnneagramType() != null ? profile.getEnneagramType() : "Not completed",
                        "completed", profile.getTestCompleted()
                )))
                .orElse(ResponseEntity.ok(Map.<String, Object>of("completed", false)));
    }

    @GetMapping("/recommendations")
    public ResponseEntity<List<Map<String, Object>>> getMatchRecommendations(HttpServletRequest httpRequest) {
        // This would integrate with the matching service
        return ResponseEntity.ok(List.of());
    }
}
