package com.trish.repository;

import com.trish.model.Gift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GiftRepository extends JpaRepository<Gift, Long> {
    List<Gift> findByCategory(Gift.GiftCategory category);
    List<Gift> findByType(Gift.GiftType type);
    List<Gift> findByCategoryAndType(Gift.GiftCategory category, Gift.GiftType type);
    List<Gift> findByIsAvailableTrue();
    List<Gift> findByIsAvailableTrueOrderByPopularityScoreDesc();
}
