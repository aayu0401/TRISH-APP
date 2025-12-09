package com.trish.repository;

import com.trish.model.Subscription;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    Optional<Subscription> findByUserAndStatus(User user, Subscription.SubscriptionStatus status);
    List<Subscription> findByUser(User user);
    List<Subscription> findByUserOrderByCreatedAtDesc(User user);
}
