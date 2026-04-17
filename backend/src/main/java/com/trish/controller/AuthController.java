package com.trish.controller;

import com.trish.dto.AuthResponse;
import com.trish.dto.LoginRequest;
import com.trish.dto.RegisterRequest;
import com.trish.service.AuthService;
import com.trish.service.EmailVerificationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private AuthService authService;

    @Autowired
    private EmailVerificationService emailVerificationService;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            try {
                emailVerificationService.sendVerificationEmail(response.getUserId());
            } catch (Exception e) {
                // Don't fail registration if email send fails
            }
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/send-verification")
    public ResponseEntity<Map<String, Object>> sendVerification(Authentication authentication) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            emailVerificationService.sendVerificationEmail(userId);
            return ResponseEntity.ok(Map.of("success", true, "message", "Verification email sent"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/verify-email")
    public ResponseEntity<Map<String, Object>> verifyEmail(@RequestParam String token) {
        boolean verified = emailVerificationService.verifyToken(token);
        if (verified) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Email verified successfully"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", "Invalid or expired token"));
        }
    }
}
