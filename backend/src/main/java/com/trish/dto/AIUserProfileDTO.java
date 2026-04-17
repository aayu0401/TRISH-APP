package com.trish.dto;

import lombok.Data;
import java.util.List;

@Data
public class AIUserProfileDTO {
    private String id;
    private String name;
    private Integer age;
    private List<String> interests;
    private Double latitude;
    private Double longitude;
    private String mbtiType;
    private String enneagramType;
    private BigFiveTraitsDTO bigFive;
    private List<String> values;
    private BehavioralMetricsDTO behavioralMetrics;
}
