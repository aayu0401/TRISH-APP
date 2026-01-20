package com.trish.service;

import com.trish.model.Report;
import com.trish.model.Report.ReportStatus;
import com.trish.model.User;
import com.trish.repository.ReportRepository;
import com.trish.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {
    
    private final ReportRepository reportRepository;
    private final UserRepository userRepository;
    private static final int AUTO_BAN_THRESHOLD = 5;
    
    @Transactional
    public Report submitReport(Long reporterId, Long reportedId, Report.ReportCategory category, 
                               String reason, String evidence) {
        if (reporterId.equals(reportedId)) {
            throw new IllegalArgumentException("Cannot report yourself");
        }
        
        User reporter = userRepository.findById(reporterId)
            .orElseThrow(() -> new RuntimeException("Reporter not found"));
        User reported = userRepository.findById(reportedId)
            .orElseThrow(() -> new RuntimeException("Reported user not found"));
        
        if (reportRepository.existsByReporterAndReported(reporter, reported)) {
            throw new IllegalArgumentException("You have already reported this user");
        }
        
        Report report = new Report();
        report.setReporter(reporter);
        report.setReported(reported);
        report.setCategory(category);
        report.setReason(reason);
        report.setEvidence(evidence);
        report.setStatus(ReportStatus.PENDING);
        
        Report savedReport = reportRepository.save(report);
        
        // Check if user should be auto-banned
        long reportCount = reportRepository.countPendingReportsAgainstUser(reportedId);
        if (reportCount >= AUTO_BAN_THRESHOLD) {
            // Auto-ban logic - could be implemented in UserService
            reported.setActive(false);
            userRepository.save(reported);
        }
        
        return savedReport;
    }
    
    public List<Report> getMyReports(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return reportRepository.findByReporter(user);
    }
    
    public Page<Report> getAllReports(Pageable pageable) {
        return reportRepository.findAllByOrderByReportedAtDesc(pageable);
    }
    
    public Page<Report> getPendingReports(Pageable pageable) {
        return reportRepository.findPendingReports(pageable);
    }
    
    public Page<Report> getReportsByStatus(ReportStatus status, Pageable pageable) {
        return reportRepository.findByStatus(status, pageable);
    }
    
    @Transactional
    public Report reviewReport(Long reportId, ReportStatus newStatus, String adminNotes) {
        Report report = reportRepository.findById(reportId)
            .orElseThrow(() -> new RuntimeException("Report not found"));
        
        report.setStatus(newStatus);
        report.setAdminNotes(adminNotes);
        report.setReviewedAt(LocalDateTime.now());
        
        return reportRepository.save(report);
    }
    
    public long getReportCountAgainstUser(Long userId) {
        return reportRepository.countPendingReportsAgainstUser(userId);
    }
}
