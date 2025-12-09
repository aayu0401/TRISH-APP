package com.trish.service;

import com.trish.model.*;
import com.trish.repository.*;
import com.trish.dto.SubscriptionRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class SubscriptionService {

    @Autowired
    private SubscriptionRepository subscriptionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletService walletService;

    private static final Map<Subscription.SubscriptionPlan, Double> PLAN_PRICES = Map.of(
        Subscription.SubscriptionPlan.FREE, 0.0,
        Subscription.SubscriptionPlan.BASIC, 299.0,
        Subscription.SubscriptionPlan.PREMIUM, 599.0,
        Subscription.SubscriptionPlan.VIP, 1299.0
    );

    public Optional<Subscription> getCurrentSubscription(User user) {
        return subscriptionRepository.findByUserAndStatus(user, Subscription.SubscriptionStatus.ACTIVE);
    }

    public List<Map<String, Object>> getAvailablePlans() {
        List<Map<String, Object>> plans = new ArrayList<>();
        
        for (Subscription.SubscriptionPlan plan : Subscription.SubscriptionPlan.values()) {
            Map<String, Object> planInfo = new HashMap<>();
            planInfo.put("plan", plan.name());
            planInfo.put("price", PLAN_PRICES.get(plan));
            planInfo.put("currency", "INR");
            planInfo.put("features", getPlanFeatures(plan));
            plans.add(planInfo);
        }
        
        return plans;
    }

    @Transactional
    public Subscription subscribeToPlan(User user, SubscriptionRequest request) {
        Subscription.SubscriptionPlan plan = Subscription.SubscriptionPlan.valueOf(request.getPlan().toUpperCase());
        Double price = PLAN_PRICES.get(plan);
        
        // Apply promo code discount if provided
        if (request.getPromoCode() != null) {
            Double discount = validatePromoCode(request.getPromoCode());
            price = price * (1 - discount);
        }

        // Deduct from wallet
        if (price > 0) {
            walletService.deductFromWallet(user, price, "Subscription: " + plan.name());
        }

        // Cancel existing active subscription
        getCurrentSubscription(user).ifPresent(sub -> {
            sub.setStatus(Subscription.SubscriptionStatus.CANCELLED);
            subscriptionRepository.save(sub);
        });

        Subscription subscription = new Subscription();
        subscription.setUser(user);
        subscription.setPlan(plan);
        subscription.setPrice(price);
        subscription.setStatus(Subscription.SubscriptionStatus.ACTIVE);
        subscription.setStartDate(LocalDateTime.now());
        subscription.setEndDate(LocalDateTime.now().plusMonths(1));
        subscription.setPromoCode(request.getPromoCode());
        subscription.setPaymentId(UUID.randomUUID().toString());

        return subscriptionRepository.save(subscription);
    }

    @Transactional
    public boolean cancelSubscription(User user) {
        Optional<Subscription> subOpt = getCurrentSubscription(user);
        if (subOpt.isPresent()) {
            Subscription subscription = subOpt.get();
            subscription.setStatus(Subscription.SubscriptionStatus.CANCELLED);
            subscription.setAutoRenew(false);
            subscriptionRepository.save(subscription);
            return true;
        }
        return false;
    }

    @Transactional
    public boolean updateAutoRenew(User user, boolean autoRenew) {
        Optional<Subscription> subOpt = getCurrentSubscription(user);
        if (subOpt.isPresent()) {
            Subscription subscription = subOpt.get();
            subscription.setAutoRenew(autoRenew);
            subscriptionRepository.save(subscription);
            return true;
        }
        return false;
    }

    public List<Map<String, Object>> getPremiumFeatures() {
        List<Map<String, Object>> features = new ArrayList<>();
        
        features.add(Map.of("name", "Unlimited Swipes", "description", "Swipe without limits"));
        features.add(Map.of("name", "See Who Liked You", "description", "View all your likes"));
        features.add(Map.of("name", "Rewind", "description", "Undo your last swipe"));
        features.add(Map.of("name", "Boost", "description", "Be the top profile in your area"));
        features.add(Map.of("name", "Super Likes", "description", "5 Super Likes per day"));
        features.add(Map.of("name", "Ad-Free", "description", "No advertisements"));
        
        return features;
    }

    public Double validatePromoCode(String promoCode) {
        // In production, validate against database
        if ("TRISH50".equals(promoCode)) {
            return 0.5; // 50% discount
        }
        return 0.0;
    }

    public List<Subscription> getSubscriptionHistory(User user) {
        return subscriptionRepository.findByUserOrderByCreatedAtDesc(user);
    }

    private List<String> getPlanFeatures(Subscription.SubscriptionPlan plan) {
        return switch (plan) {
            case FREE -> List.of("Limited swipes", "Basic matching");
            case BASIC -> List.of("Unlimited swipes", "See who liked you");
            case PREMIUM -> List.of("All Basic features", "Rewind", "5 Super Likes/day", "Ad-free");
            case VIP -> List.of("All Premium features", "Priority support", "Profile boost", "Exclusive badges");
        };
    }
}
