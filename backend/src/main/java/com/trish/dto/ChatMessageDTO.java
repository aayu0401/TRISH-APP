package com.trish.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private Long id;
    private Long matchId;
    private Long senderId;
    private Long recipientId;
    private String content;
    private Boolean isRead;
    private LocalDateTime sentAt;
    private String messageType;
    private Long referenceId;
}

