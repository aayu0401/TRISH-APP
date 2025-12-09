package com.trish.repository;

import com.trish.model.Photo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PhotoRepository extends JpaRepository<Photo, Long> {
    
    List<Photo> findByUserIdOrderByDisplayOrderAsc(Long userId);
    
    long countByUserId(Long userId);
}
