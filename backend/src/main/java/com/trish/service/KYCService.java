package com.trish.service;

import com.trish.model.*;
import com.trish.repository.*;
import com.trish.dto.KYCSubmitRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class KYCService {

    @Autowired
    private KYCVerificationRepository kycRepository;

    @Autowired
    private UserRepository userRepository;

    public Optional<KYCVerification> getKYCStatus(User user) {
        return kycRepository.findByUser(user);
    }

    @Transactional
    public KYCVerification submitKYC(User user, KYCSubmitRequest request, MultipartFile[] documents, MultipartFile selfie) {
        KYCVerification kyc = kycRepository.findByUser(user).orElse(new KYCVerification());
        
        kyc.setUser(user);
        kyc.setType(KYCVerification.KYCType.valueOf(request.getType().toUpperCase()));
        kyc.setDocumentNumber(request.getDocumentNumber());
        kyc.setStatus(KYCVerification.VerificationStatus.SUBMITTED);
        
        // In production, upload files to cloud storage (S3, etc.)
        // kyc.setDocumentImageUrl(uploadToCloud(documents));
        // kyc.setSelfieImageUrl(uploadToCloud(selfie));
        
        return kycRepository.save(kyc);
    }

    @Transactional
    public boolean verifyAadhar(User user, String aadharNumber, String otp) {
        // In production, integrate with Aadhar verification API
        KYCVerification kyc = kycRepository.findByUser(user).orElse(new KYCVerification());
        kyc.setUser(user);
        kyc.setType(KYCVerification.KYCType.AADHAR);
        kyc.setDocumentNumber(aadharNumber);
        kyc.setGovernmentIdVerified(true);
        kyc.setStatus(KYCVerification.VerificationStatus.VERIFIED);
        kyc.setVerifiedAt(LocalDateTime.now());
        kycRepository.save(kyc);
        return true;
    }

    public boolean sendAadharOTP(String aadharNumber) {
        // In production, call Aadhar OTP API
        return true;
    }

    @Transactional
    public boolean verifyPAN(User user, String panNumber, String name, String dob) {
        // In production, integrate with PAN verification API
        KYCVerification kyc = kycRepository.findByUser(user).orElse(new KYCVerification());
        kyc.setUser(user);
        kyc.setType(KYCVerification.KYCType.PAN);
        kyc.setDocumentNumber(panNumber);
        kyc.setGovernmentIdVerified(true);
        kyc.setStatus(KYCVerification.VerificationStatus.VERIFIED);
        kyc.setVerifiedAt(LocalDateTime.now());
        kycRepository.save(kyc);
        return true;
    }

    @Transactional
    public boolean verifyPhone(User user, String phoneNumber, String otp) {
        // In production, verify OTP
        KYCVerification kyc = kycRepository.findByUser(user).orElse(new KYCVerification());
        kyc.setUser(user);
        kyc.setPhoneVerified(true);
        kycRepository.save(kyc);
        return true;
    }

    @Transactional
    public boolean verifyEmail(User user, String email, String otp) {
        // In production, verify OTP
        KYCVerification kyc = kycRepository.findByUser(user).orElse(new KYCVerification());
        kyc.setUser(user);
        kyc.setEmailVerified(true);
        kycRepository.save(kyc);
        return true;
    }

    @Transactional
    public boolean submitFaceVerification(User user, MultipartFile faceImage) {
        // In production, use face recognition API
        KYCVerification kyc = kycRepository.findByUser(user).orElse(new KYCVerification());
        kyc.setUser(user);
        kyc.setFaceVerified(true);
        kycRepository.save(kyc);
        return true;
    }

    public Map<String, Object> getSafetyVerification(User user) {
        KYCVerification kyc = kycRepository.findByUser(user).orElse(null);
        Map<String, Object> safety = new HashMap<>();
        
        if (kyc != null) {
            safety.put("phoneVerified", kyc.getPhoneVerified());
            safety.put("emailVerified", kyc.getEmailVerified());
            safety.put("faceVerified", kyc.getFaceVerified());
            safety.put("governmentIdVerified", kyc.getGovernmentIdVerified());
            safety.put("status", kyc.getStatus());
        } else {
            safety.put("phoneVerified", false);
            safety.put("emailVerified", false);
            safety.put("faceVerified", false);
            safety.put("governmentIdVerified", false);
            safety.put("status", "NOT_STARTED");
        }
        
        return safety;
    }
}
