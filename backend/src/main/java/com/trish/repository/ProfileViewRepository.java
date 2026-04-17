package com.trish.repository;

import com.trish.model.ProfileView;
import com.trish.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProfileViewRepository extends JpaRepository<ProfileView, Long> {

    Page<ProfileView> findByViewedUserOrderByViewedAtDesc(User viewedUser, Pageable pageable);
    
    @Query("SELECT COUNT(DISTINCT pv.viewer) FROM ProfileView pv WHERE pv.viewedUser = :user")
    long countUniqueViewers(User user);
    
    Optional<ProfileView> findFirstByViewedUserAndViewerOrderByViewedAtDesc(User viewedUser, User viewer);
}
