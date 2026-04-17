package com.trish.dto;

import com.trish.model.Swipe;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SwipeRequest {

    @NotNull(message = "Target user ID is required")
    private Long targetUserId;

    @NotNull(message = "Swipe type is required")
    private Swipe.SwipeType type;

    private Boolean blindDate = false;
}
