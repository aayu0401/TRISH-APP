package com.trish.repository;

import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    boolean existsByEmail(String email);
    
    @Query("SELECT u FROM User u WHERE u.isActive = true AND u.id != :userId " +
           "AND u.gender = :interestedInGender " +
           "AND (u.dateOfBirth BETWEEN :minBirthDate AND :maxBirthDate) " +
           "AND u.latitude IS NOT NULL AND u.longitude IS NOT NULL")
    List<User> findPotentialMatches(
        @Param("userId") Long userId,
        @Param("interestedInGender") User.Gender interestedInGender,
        @Param("minBirthDate") java.time.LocalDate minBirthDate,
        @Param("maxBirthDate") java.time.LocalDate maxBirthDate
    );
    
    @Query("SELECT u FROM User u WHERE u.isActive = true AND u.id IN :userIds")
    List<User> findActiveUsersByIds(@Param("userIds") List<Long> userIds);
}
