package com.trish.service;

import com.trish.dto.SwipeRequest;
import com.trish.model.Match;
import com.trish.model.PersonalityProfile;
import com.trish.model.Swipe;
import com.trish.model.User;
import com.trish.repository.MatchRepository;
import com.trish.repository.PersonalityProfileRepository;
import com.trish.repository.SwipeRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MatchService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SwipeRepository swipeRepository;

    @Autowired
    private MatchRepository matchRepository;

    @Autowired
    private AIEngineService aiEngineService;

    @Autowired
    private PersonalityProfileRepository personalityProfileRepository;

    @Transactional
    public Match processSwipe(Long swiperId, SwipeRequest request) {
        User swiper = userRepository.findById(swiperId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        User swiped = userRepository.findById(request.getTargetUserId())
                .orElseThrow(() -> new IllegalArgumentException("Target user not found"));

        // Check if already swiped
        if (swipeRepository.existsBySwiperAndSwiped(swiper, swiped)) {
            throw new IllegalArgumentException("Already swiped on this user");
        }

        // Create swipe record
        Swipe swipe = new Swipe();
        swipe.setSwiper(swiper);
        swipe.setSwiped(swiped);
        swipe.setType(request.getType());
        swipeRepository.save(swipe);

        // If it's a LIKE or SUPER_LIKE, check for mutual match
        if (request.getType() == Swipe.SwipeType.LIKE || request.getType() == Swipe.SwipeType.SUPER_LIKE) {
            Optional<Swipe> reciprocalSwipe = swipeRepository.findBySwiperAndSwiped(swiped, swiper);

            if (reciprocalSwipe.isPresent() &&
                    (reciprocalSwipe.get().getType() == Swipe.SwipeType.LIKE ||
                            reciprocalSwipe.get().getType() == Swipe.SwipeType.SUPER_LIKE)) {

                // Create match
                Match match = new Match();
                match.setUser1(swiper);
                match.setUser2(swiped);
                match.setIsBlindDateMatch(request.getBlindDate() != null && request.getBlindDate());

                // Calculate real compatibility via AI Engine
                try {
                    String swiperMbti = personalityProfileRepository.findByUserId(swiper.getId())
                            .map(PersonalityProfile::getMbtiType)
                            .filter(mbti -> !mbti.isBlank())
                            .orElse("INFJ");

                    String swipedMbti = personalityProfileRepository.findByUserId(swiped.getId())
                            .map(PersonalityProfile::getMbtiType)
                            .filter(mbti -> !mbti.isBlank())
                            .orElse("ENFP");

                    Map<String, Object> aiRequest = Map.of(
                            "user_mbti", swiperMbti,
                            "candidate_mbti", swipedMbti);
                    Map<String, Object> result = aiEngineService.getAdvancedMatch(aiRequest);
                    Double score = (Double) result.getOrDefault("overall_score", 0.85);
                    match.setCompatibilityScore(score);
                } catch (Exception e) {
                    match.setCompatibilityScore(0.75); // Fallback
                }

                match.setIsActive(true);
                return matchRepository.save(match);
            }
        }

        return null;
    }

    public List<Match> getUserMatches(Long userId) {
        return matchRepository.findActiveMatchesByUserId(userId);
    }

    /**
     * Rewind (undo) last PASS swipe. Premium feature - allows user to take back an
     * accidental pass.
     * 
     * @return The user that was un-passed, or empty if no pass to rewind
     */
    @Transactional
    public Optional<User> rewindLastPass(Long userId) {
        Optional<Swipe> lastPass = swipeRepository.findTopBySwiperIdAndTypeOrderBySwipedAtDesc(userId,
                Swipe.SwipeType.PASS);
        if (lastPass.isEmpty()) {
            return Optional.empty();
        }
        Swipe swipe = lastPass.get();
        User unpassedUser = swipe.getSwiped();
        swipeRepository.delete(swipe);
        return Optional.of(unpassedUser);
    }

    public List<User> getRecommendations(Long userId) {
        User currentUser = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // Get users already swiped on
        List<Long> swipedUserIds = swipeRepository.findSwipedUserIds(userId);
        swipedUserIds.add(userId); // Exclude self

        // Calculate age range based on preferences
        int minAge = currentUser.getMinAge() != null ? currentUser.getMinAge() : 18;
        int maxAge = currentUser.getMaxAge() != null ? currentUser.getMaxAge() : 100;
        int maxDistance = currentUser.getMaxDistance() != null ? currentUser.getMaxDistance() : 50;

        LocalDate maxBirthDate = LocalDate.now().minusYears(minAge);
        LocalDate minBirthDate = LocalDate.now().minusYears(maxAge + 1);

        // Get potential matches based on preferences
        List<User> potentialMatches = userRepository.findPotentialMatches(
                userId,
                currentUser.getInterestedInGender(),
                minBirthDate,
                maxBirthDate);

        // Filter out already swiped users
        potentialMatches = potentialMatches.stream()
                .filter(user -> !swipedUserIds.contains(user.getId()))
                .collect(Collectors.toList());

        // Use Passport coordinates if active, otherwise real coordinates
        boolean passportActive = Boolean.TRUE.equals(currentUser.getIsPassportActive());
        Double currentLat = passportActive ? currentUser.getPassportLatitude()
                : currentUser.getLatitude();
        Double currentLon = passportActive ? currentUser.getPassportLongitude()
                : currentUser.getLongitude();

        // Apply distance filter if location is available
        if (currentLat != null && currentLon != null) {
                potentialMatches = potentialMatches.stream()
                    .filter(candidate -> {
                        // Candidate might also be using passport
                        boolean candidatePassportActive = Boolean.TRUE.equals(candidate.getIsPassportActive());
                        Double targetLat = candidatePassportActive ? candidate.getPassportLatitude()
                                : candidate.getLatitude();
                        Double targetLon = candidatePassportActive ? candidate.getPassportLongitude()
                                : candidate.getLongitude();

                        if (targetLat == null || targetLon == null) {
                            return false;
                        }
                        double distance = calculateDistance(
                                currentLat, currentLon,
                                targetLat, targetLon);
                        return distance <= maxDistance;
                    })
                    .collect(Collectors.toList());
        }

        // Sort: Boosted users first, then by createdAt (new users)
        potentialMatches.sort((a, b) -> {
            LocalDateTime now = LocalDateTime.now();
            boolean aBoosted = Boolean.TRUE.equals(a.getIsBoosted()) && a.getBoostExpiresAt() != null && a.getBoostExpiresAt().isAfter(now);
            boolean bBoosted = Boolean.TRUE.equals(b.getIsBoosted()) && b.getBoostExpiresAt() != null && b.getBoostExpiresAt().isAfter(now);
            if (aBoosted && !bBoosted)
                return -1;
            if (!aBoosted && bBoosted)
                return 1;
            return b.getCreatedAt().compareTo(a.getCreatedAt());
        });

        // Limit to 20 recommendations
        return potentialMatches.stream().limit(20).collect(Collectors.toList());
    }

    // Haversine formula to calculate distance between two points
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km

        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                        * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c;
    }

    @Transactional
    public Match updateRevealProgress(Long userId, Long matchId, Integer progress) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new IllegalArgumentException("Match not found"));

        if (!match.getUser1().getId().equals(userId) && !match.getUser2().getId().equals(userId)) {
            throw new IllegalArgumentException("Not authorized to update this match");
        }

        match.setRevealProgress(Math.min(100, Math.max(match.getRevealProgress(), progress)));
        return matchRepository.save(match);
    }
}
