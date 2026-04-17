package com.trish.service;

import com.trish.model.User;
import com.trish.repository.MatchRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.CachePut;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class EnhancedUserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MatchRepository matchRepository;

    /**
     * Get user by ID with caching
     */
    @Cacheable(value = "users", key = "#userId")
    public Optional<User> getUserById(Long userId) {
        return userRepository.findById(userId);
    }

    /**
     * Get user by email with caching
     */
    @Cacheable(value = "users", key = "#email")
    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    /**
     * Update user and refresh cache
     */
    @CachePut(value = "users", key = "#user.id")
    public User updateUser(User user) {
        return userRepository.save(user);
    }

    /**
     * Delete user and evict from cache
     */
    @CacheEvict(value = "users", key = "#userId")
    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }

    /**
     * Get users with pagination for better performance
     */
    public Page<User> getUsersWithPagination(Pageable pageable) {
        return userRepository.findAll(pageable);
    }

    /**
     * Search users by location with distance calculation
     * Prioritizes boosted users and supports passport feature
     */
    public List<User> searchUsersByLocation(
            User searcher,
            Double radiusKm,
            Pageable pageable) {

        Double baseLat = searcher.getIsPassportActive() ? searcher.getPassportLatitude() : searcher.getLatitude();
        Double baseLon = searcher.getIsPassportActive() ? searcher.getPassportLongitude() : searcher.getLongitude();

        if (baseLat == null || baseLon == null) {
            return List.of();
        }

        return userRepository.findAll(pageable).getContent().stream()
                .filter(user -> !user.getId().equals(searcher.getId())) // Don't show self
                .filter(user -> {
                    Double userLat = user.getLatitude();
                    Double userLon = user.getLongitude();

                    if (userLat == null || userLon == null)
                        return false;

                    double distance = calculateDistance(baseLat, baseLon, userLat, userLon);
                    return distance <= (radiusKm != null ? radiusKm : searcher.getMaxDistance());
                })
                .sorted((u1, u2) -> {
                    // Priority 1: Boosted users
                    boolean b1 = u1.getIsBoosted() != null && u1.getIsBoosted();
                    boolean b2 = u2.getIsBoosted() != null && u2.getIsBoosted();
                    if (b1 && !b2)
                        return -1;
                    if (!b1 && b2)
                        return 1;

                    // Priority 2: Distance
                    double d1 = calculateDistance(baseLat, baseLon, u1.getLatitude(), u1.getLongitude());
                    double d2 = calculateDistance(baseLat, baseLon, u2.getLatitude(), u2.getLongitude());
                    return Double.compare(d1, d2);
                })
                .toList();
    }

    /**
     * Calculate distance between two points using Haversine formula
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int EARTH_RADIUS_KM = 6371;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }

    /**
     * Get active users (online in last 24 hours)
     */
    public List<User> getActiveUsers(Pageable pageable) {
        // This would require a lastActive field in User model
        return userRepository.findAll(pageable).getContent();
    }

    /**
     * Get verified users only
     */
    public List<User> getVerifiedUsers(Pageable pageable) {
        return userRepository.findAll(pageable).getContent().stream()
                .filter(User::isVerified)
                .toList();
    }

    /**
     * Bulk update user status
     */
    @CacheEvict(value = "users", allEntries = true)
    public void bulkUpdateUserStatus(List<Long> userIds, boolean isActive) {
        List<User> users = userRepository.findAllById(userIds);
        users.forEach(user -> user.setActive(isActive));
        userRepository.saveAll(users);
    }

    /**
     * Get user statistics
     */
    public UserStatistics getUserStatistics(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Calculate various statistics
        return UserStatistics.builder()
                .totalMatches(matchRepository.findActiveMatchesByUserId(userId).size())
                .profileCompleteness(calculateProfileCompleteness(user))
                .verificationStatus(user.isVerified())
                .build();
    }

    private int calculateProfileCompleteness(User user) {
        int score = 0;
        int totalFields = 8;

        if (user.getName() != null && !user.getName().isEmpty())
            score++;
        if (user.getBio() != null && !user.getBio().isEmpty())
            score++;
        if (user.getDateOfBirth() != null)
            score++;
        if (user.getGender() != null)
            score++;
        if (user.getCity() != null)
            score++;
        if (user.getPhotos() != null && !user.getPhotos().isEmpty())
            score++;
        if (user.getInterests() != null && !user.getInterests().isEmpty())
            score++;
        if (user.getLatitude() != null && user.getLongitude() != null)
            score++;

        return (score * 100) / totalFields;
    }

    // Inner class for statistics
    public static class UserStatistics {
        private int totalMatches;
        private int profileCompleteness;
        private boolean verificationStatus;

        public static UserStatisticsBuilder builder() {
            return new UserStatisticsBuilder();
        }

        public static class UserStatisticsBuilder {
            private int totalMatches;
            private int profileCompleteness;
            private boolean verificationStatus;

            public UserStatisticsBuilder totalMatches(int totalMatches) {
                this.totalMatches = totalMatches;
                return this;
            }

            public UserStatisticsBuilder profileCompleteness(int profileCompleteness) {
                this.profileCompleteness = profileCompleteness;
                return this;
            }

            public UserStatisticsBuilder verificationStatus(boolean verificationStatus) {
                this.verificationStatus = verificationStatus;
                return this;
            }

            public UserStatistics build() {
                UserStatistics stats = new UserStatistics();
                stats.totalMatches = this.totalMatches;
                stats.profileCompleteness = this.profileCompleteness;
                stats.verificationStatus = this.verificationStatus;
                return stats;
            }
        }

        // Getters
        public int getTotalMatches() {
            return totalMatches;
        }

        public int getProfileCompleteness() {
            return profileCompleteness;
        }

        public boolean isVerificationStatus() {
            return verificationStatus;
        }
    }
}
