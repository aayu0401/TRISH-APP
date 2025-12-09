package com.trish.dto;

import lombok.Data;

@Data
public class WalletRequest {
    private Double amount;
    private String paymentMethod;
    private String bankAccountNumber;
    private String ifscCode;
    private String accountHolderName;
}
