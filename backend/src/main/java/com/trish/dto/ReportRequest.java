package com.trish.dto;

import com.trish.model.Report.ReportCategory;
import lombok.Data;

@Data
public class ReportRequest {
    private Long reportedUserId;
    private ReportCategory category;
    private String reason;
    private String evidence;
}
