package com.trish.service;

import com.trish.model.*;
import com.trish.repository.*;
import com.trish.dto.WalletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class WalletService {

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private WalletTransactionRepository walletTransactionRepository;

    @Autowired
    private UserRepository userRepository;

    public Wallet getOrCreateWallet(User user) {
        return walletRepository.findByUser(user).orElseGet(() -> {
            Wallet wallet = new Wallet();
            wallet.setUser(user);
            wallet.setBalance(0.0);
            wallet.setTotalEarned(0.0);
            wallet.setTotalSpent(0.0);
            return walletRepository.save(wallet);
        });
    }

    public Optional<Wallet> getWallet(User user) {
        return walletRepository.findByUser(user);
    }

    @Transactional
    public WalletTransaction addToWallet(User user, Double amount, String description) {
        Wallet wallet = getOrCreateWallet(user);
        
        Double balanceBefore = wallet.getBalance();
        Double balanceAfter = balanceBefore + amount;
        
        wallet.setBalance(balanceAfter);
        wallet.setTotalEarned(wallet.getTotalEarned() + amount);
        walletRepository.save(wallet);

        WalletTransaction transaction = new WalletTransaction();
        transaction.setWallet(wallet);
        transaction.setType(WalletTransaction.TransactionType.CREDIT);
        transaction.setAmount(amount);
        transaction.setBalanceBefore(balanceBefore);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setStatus(WalletTransaction.TransactionStatus.COMPLETED);
        transaction.setDescription(description);

        return walletTransactionRepository.save(transaction);
    }

    @Transactional
    public WalletTransaction deductFromWallet(User user, Double amount, String description) {
        Wallet wallet = getOrCreateWallet(user);
        
        if (wallet.getBalance() < amount) {
            throw new RuntimeException("Insufficient balance");
        }

        Double balanceBefore = wallet.getBalance();
        Double balanceAfter = balanceBefore - amount;
        
        wallet.setBalance(balanceAfter);
        wallet.setTotalSpent(wallet.getTotalSpent() + amount);
        walletRepository.save(wallet);

        WalletTransaction transaction = new WalletTransaction();
        transaction.setWallet(wallet);
        transaction.setType(WalletTransaction.TransactionType.DEBIT);
        transaction.setAmount(amount);
        transaction.setBalanceBefore(balanceBefore);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setStatus(WalletTransaction.TransactionStatus.COMPLETED);
        transaction.setDescription(description);

        return walletTransactionRepository.save(transaction);
    }

    @Transactional
    public WalletTransaction addMoney(User user, WalletRequest request) {
        // In production, integrate with payment gateway (Razorpay, Stripe, etc.)
        return addToWallet(user, request.getAmount(), "Added money via " + request.getPaymentMethod());
    }

    @Transactional
    public WalletTransaction withdraw(User user, WalletRequest request) {
        // In production, integrate with bank transfer API
        WalletTransaction transaction = deductFromWallet(user, request.getAmount(), "Withdrawal to bank account");
        transaction.setPaymentMethod("BANK_TRANSFER");
        return walletTransactionRepository.save(transaction);
    }

    public Page<WalletTransaction> getTransactions(User user, int page, int limit) {
        Wallet wallet = getOrCreateWallet(user);
        return walletTransactionRepository.findByWallet(wallet, PageRequest.of(page, limit));
    }

    public Optional<WalletTransaction> getTransactionById(Long id) {
        return walletTransactionRepository.findById(id);
    }

    public Map<String, Object> getWalletStats(User user) {
        Wallet wallet = getOrCreateWallet(user);
        Map<String, Object> stats = new HashMap<>();
        stats.put("balance", wallet.getBalance());
        stats.put("totalEarned", wallet.getTotalEarned());
        stats.put("totalSpent", wallet.getTotalSpent());
        stats.put("currency", wallet.getCurrency());
        return stats;
    }

    public boolean verifyPayment(String paymentId, String signature) {
        // In production, verify payment signature with payment gateway
        return true;
    }
}
