package com.trish.controller;

import com.trish.model.*;
import com.trish.service.KYCService;
import com.trish.dto.KYCSubmitRequest;
import com.trish.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class KYCController {

    @Autowired
    private KYCService kycService;

    @Autowired
    private JwtUtil jwtUtil;

    @GetMapping("/kyc/status")
    public ResponseEntity<KYCVerification> getKYCStatus(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return kycService.getKYCStatus(user)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/kyc/submit")
    public ResponseEntity<KYCVerification> submitKYC(
            @RequestPart("type") String type,
            @RequestPart("documentData") String documentData,
            @RequestPart("documentImages") MultipartFile[] documents,
            @RequestPart(value = "selfieImage", required = false) MultipartFile selfie,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        KYCSubmitRequest request = new KYCSubmitRequest();
        request.setType(type);
        // Parse documentData JSON if needed
        
        KYCVerification kyc = kycService.submitKYC(user, request, documents, selfie);
        return ResponseEntity.ok(kyc);
    }

    @PostMapping("/kyc/verify-aadhar")
    public ResponseEntity<String> verifyAadhar(
            @RequestBody Map<String, String> request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean verified = kycService.verifyAadhar(
                user,
                request.get("aadharNumber"),
                request.get("otp")
        );
        
        if (verified) {
            return ResponseEntity.ok("Aadhar verified successfully");
        }
        return ResponseEntity.badRequest().body("Verification failed");
    }

    @PostMapping("/kyc/send-aadhar-otp")
    public ResponseEntity<String> sendAadharOTP(@RequestBody Map<String, String> request) {
        boolean sent = kycService.sendAadharOTP(request.get("aadharNumber"));
        
        if (sent) {
            return ResponseEntity.ok("OTP sent successfully");
        }
        return ResponseEntity.badRequest().body("Failed to send OTP");
    }

    @PostMapping("/kyc/verify-pan")
    public ResponseEntity<String> verifyPAN(
            @RequestBody Map<String, String> request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean verified = kycService.verifyPAN(
                user,
                request.get("panNumber"),
                request.get("name"),
                request.get("dob")
        );
        
        if (verified) {
            return ResponseEntity.ok("PAN verified successfully");
        }
        return ResponseEntity.badRequest().body("Verification failed");
    }

    @GetMapping("/safety/verification")
    public ResponseEntity<Map<String, Object>> getSafetyVerification(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(kycService.getSafetyVerification(user));
    }

    @PostMapping("/safety/verify-phone")
    public ResponseEntity<String> verifyPhone(
            @RequestBody Map<String, String> request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean verified = kycService.verifyPhone(
                user,
                request.get("phoneNumber"),
                request.get("otp")
        );
        
        if (verified) {
            return ResponseEntity.ok("Phone verified successfully");
        }
        return ResponseEntity.badRequest().body("Verification failed");
    }

    @PostMapping("/safety/verify-email")
    public ResponseEntity<String> verifyEmail(
            @RequestBody Map<String, String> request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean verified = kycService.verifyEmail(
                user,
                request.get("email"),
                request.get("otp")
        );
        
        if (verified) {
            return ResponseEntity.ok("Email verified successfully");
        }
        return ResponseEntity.badRequest().body("Verification failed");
    }

    @PostMapping("/safety/verify-face")
    public ResponseEntity<String> submitFaceVerification(
            @RequestPart("faceImage") MultipartFile faceImage,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean verified = kycService.submitFaceVerification(user, faceImage);
        
        if (verified) {
            return ResponseEntity.ok("Face verification submitted");
        }
        return ResponseEntity.badRequest().body("Verification failed");
    }
}
