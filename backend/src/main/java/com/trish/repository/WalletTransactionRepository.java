package com.trish.repository;

import com.trish.model.WalletTransaction;
import com.trish.model.Wallet;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {
    Page<WalletTransaction> findByWallet(Wallet wallet, Pageable pageable);
    List<WalletTransaction> findByWalletOrderByCreatedAtDesc(Wallet wallet);
    List<WalletTransaction> findByStatus(WalletTransaction.TransactionStatus status);
}
