package com.trish.service;

import com.trish.model.Notification;
import com.trish.model.Notification.NotificationType;
import com.trish.model.User;
import com.trish.repository.FCMTokenRepository;
import com.trish.repository.NotificationRepository;
import com.trish.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NotificationService {
    
    private final NotificationRepository notificationRepository;
    private final FCMTokenRepository fcmTokenRepository;
    private final UserRepository userRepository;
    
    @Transactional
    public Notification createNotification(Long userId, NotificationType type, String title, String body, String data) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        Notification notification = new Notification();
        notification.setUser(user);
        notification.setType(type);
        notification.setTitle(title);
        notification.setBody(body);
        notification.setData(data);
        
        Notification saved = notificationRepository.save(notification);
        
        // Send push notification (integrate with FCM in production)
        sendPushNotification(user, title, body, data);
        
        return saved;
    }
    
    private void sendPushNotification(User user, String title, String body, String data) {
        // In production, integrate with Firebase Cloud Messaging
        var tokens = fcmTokenRepository.findByUser(user);
        for (var tokenEntity : tokens) {
            // Send FCM notification using token
            // FCM.send(tokenEntity.getToken(), title, body, data);
        }
    }
    
    public Page<Notification> getUserNotifications(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return notificationRepository.findByUserOrderByCreatedAtDesc(user, pageable);
    }
    
    @Transactional
    public void markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
            .orElseThrow(() -> new RuntimeException("Notification not found"));
        notification.setRead(true);
        notificationRepository.save(notification);
    }
    
    public long getUnreadCount(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return notificationRepository.countUnreadByUser(user);
    }
    
    @Transactional
    public void markAllAsRead(Long userId) {
        Page<Notification> notifications = getUserNotifications(userId, Pageable.unpaged());
        notifications.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(notifications);
    }
}
