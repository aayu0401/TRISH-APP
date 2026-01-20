package com.trish.repository;

import com.trish.model.Report;
import com.trish.model.Report.ReportStatus;
import com.trish.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    
    List<Report> findByReporter(User reporter);
    
    List<Report> findByReported(User reported);
    
    Page<Report> findByStatus(ReportStatus status, Pageable pageable);
    
    Page<Report> findAllByOrderByReportedAtDesc(Pageable pageable);
    
    @Query("SELECT COUNT(r) FROM Report r WHERE r.reported.id = :userId AND r.status = 'PENDING'")
    long countPendingReportsAgainstUser(Long userId);
    
    @Query("SELECT r FROM Report r WHERE r.status = 'PENDING' ORDER BY r.reportedAt ASC")
    Page<Report> findPendingReports(Pageable pageable);
    
    boolean existsByReporterAndReported(User reporter, User reported);
}
