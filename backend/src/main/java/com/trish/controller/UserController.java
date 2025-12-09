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
    public ResponseEntity<User> updatePreferences(
            Authentication authentication,
            @RequestBody Map<String, Object> preferences) {
        Long userId = (Long) authentication.getPrincipal();
        
        User.Gender interestedInGender = preferences.containsKey("interestedInGender") 
            ? User.Gender.valueOf((String) preferences.get("interestedInGender")) 
            : null;
        Integer minAge = preferences.containsKey("minAge") 
            ? (Integer) preferences.get("minAge") 
            : null;
        Integer maxAge = preferences.containsKey("maxAge") 
            ? (Integer) preferences.get("maxAge") 
            : null;
        Integer maxDistance = preferences.containsKey("maxDistance") 
            ? (Integer) preferences.get("maxDistance") 
            : null;
        
        User user = userService.updatePreferences(userId, interestedInGender, minAge, maxAge, maxDistance);
        return ResponseEntity.ok(user);
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
