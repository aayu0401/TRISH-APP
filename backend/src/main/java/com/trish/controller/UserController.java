package com.trish.controller;

import com.trish.model.Photo;
import com.trish.model.User;
import com.trish.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/profile")
    public ResponseEntity<User> getProfile(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        User user = userService.getUserById(userId);
        return ResponseEntity.ok(user);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        User user = userService.getUserById(id);
        return ResponseEntity.ok(user);
    }
    
    @PutMapping("/profile")
    public ResponseEntity<User> updateProfile(Authentication authentication, @RequestBody User updates) {
        Long userId = (Long) authentication.getPrincipal();
        User user = userService.updateProfile(userId, updates);
        return ResponseEntity.ok(user);
    }
    
    @PutMapping("/location")
    public ResponseEntity<User> updateLocation(
            Authentication authentication,
            @RequestBody Map<String, Double> location) {
        Long userId = (Long) authentication.getPrincipal();
        Double latitude = location.get("latitude");
        Double longitude = location.get("longitude");
        User user = userService.updateLocation(userId, latitude, longitude);
        return ResponseEntity.ok(user);
    }
    
    @PutMapping("/preferences")
    public ResponseEntity<?> updatePreferences(
            Authentication authentication,
            @RequestBody Map<String, Object> preferences) {
        Long userId = (Long) authentication.getPrincipal();

        User.Gender interestedInGender = null;
        if (preferences != null && preferences.containsKey("interestedInGender") && preferences.get("interestedInGender") != null) {
            try {
                interestedInGender = User.Gender.valueOf(preferences.get("interestedInGender").toString());
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body(Map.of("message", "Invalid interestedInGender value"));
            }
        }

        Integer minAge = readInt(preferences, "minAge");
        Integer maxAge = readInt(preferences, "maxAge");
        Integer maxDistance = readInt(preferences, "maxDistance");

        User user = userService.updatePreferences(userId, interestedInGender, minAge, maxAge, maxDistance);
        return ResponseEntity.ok(user);
    }

    private Integer readInt(Map<String, Object> map, String key) {
        if (map == null || key == null || !map.containsKey(key)) return null;
        Object value = map.get(key);
        if (value == null) return null;
        if (value instanceof Number number) return number.intValue();
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    @PostMapping("/photos")
    public ResponseEntity<Photo> uploadPhoto(
            Authentication authentication,
            @RequestParam("file") MultipartFile file) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            Photo photo = userService.uploadPhoto(userId, file);
            return ResponseEntity.ok(photo);
        } catch (IOException | IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    @DeleteMapping("/photos/{photoId}")
    public ResponseEntity<Void> deletePhoto(
            Authentication authentication,
            @PathVariable Long photoId) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            userService.deletePhoto(userId, photoId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/photos")
    public ResponseEntity<List<Photo>> getPhotos(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<Photo> photos = userService.getUserPhotos(userId);
        return ResponseEntity.ok(photos);
    }
}
