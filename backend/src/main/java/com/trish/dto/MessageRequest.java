package com.trish.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class MessageRequest {
    
    @NotNull(message = "Match ID is required")
    private Long matchId;
    
    @NotBlank(message = "Message content is required")
    @Size(max = 2000, message = "Message cannot exceed 2000 characters")
    private String content;
}
