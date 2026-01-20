package com.trish.dto;

import lombok.Data;

@Data
public class BlockRequest {
    private Long userId;
    private String reason;
}
