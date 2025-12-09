package com.trish.service;

import com.trish.dto.MessageRequest;
import com.trish.model.Match;
import com.trish.model.Message;
import com.trish.model.User;
import com.trish.repository.MatchRepository;
import com.trish.repository.MessageRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessageService {
    
    @Autowired
    private MessageRepository messageRepository;
    
    @Autowired
    private MatchRepository matchRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Transactional
    public Message sendMessage(Long senderId, MessageRequest request) {
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));
        
        Match match = matchRepository.findById(request.getMatchId())
                .orElseThrow(() -> new IllegalArgumentException("Match not found"));
        
        // Verify sender is part of the match
        if (!match.getUser1().getId().equals(senderId) && !match.getUser2().getId().equals(senderId)) {
            throw new IllegalArgumentException("Unauthorized to send message in this match");
        }
        
        // Determine receiver
        User receiver = match.getUser1().getId().equals(senderId) ? match.getUser2() : match.getUser1();
        
        // Create message
        Message message = new Message();
        message.setMatch(match);
        message.setSender(sender);
        message.setReceiver(receiver);
        message.setContent(request.getContent());
        message.setIsRead(false);
        
        return messageRepository.save(message);
    }
    
    public List<Message> getConversation(Long userId, Long matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new IllegalArgumentException("Match not found"));
        
        // Verify user is part of the match
        if (!match.getUser1().getId().equals(userId) && !match.getUser2().getId().equals(userId)) {
            throw new IllegalArgumentException("Unauthorized to view this conversation");
        }
        
        return messageRepository.findByMatchIdOrderBySentAt(matchId);
    }
    
    @Transactional
    public void markAsRead(Long userId, Long messageId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));
        
        // Verify user is the receiver
        if (!message.getReceiver().getId().equals(userId)) {
            throw new IllegalArgumentException("Unauthorized to mark this message as read");
        }
        
        message.setIsRead(true);
        message.setReadAt(LocalDateTime.now());
        messageRepository.save(message);
    }
    
    public long getUnreadCount(Long userId) {
        return messageRepository.countUnreadMessagesByReceiver(userId);
    }
}
