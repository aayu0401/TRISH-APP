package com.trish.controller;

import com.trish.dto.MessageRequest;
import com.trish.model.Message;
import com.trish.service.MessageService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/messages")
public class MessageController {
    
    @Autowired
    private MessageService messageService;
    
    @PostMapping
    public ResponseEntity<Message> sendMessage(
            Authentication authentication,
            @Valid @RequestBody MessageRequest request) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            Message message = messageService.sendMessage(userId, request);
            return ResponseEntity.ok(message);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    @GetMapping("/match/{matchId}")
    public ResponseEntity<List<Message>> getConversation(
            Authentication authentication,
            @PathVariable Long matchId) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            List<Message> messages = messageService.getConversation(userId, matchId);
            return ResponseEntity.ok(messages);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    @PutMapping("/{messageId}/read")
    public ResponseEntity<Void> markAsRead(
            Authentication authentication,
            @PathVariable Long messageId) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            messageService.markAsRead(userId, messageId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        long count = messageService.getUnreadCount(userId);
        
        Map<String, Long> response = new HashMap<>();
        response.put("count", count);
        return ResponseEntity.ok(response);
    }
}
