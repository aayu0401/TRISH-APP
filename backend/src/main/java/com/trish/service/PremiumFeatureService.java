package com.trish.service;

import com.trish.model.User;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class PremiumFeatureService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletService walletService;

    private static final double BOOST_PRICE = 99.0;

    /**
     * Activate Boost for a user for 30 minutes
     */
    @Transactional
    public User activateBoost(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Deduct from wallet
        walletService.deductFromWallet(user, BOOST_PRICE, "Profile Boost (30 mins)");

        user.setIsBoosted(true);
        user.setBoostExpiresAt(LocalDateTime.now().plusMinutes(30));

        return userRepository.save(user);
    }

    /**
     * Set Passport location for a user
     */
    @Transactional
    public User setPassportLocation(Long userId, Double lat, Double lon, String city, String country) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!user.getIsPremium()) {
            throw new RuntimeException("Passport is a premium feature. Please upgrade.");
        }

        user.setIsPassportActive(true);
        user.setPassportLatitude(lat);
        user.setPassportLongitude(lon);
        user.setPassportCity(city);
        user.setPassportCountry(country);

        return userRepository.save(user);
    }

    /**
     * Deactivate Passport and return to original location
     */
    @Transactional
    public User deactivatePassport(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setIsPassportActive(false);
        return userRepository.save(user);
    }

    /**
     * Check and reset expired boosts
     */
    @Transactional
    public void cleanupExpiredBoosts() {
        // This would be called by a scheduled task
        // userRepository.resetExpiredBoosts(LocalDateTime.now());
    }
}
