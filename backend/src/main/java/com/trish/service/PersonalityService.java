package com.trish.service;

import com.trish.model.*;
import com.trish.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class PersonalityService {

    @Autowired
    private PersonalityProfileRepository personalityRepository;

    @Autowired
    private UserRepository userRepository;

    public Optional<PersonalityProfile> getPersonalityProfile(User user) {
        return personalityRepository.findByUser(user);
    }

    public Optional<PersonalityProfile> getPersonalityProfileByUserId(Long userId) {
        return personalityRepository.findByUserId(userId);
    }

    @Transactional
    public PersonalityProfile updatePersonalityProfile(User user, Map<String, Object> profileData) {
        PersonalityProfile profile = personalityRepository.findByUser(user)
                .orElse(new PersonalityProfile());
        
        profile.setUser(user);
        
        if (profileData.containsKey("mbtiType")) {
            profile.setMbtiType((String) profileData.get("mbtiType"));
        }
        if (profileData.containsKey("enneagramType")) {
            profile.setEnneagramType((String) profileData.get("enneagramType"));
        }
        if (profileData.containsKey("bio")) {
            profile.setBio((String) profileData.get("bio"));
        }
        if (profileData.containsKey("traits")) {
            profile.setTraits((List<String>) profileData.get("traits"));
        }
        if (profileData.containsKey("values")) {
            profile.setValues((List<String>) profileData.get("values"));
        }
        if (profileData.containsKey("interests")) {
            profile.setInterests((List<String>) profileData.get("interests"));
        }
        
        return personalityRepository.save(profile);
    }

    @Transactional
    public PersonalityProfile takePersonalityTest(User user, String testType, Map<String, Object> answers) {
        PersonalityProfile profile = personalityRepository.findByUser(user)
                .orElse(new PersonalityProfile());
        
        profile.setUser(user);
        
        // Process test results based on type
        if ("MBTI".equalsIgnoreCase(testType)) {
            profile.setMbtiType(calculateMBTI(answers));
        } else if ("ENNEAGRAM".equalsIgnoreCase(testType)) {
            profile.setEnneagramType(calculateEnneagram(answers));
        } else if ("BIG_FIVE".equalsIgnoreCase(testType)) {
            calculateBigFive(profile, answers);
        }
        
        profile.setTestCompleted(true);
        profile.setTestCompletedAt(LocalDateTime.now());
        
        return personalityRepository.save(profile);
    }

    public Map<String, Object> getCompatibilityAnalysis(User currentUser, Long targetUserId) {
        Optional<PersonalityProfile> currentProfile = personalityRepository.findByUser(currentUser);
        Optional<PersonalityProfile> targetProfile = personalityRepository.findByUserId(targetUserId);
        
        Map<String, Object> analysis = new HashMap<>();
        
        if (currentProfile.isPresent() && targetProfile.isPresent()) {
            PersonalityProfile cp = currentProfile.get();
            PersonalityProfile tp = targetProfile.get();
            
            double compatibilityScore = calculateCompatibilityScore(cp, tp);
            analysis.put("score", compatibilityScore);
            analysis.put("mbtiCompatibility", getMBTICompatibility(cp.getMbtiType(), tp.getMbtiType()));
            analysis.put("sharedInterests", getSharedInterests(cp.getInterests(), tp.getInterests()));
            analysis.put("sharedValues", getSharedValues(cp.getValues(), tp.getValues()));
        } else {
            analysis.put("score", 0.5);
            analysis.put("message", "Complete personality test for better compatibility analysis");
        }
        
        return analysis;
    }

    public List<Map<String, Object>> getPersonalityInsights(User user) {
        Optional<PersonalityProfile> profileOpt = personalityRepository.findByUser(user);
        List<Map<String, Object>> insights = new ArrayList<>();
        
        if (profileOpt.isPresent()) {
            PersonalityProfile profile = profileOpt.get();
            
            if (profile.getMbtiType() != null) {
                insights.add(Map.of(
                    "type", "MBTI",
                    "value", profile.getMbtiType(),
                    "description", getMBTIDescription(profile.getMbtiType())
                ));
            }
            
            if (profile.getEnneagramType() != null) {
                insights.add(Map.of(
                    "type", "Enneagram",
                    "value", profile.getEnneagramType(),
                    "description", getEnneagramDescription(profile.getEnneagramType())
                ));
            }
        }
        
        return insights;
    }

    // Helper methods
    private String calculateMBTI(Map<String, Object> answers) {
        // Simplified MBTI calculation
        return "INFP"; // In production, calculate based on answers
    }

    private String calculateEnneagram(Map<String, Object> answers) {
        // Simplified Enneagram calculation
        return "Type 4"; // In production, calculate based on answers
    }

    private void calculateBigFive(PersonalityProfile profile, Map<String, Object> answers) {
        // Simplified Big Five calculation
        profile.setOpennessScore(75);
        profile.setConscientiousnessScore(65);
        profile.setExtraversionScore(55);
        profile.setAgreeablenessScore(80);
        profile.setNeuroticismScore(45);
    }

    private double calculateCompatibilityScore(PersonalityProfile p1, PersonalityProfile p2) {
        double score = 0.5;
        
        // MBTI compatibility
        if (p1.getMbtiType() != null && p2.getMbtiType() != null) {
            score += getMBTICompatibility(p1.getMbtiType(), p2.getMbtiType()) * 0.3;
        }
        
        // Shared interests
        if (p1.getInterests() != null && p2.getInterests() != null) {
            List<String> shared = getSharedInterests(p1.getInterests(), p2.getInterests());
            score += (shared.size() / 10.0) * 0.2;
        }
        
        return Math.min(score, 1.0);
    }

    private double getMBTICompatibility(String type1, String type2) {
        // Simplified compatibility matrix
        return 0.7;
    }

    private List<String> getSharedInterests(List<String> interests1, List<String> interests2) {
        if (interests1 == null || interests2 == null) return new ArrayList<>();
        List<String> shared = new ArrayList<>(interests1);
        shared.retainAll(interests2);
        return shared;
    }

    private List<String> getSharedValues(List<String> values1, List<String> values2) {
        if (values1 == null || values2 == null) return new ArrayList<>();
        List<String> shared = new ArrayList<>(values1);
        shared.retainAll(values2);
        return shared;
    }

    private String getMBTIDescription(String type) {
        return "Personality type: " + type;
    }

    private String getEnneagramDescription(String type) {
        return "Enneagram: " + type;
    }
}
