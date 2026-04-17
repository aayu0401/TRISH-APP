package com.trish.dto;

import lombok.Data;

@Data
public class AdvancedMatchResultDTO {
    private String id;
    private String name;
    private Double overallScore;
    private CompatibilityBreakdownDTO breakdown;
    private MatchInsightsDTO insights;
    private Double distance;
    private Double predictedConversationQuality;
}
