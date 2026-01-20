package com.trish.controller;

import com.trish.dto.ApiResponse;
import com.trish.model.User;
import com.trish.service.EnhancedUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class EnhancedUserController {

    @Autowired
    private EnhancedUserService enhancedUserService;

    /**
     * Get paginated users
     */
    @GetMapping("/paginated")
    public ResponseEntity<Map<String, Object>> getPaginatedUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "ASC") String direction) {
        
        Sort.Direction sortDirection = direction.equalsIgnoreCase("DESC") 
            ? Sort.Direction.DESC 
            : Sort.Direction.ASC;
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sortBy));
        Page<User> userPage = enhancedUserService.getUsersWithPagination(pageable);

        Map<String, Object> response = new HashMap<>();
        response.put("users", userPage.getContent());
        response.put("currentPage", userPage.getNumber());
        response.put("totalItems", userPage.getTotalElements());
        response.put("totalPages", userPage.getTotalPages());
        response.put("hasNext", userPage.hasNext());
        response.put("hasPrevious", userPage.hasPrevious());

        return ResponseEntity.ok(response);
    }

    /**
     * Search users by location
     */
    @GetMapping("/nearby")
    public ResponseEntity<List<User>> getNearbyUsers(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "50") Double radiusKm,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        List<User> nearbyUsers = enhancedUserService.searchUsersByLocation(
            latitude, longitude, radiusKm, pageable
        );

        return ResponseEntity.ok(nearbyUsers);
    }

    /**
     * Get user statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<EnhancedUserService.UserStatistics> getUserStatistics(
            Authentication authentication) {
        
        String email = authentication.getName();
        User user = enhancedUserService.getUserByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        EnhancedUserService.UserStatistics stats = 
            enhancedUserService.getUserStatistics(user.getId());

        return ResponseEntity.ok(stats);
    }

    /**
     * Get active users
     */
    @GetMapping("/active")
    public ResponseEntity<List<User>> getActiveUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        List<User> activeUsers = enhancedUserService.getActiveUsers(pageable);

        return ResponseEntity.ok(activeUsers);
    }

    /**
     * Get verified users
     */
    @GetMapping("/verified")
    public ResponseEntity<List<User>> getVerifiedUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        List<User> verifiedUsers = enhancedUserService.getVerifiedUsers(pageable);

        return ResponseEntity.ok(verifiedUsers);
    }

    /**
     * Health check with detailed info
     */
    @GetMapping("/health/detailed")
    public ResponseEntity<Map<String, Object>> getDetailedHealth() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", System.currentTimeMillis());
        health.put("service", "User Service");
        health.put("version", "2.0.0");
        
        return ResponseEntity.ok(health);
    }
}
