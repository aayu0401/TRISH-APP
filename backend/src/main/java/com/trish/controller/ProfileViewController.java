package com.trish.controller;

import com.trish.model.User;
import com.trish.service.ProfileViewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/profile-views")
public class ProfileViewController {

    @Autowired
    private ProfileViewService profileViewService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getWhoViewedMe(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Long userId = (Long) authentication.getPrincipal();
        List<User> viewers = profileViewService.getWhoViewedMe(userId, page, size);
        long totalCount = profileViewService.getViewCount(userId);

        Map<String, Object> response = new HashMap<>();
        response.put("viewers", viewers);
        response.put("totalCount", totalCount);
        response.put("page", page);
        response.put("size", size);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/record")
    public ResponseEntity<Map<String, Object>> recordView(
            Authentication authentication,
            @RequestParam Long viewedUserId) {
        try {
            Long viewerId = (Long) authentication.getPrincipal();
            profileViewService.recordView(viewerId, viewedUserId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @GetMapping("/count")
    public ResponseEntity<Map<String, Object>> getViewCount(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        long count = profileViewService.getViewCount(userId);

        Map<String, Object> response = new HashMap<>();
        response.put("count", count);

        return ResponseEntity.ok(response);
    }
}
