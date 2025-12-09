package com.trish.repository;

import com.trish.model.GiftTransaction;
import com.trish.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GiftTransactionRepository extends JpaRepository<GiftTransaction, Long> {
    List<GiftTransaction> findBySender(User sender);
    List<GiftTransaction> findByReceiver(User receiver);
    List<GiftTransaction> findBySenderOrderByCreatedAtDesc(User sender);
    List<GiftTransaction> findByReceiverOrderByCreatedAtDesc(User receiver);
    List<GiftTransaction> findByStatus(GiftTransaction.TransactionStatus status);
}
