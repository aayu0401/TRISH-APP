package com.trish.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class AdvancedMatchRequestDTO {
    private AIUserProfileDTO user;
    private List<AIUserProfileDTO> candidates;
    private Integer maxDistance;
    private Map<String, Double> customWeights;
}
