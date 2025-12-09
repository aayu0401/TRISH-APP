package com.trish.service;

import com.trish.dto.SwipeRequest;
import com.trish.model.Match;
import com.trish.model.Swipe;
import com.trish.model.User;
import com.trish.repository.MatchRepository;
import com.trish.repository.SwipeRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
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
    private RestTemplate restTemplate;
    
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
                match.setCompatibilityScore(0.0); // Will be calculated by AI
                match.setIsActive(true);
                
                return matchRepository.save(match);
            }
        }
        
        return null; // No match created
    }
    
    public List<Match> getUserMatches(Long userId) {
        return matchRepository.findActiveMatchesByUserId(userId);
    }
    
    public List<User> getRecommendations(Long userId) {
        User currentUser = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        // Get users already swiped on
        List<Long> swipedUserIds = swipeRepository.findSwipedUserIds(userId);
        swipedUserIds.add(userId); // Exclude self
        
        // Calculate age range based on preferences
        LocalDate maxBirthDate = LocalDate.now().minusYears(currentUser.getMinAge());
        LocalDate minBirthDate = LocalDate.now().minusYears(currentUser.getMaxAge() + 1);
        
        // Get potential matches based on preferences
        List<User> potentialMatches = userRepository.findPotentialMatches(
            userId,
            currentUser.getInterestedInGender(),
            minBirthDate,
            maxBirthDate
        );
        
        // Filter out already swiped users
        potentialMatches = potentialMatches.stream()
                .filter(user -> !swipedUserIds.contains(user.getId()))
                .collect(Collectors.toList());
        
        // Apply distance filter if location is available
        if (currentUser.getLatitude() != null && currentUser.getLongitude() != null) {
            potentialMatches = potentialMatches.stream()
                    .filter(user -> {
                        if (user.getLatitude() == null || user.getLongitude() == null) {
                            return false;
                        }
                        double distance = calculateDistance(
                            currentUser.getLatitude(), currentUser.getLongitude(),
                            user.getLatitude(), user.getLongitude()
                        );
                        return distance <= currentUser.getMaxDistance();
                    })
                    .collect(Collectors.toList());
        }
        
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
}
