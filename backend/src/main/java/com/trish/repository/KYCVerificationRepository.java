package com.trish.repository;

import com.trish.model.KYCVerification;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface KYCVerificationRepository extends JpaRepository<KYCVerification, Long> {
    Optional<KYCVerification> findByUser(User user);
    Optional<KYCVerification> findByUserId(Long userId);
}
