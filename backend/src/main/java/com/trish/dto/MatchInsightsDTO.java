package com.trish.dto;

import lombok.Data;
import java.util.List;

@Data
public class MatchInsightsDTO {
    private List<String> strengths;
    private List<String> growthAreas;
    private List<String> conversationStarters;
    private String compatibilitySummary;
}
