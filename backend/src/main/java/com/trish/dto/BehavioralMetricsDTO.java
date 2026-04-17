package com.trish.dto;

import lombok.Data;
import java.util.List;

@Data
public class BehavioralMetricsDTO {
    private Double avgResponseTimeMinutes;
    private Integer avgMessageLength;
    private List<Integer> activeHours;
    private Double swipeSelectivity;
    private Double conversationInitiationRate;
}
