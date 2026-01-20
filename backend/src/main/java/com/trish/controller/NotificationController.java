package com.trish.controller;

import com.trish.model.Notification;
import com.trish.security.JwtUtil;
import com.trish.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    
    private final NotificationService notificationService;
    private final JwtUtil jwtUtil;
    
    @GetMapping
    public ResponseEntity<?> getNotifications(
            @RequestHeader("Authorization") String token,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Long userId = jwtUtil.extractUserId(token.substring(7));
            Page<Notification> notifications = notificationService.getUserNotifications(userId, PageRequest.of(page, size));
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "notifications", notifications.getContent(),
                "totalPages", notifications.getTotalPages(),
                "totalElements", notifications.getTotalElements()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id) {
        try {
            notificationService.markAsRead(id);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Notification marked as read"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead(@RequestHeader("Authorization") String token) {
        try {
            Long userId = jwtUtil.extractUserId(token.substring(7));
            notificationService.markAllAsRead(userId);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "All notifications marked as read"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/unread-count")
    public ResponseEntity<?> getUnreadCount(@RequestHeader("Authorization") String token) {
        try {
            Long userId = jwtUtil.extractUserId(token.substring(7));
            long count = notificationService.getUnreadCount(userId);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "count", count
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
