package com.trish.dto;

import lombok.Data;

@Data
public class SubscriptionRequest {
    private String plan;
    private String paymentMethod;
    private String promoCode;
}
