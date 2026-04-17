package com.trish.service;

import com.trish.dto.ChatMessageDTO;
import com.trish.model.*;
import com.trish.repository.*;
import com.trish.dto.SendGiftRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class GiftService {

    @Autowired
    private GiftRepository giftRepository;

    @Autowired
    private GiftTransactionRepository giftTransactionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletService walletService;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private MatchRepository matchRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public List<Gift> getAllGifts() {
        return giftRepository.findByIsAvailableTrue();
    }

    public List<Gift> getGiftsByCategory(Gift.GiftCategory category) {
        return giftRepository.findByCategory(category);
    }

    public List<Gift> getGiftsByCategoryAndType(Gift.GiftCategory category, Gift.GiftType type) {
        return giftRepository.findByCategoryAndType(category, type);
    }

    public List<Gift> getGiftsByType(Gift.GiftType type) {
        return giftRepository.findByType(type);
    }

    public List<Gift> getPopularGifts() {
        return giftRepository.findByIsAvailableTrueOrderByPopularityScoreDesc();
    }

    public Optional<Gift> getGiftById(Long id) {
        return giftRepository.findById(id);
    }

    @Transactional
    public GiftTransaction sendGift(User sender, SendGiftRequest request) {
        Gift gift = giftRepository.findById(request.getGiftId())
                .orElseThrow(() -> new IllegalArgumentException("Gift not found"));

        User receiver = userRepository.findById(request.getReceiverId())
                .orElseThrow(() -> new IllegalArgumentException("Receiver not found"));

        // Deduct from wallet
        walletService.deductFromWallet(sender, gift.getPrice(), "Gift purchase: " + gift.getName());

        GiftTransaction transaction = new GiftTransaction();
        transaction.setSender(sender);
        transaction.setReceiver(receiver);
        transaction.setGift(gift);
        transaction.setAmount(gift.getPrice());
        transaction.setMessage(request.getMessage());
        transaction.setDeliveryAddress(request.getDeliveryAddress());
        transaction.setStatus(GiftTransaction.TransactionStatus.PENDING);

        GiftTransaction savedTransaction = giftTransactionRepository.save(transaction);

        // Increment popularity
        gift.setPopularityScore((gift.getPopularityScore() != null ? gift.getPopularityScore() : 0) + 1);
        giftRepository.save(gift);

        // Create notification message in chat if match exists
        matchRepository.findMatchBetweenUsers(sender.getId(), receiver.getId()).ifPresent(match -> {
            Message message = new Message();
            message.setMatch(match);
            message.setSender(sender);
            message.setReceiver(receiver);
            message.setContent("\uD83C\uDF81 Sent you a " + gift.getName() + "!"
                    + (request.getMessage() != null ? "\n\"" + request.getMessage() + "\"" : ""));
            message.setMessageType(Message.MessageType.GIFT);
            message.setReferenceId(savedTransaction.getId());
            Message savedMsg = messageRepository.save(message);

            // Notify users via WebSocket
            ChatMessageDTO payload = new ChatMessageDTO(
                    savedMsg.getId(),
                    match.getId(),
                    sender.getId(),
                    receiver.getId(),
                    savedMsg.getContent(),
                    savedMsg.getIsRead(),
                    savedMsg.getSentAt() != null ? savedMsg.getSentAt() : LocalDateTime.now(),
                    savedMsg.getMessageType() != null ? savedMsg.getMessageType().name() : null,
                    savedMsg.getReferenceId()
            );
            messagingTemplate.convertAndSend("/queue/messages-" + receiver.getId(), payload);
            messagingTemplate.convertAndSend("/queue/messages-" + sender.getId(), payload);
        });

        return savedTransaction;
    }

    public List<GiftTransaction> getSentGifts(User user) {
        return giftTransactionRepository.findBySenderOrderByCreatedAtDesc(user);
    }

    public List<GiftTransaction> getReceivedGifts(User user) {
        return giftTransactionRepository.findByReceiverOrderByCreatedAtDesc(user);
    }

    public Optional<GiftTransaction> trackGift(Long transactionId) {
        return giftTransactionRepository.findById(transactionId);
    }

    @Transactional
    public boolean cancelGift(Long transactionId, User user) {
        Optional<GiftTransaction> transactionOpt = giftTransactionRepository.findById(transactionId);
        if (transactionOpt.isPresent()) {
            GiftTransaction transaction = transactionOpt.get();
            if (transaction.getSender().getId().equals(user.getId()) &&
                    transaction.getStatus() == GiftTransaction.TransactionStatus.PENDING) {

                transaction.setStatus(GiftTransaction.TransactionStatus.CANCELLED);
                giftTransactionRepository.save(transaction);

                // Refund to wallet
                walletService.addToWallet(user, transaction.getAmount(),
                        "Gift refund: " + transaction.getGift().getName());
                return true;
            }
        }
        return false;
    }

    @Transactional
    public boolean acceptGift(Long transactionId, User user) {
        Optional<GiftTransaction> transactionOpt = giftTransactionRepository.findById(transactionId);
        if (transactionOpt.isPresent()) {
            GiftTransaction transaction = transactionOpt.get();
            if (transaction.getReceiver().getId().equals(user.getId()) &&
                    transaction.getStatus() == GiftTransaction.TransactionStatus.PENDING) {

                transaction.setStatus(GiftTransaction.TransactionStatus.ACCEPTED);
                giftTransactionRepository.save(transaction);

                // Create notification message in chat
                matchRepository
                        .findMatchBetweenUsers(transaction.getSender().getId(), transaction.getReceiver().getId())
                        .ifPresent(match -> {
                            Message message = new Message();
                            message.setMatch(match);
                            message.setSender(user); // Receiver is the one accepting
                            message.setReceiver(transaction.getSender());
                            message.setContent("✅ Accepted your gift: " + transaction.getGift().getName());
                            message.setMessageType(Message.MessageType.SYSTEM);
                            message.setReferenceId(transaction.getId());
                            Message savedMsg = messageRepository.save(message);

                            // Notify users via WebSocket
                            ChatMessageDTO payload = new ChatMessageDTO(
                                    savedMsg.getId(),
                                    match.getId(),
                                    user.getId(),
                                    transaction.getSender().getId(),
                                    savedMsg.getContent(),
                                    savedMsg.getIsRead(),
                                    savedMsg.getSentAt() != null ? savedMsg.getSentAt() : LocalDateTime.now(),
                                    savedMsg.getMessageType() != null ? savedMsg.getMessageType().name() : null,
                                    savedMsg.getReferenceId()
                            );
                            messagingTemplate.convertAndSend("/queue/messages-" + transaction.getSender().getId(), payload);
                            messagingTemplate.convertAndSend("/queue/messages-" + transaction.getReceiver().getId(), payload);
                        });

                return true;
            }
        }
        return false;
    }
}
