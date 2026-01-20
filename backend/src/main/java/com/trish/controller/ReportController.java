package com.trish.controller;

import com.trish.dto.ReportRequest;
import com.trish.model.Report;
import com.trish.model.Report.ReportStatus;
import com.trish.security.JwtUtil;
import com.trish.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/report")
@RequiredArgsConstructor
public class ReportController {
    
    private final ReportService reportService;
    private final JwtUtil jwtUtil;
    
    @PostMapping
    public ResponseEntity<?> submitReport(
            @RequestHeader("Authorization") String token,
            @RequestBody ReportRequest request) {
        try {
            Long reporterId = jwtUtil.extractUserId(token.substring(7));
            
            Report report = reportService.submitReport(
                reporterId,
                request.getReportedUserId(),
                request.getCategory(),
                request.getReason(),
                request.getEvidence()
            );
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Report submitted successfully",
                "report", report
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/my-reports")
    public ResponseEntity<?> getMyReports(@RequestHeader("Authorization") String token) {
        try {
            Long userId = jwtUtil.extractUserId(token.substring(7));
            List<Report> reports = reportService.getMyReports(userId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "reports", reports
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/admin/all")
    public ResponseEntity<?> getAllReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Page<Report> reports = reportService.getAllReports(PageRequest.of(page, size));
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "reports", reports.getContent(),
                "totalPages", reports.getTotalPages(),
                "totalElements", reports.getTotalElements()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @GetMapping("/admin/pending")
    public ResponseEntity<?> getPendingReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Page<Report> reports = reportService.getPendingReports(PageRequest.of(page, size));
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "reports", reports.getContent(),
                "totalPages", reports.getTotalPages(),
                "totalElements", reports.getTotalElements()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
    
    @PutMapping("/admin/{reportId}")
    public ResponseEntity<?> reviewReport(
            @PathVariable Long reportId,
            @RequestParam ReportStatus status,
            @RequestParam(required = false) String adminNotes) {
        try {
            Report report = reportService.reviewReport(reportId, status, adminNotes);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Report reviewed successfully",
                "report", report
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
