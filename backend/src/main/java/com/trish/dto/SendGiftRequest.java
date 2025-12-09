package com.trish.dto;

import lombok.Data;

@Data
public class SendGiftRequest {
    private Long receiverId;
    private Long giftId;
    private String message;
    private String deliveryAddress;
}
