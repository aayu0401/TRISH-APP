package com.trish.controller;

import com.trish.model.User;
import com.trish.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/premium")
public class PremiumController {

    @Autowired
    private UserService userService;

    @PostMapping("/boost")
    public ResponseEntity<User> activateBoost(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        User user = userService.activateBoost(userId);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/passport")
    public ResponseEntity<User> updatePassport(
            Authentication authentication,
            @RequestBody Map<String, Object> request) {
        Long userId = (Long) authentication.getPrincipal();
        Boolean active = (Boolean) request.get("active");
        Double lat = request.containsKey("latitude") ? Double.valueOf(request.get("latitude").toString()) : null;
        Double lon = request.containsKey("longitude") ? Double.valueOf(request.get("longitude").toString()) : null;
        String city = (String) request.get("city");
        String country = (String) request.get("country");

        User user = userService.updatePassport(userId, active, lat, lon, city, country);
        return ResponseEntity.ok(user);
    }
}
