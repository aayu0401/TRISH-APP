package com.trish.repository;

import com.trish.model.PersonalityProfile;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface PersonalityProfileRepository extends JpaRepository<PersonalityProfile, Long> {
    Optional<PersonalityProfile> findByUser(User user);
    Optional<PersonalityProfile> findByUserId(Long userId);
}
