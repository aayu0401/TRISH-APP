package com.trish.repository;

import com.trish.model.Swipe;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SwipeRepository extends JpaRepository<Swipe, Long> {
    
    Optional<Swipe> findBySwiperAndSwiped(User swiper, User swiped);
    
    boolean existsBySwiperAndSwiped(User swiper, User swiped);
    
    @Query("SELECT s FROM Swipe s WHERE s.swiper.id = :swiperId AND s.type = 'LIKE'")
    List<Swipe> findLikesBySwiper(@Param("swiperId") Long swiperId);
    
    @Query("SELECT s FROM Swipe s WHERE s.swiped.id = :swipedId AND s.type = 'LIKE'")
    List<Swipe> findLikesForUser(@Param("swipedId") Long swipedId);
    
    @Query("SELECT s.swiped.id FROM Swipe s WHERE s.swiper.id = :userId")
    List<Long> findSwipedUserIds(@Param("userId") Long userId);

    Optional<Swipe> findTopBySwiperIdAndTypeOrderBySwipedAtDesc(Long swiperId, Swipe.SwipeType type);
}
