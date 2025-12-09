package com.trish.controller;

import com.trish.model.*;
import com.trish.service.SubscriptionService;
import com.trish.dto.SubscriptionRequest;
import com.trish.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/subscription")
@CrossOrigin(origins = "*")
public class SubscriptionController {

    @Autowired
    private SubscriptionService subscriptionService;

    @Autowired
    private JwtUtil jwtUtil;

    @GetMapping("/current")
    public ResponseEntity<Subscription> getCurrentSubscription(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return subscriptionService.getCurrentSubscription(user)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/plans")
    public ResponseEntity<List<Map<String, Object>>> getAvailablePlans() {
        return ResponseEntity.ok(subscriptionService.getAvailablePlans());
    }

    @PostMapping("/subscribe")
    public ResponseEntity<Subscription> subscribeToPlan(
            @RequestBody SubscriptionRequest request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        Subscription subscription = subscriptionService.subscribeToPlan(user, request);
        return ResponseEntity.ok(subscription);
    }

    @PostMapping("/cancel")
    public ResponseEntity<String> cancelSubscription(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean cancelled = subscriptionService.cancelSubscription(user);
        
        if (cancelled) {
            return ResponseEntity.ok("Subscription cancelled successfully");
        }
        return ResponseEntity.badRequest().body("No active subscription found");
    }

    @PutMapping("/auto-renew")
    public ResponseEntity<String> updateAutoRenew(
            @RequestBody Map<String, Boolean> request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean updated = subscriptionService.updateAutoRenew(user, request.get("autoRenew"));
        
        if (updated) {
            return ResponseEntity.ok("Auto-renew updated successfully");
        }
        return ResponseEntity.badRequest().body("No active subscription found");
    }

    @GetMapping("/features")
    public ResponseEntity<List<Map<String, Object>>> getPremiumFeatures() {
        return ResponseEntity.ok(subscriptionService.getPremiumFeatures());
    }

    @PostMapping("/validate-promo")
    public ResponseEntity<Map<String, Object>> validatePromoCode(@RequestBody Map<String, String> request) {
        Double discount = subscriptionService.validatePromoCode(request.get("promoCode"));
        return ResponseEntity.ok(Map.of(
                "valid", discount > 0,
                "discount", discount,
                "discountPercentage", discount * 100
        ));
    }

    @GetMapping("/history")
    public ResponseEntity<List<Subscription>> getSubscriptionHistory(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(subscriptionService.getSubscriptionHistory(user));
    }
}
