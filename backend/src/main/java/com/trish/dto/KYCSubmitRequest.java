package com.trish.dto;

import lombok.Data;

@Data
public class KYCSubmitRequest {
    private String type;
    private String documentNumber;
    private String name;
    private String dateOfBirth;
}
