package com.trish.controller;

import com.trish.dto.ChatMessageDTO;
import com.trish.dto.MessageRequest;
import com.trish.model.Message;
import com.trish.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.time.LocalDateTime;

@Controller
public class ChatWSController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private MessageService messageService;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload MessageRequest request, Principal principal) {
        Long senderId = null;
        if (principal instanceof Authentication authentication) {
            Object authPrincipal = authentication.getPrincipal();
            if (authPrincipal instanceof Long id) {
                senderId = id;
            } else if (authPrincipal instanceof String s) {
                try {
                    senderId = Long.parseLong(s);
                } catch (NumberFormatException ignored) {
                    senderId = null;
                }
            }
        }

        Long requestSenderId = request.getSenderId();
        if (senderId != null) {
            if (requestSenderId != null && !requestSenderId.equals(senderId)) {
                throw new IllegalArgumentException("Sender mismatch");
            }
        } else {
            senderId = requestSenderId;
        }

        if (senderId == null) {
            throw new IllegalArgumentException("Unauthorized");
        }

        Message savedMessage = messageService.sendMessage(senderId, request);

        Long recipientId = savedMessage.getReceiver() != null ? savedMessage.getReceiver().getId() : request.getRecipientId();

        ChatMessageDTO payload = new ChatMessageDTO(
                savedMessage.getId(),
                savedMessage.getMatch() != null ? savedMessage.getMatch().getId() : request.getMatchId(),
                savedMessage.getSender() != null ? savedMessage.getSender().getId() : senderId,
                recipientId,
                savedMessage.getContent(),
                savedMessage.getIsRead(),
                savedMessage.getSentAt() != null ? savedMessage.getSentAt() : LocalDateTime.now(),
                savedMessage.getMessageType() != null ? savedMessage.getMessageType().name() : null,
                savedMessage.getReferenceId()
        );

        // Notify both users (or rely on queue for simplicity)
        if (recipientId != null) {
            messagingTemplate.convertAndSend("/queue/messages-" + recipientId, payload);
        }
        messagingTemplate.convertAndSend("/queue/messages-" + senderId, payload);
    }
}
