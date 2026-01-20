package com.trish.controller;

import com.trish.dto.BlockRequest;
import com.trish.model.Block;
import com.trish.security.JwtUtil;
import com.trish.service.BlockService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/block")
@RequiredArgsConstructor
public class BlockController {
    
    private final BlockService blockService;
    private final JwtUtil jwtUtil;
    
    @PostMapping("/{userId}")
    public ResponseEntity<?> blockUser(
            @RequestHeader("Authorization") String token,
            @PathVariable Long userId,
            @RequestBody(required = false) BlockRequest request) {
        try {
            Long currentUserId = jwtUtil.extractUserId(token.substring(7));
            String reason = request != null ? request.getReason() : null;
            
            Block block = blockService.blockUser(currentUserId, userId, reason);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "User blocked successfully");
            response.put("block", block);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @DeleteMapping("/{userId}")
    public ResponseEntity<?> unblockUser(
            @RequestHeader("Authorization") String token,
            @PathVariable Long userId) {
        try {
            Long currentUserId = jwtUtil.extractUserId(token.substring(7));
            blockService.unblockUser(currentUserId, userId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "User unblocked successfully"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/list")
    public ResponseEntity<?> getBlockedUsers(@RequestHeader("Authorization") String token) {
        try {
            Long currentUserId = jwtUtil.extractUserId(token.substring(7));
            List<Block> blockedUsers = blockService.getBlockedUsers(currentUserId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "blockedUsers", blockedUsers
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/check/{userId}")
    public ResponseEntity<?> checkIfBlocked(
            @RequestHeader("Authorization") String token,
            @PathVariable Long userId) {
        try {
            Long currentUserId = jwtUtil.extractUserId(token.substring(7));
            boolean isBlocked = blockService.isBlocked(currentUserId, userId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "isBlocked", isBlocked
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
