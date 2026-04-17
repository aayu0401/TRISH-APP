package com.trish.service;

import com.trish.model.EmailVerificationToken;
import com.trish.model.User;
import com.trish.repository.EmailVerificationTokenRepository;
import com.trish.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Optional;

@Service
public class EmailVerificationService {

    private static final Logger log = LoggerFactory.getLogger(EmailVerificationService.class);
    private static final int TOKEN_VALIDITY_HOURS = 24;
    private static final SecureRandom RANDOM = new SecureRandom();

    @Autowired
    private EmailVerificationTokenRepository tokenRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${app.frontend-url:http://localhost:3000}")
    private String frontendUrl;

    @Value("${app.mail-from:no-reply@trish.app}")
    private String mailFrom;

    @Transactional
    public void sendVerificationEmail(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        tokenRepository.findByUser(user).ifPresent(tokenRepository::delete);

        String token = generateToken();
        EmailVerificationToken evt = new EmailVerificationToken();
        evt.setToken(token);
        evt.setUser(user);
        evt.setCreatedAt(LocalDateTime.now());
        evt.setExpiresAt(LocalDateTime.now().plusHours(TOKEN_VALIDITY_HOURS));
        tokenRepository.save(evt);

        String verifyUrl = frontendUrl + "/verify-email?token=" + token;
        String subject = "Verify your TRISH email address";

        if (mailSender != null) {
            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setFrom(mailFrom);
                message.setTo(user.getEmail());
                message.setSubject(subject);
                message.setText(String.format(
                    "Hi %s,\n\nPlease verify your email by clicking the link below:\n\n%s\n\nThis link expires in 24 hours.\n\n- The TRISH Team",
                    user.getName(), verifyUrl
                ));
                mailSender.send(message);
                log.info("Verification email sent to {}", user.getEmail());
            } catch (Exception e) {
                log.warn("Failed to send verification email, logging link: {}", e.getMessage());
                log.info("VERIFICATION LINK for {}: {}", user.getEmail(), verifyUrl);
            }
        } else {
            log.info("No mail sender configured. VERIFICATION LINK for {}: {}", user.getEmail(), verifyUrl);
        }
    }

    @Transactional
    public boolean verifyToken(String token) {
        Optional<EmailVerificationToken> opt = tokenRepository.findByToken(token);
        if (opt.isEmpty()) return false;

        EmailVerificationToken evt = opt.get();
        if (evt.getExpiresAt().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(evt);
            return false;
        }

        User user = evt.getUser();
        user.setEmailVerified(true);
        userRepository.save(user);
        tokenRepository.delete(evt);
        return true;
    }

    private String generateToken() {
        byte[] bytes = new byte[48];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
