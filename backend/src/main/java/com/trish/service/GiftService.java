package com.trish.service;

import com.trish.model.*;
import com.trish.repository.*;
import com.trish.dto.SendGiftRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
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

    public List<Gift> getAllGifts() {
        return giftRepository.findByIsAvailableTrue();
    }

    public List<Gift> getGiftsByCategory(Gift.GiftCategory category) {
        return giftRepository.findByCategory(category);
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
                .orElseThrow(() -> new RuntimeException("Gift not found"));

        User receiver = userRepository.findById(request.getReceiverId())
                .orElseThrow(() -> new RuntimeException("Receiver not found"));

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

        // Increment popularity
        gift.setPopularityScore(gift.getPopularityScore() + 1);
        giftRepository.save(gift);

        return giftTransactionRepository.save(transaction);
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
                walletService.addToWallet(user, transaction.getAmount(), "Gift refund: " + transaction.getGift().getName());
                return true;
            }
        }
        return false;
    }
}
