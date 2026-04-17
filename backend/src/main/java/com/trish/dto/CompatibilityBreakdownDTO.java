package com.trish.dto;

import lombok.Data;
import java.util.List;

@Data
public class CompatibilityBreakdownDTO {
    private Double interestScore;
    private Double personalityScore;
    private Double ageScore;
    private Double locationScore;
    private Double valueScore;
    private Double communicationScore;
    private Double activityScore;
}
