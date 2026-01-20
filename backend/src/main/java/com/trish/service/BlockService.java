package com.trish.service;

import com.trish.model.Block;
import com.trish.model.User;
import com.trish.repository.BlockRepository;
import com.trish.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BlockService {
    
    private final BlockRepository blockRepository;
    private final UserRepository userRepository;
    
    @Transactional
    public Block blockUser(Long blockerId, Long blockedId, String reason) {
        if (blockerId.equals(blockedId)) {
            throw new IllegalArgumentException("Cannot block yourself");
        }
        
        User blocker = userRepository.findById(blockerId)
            .orElseThrow(() -> new RuntimeException("Blocker not found"));
        User blocked = userRepository.findById(blockedId)
            .orElseThrow(() -> new RuntimeException("User to block not found"));
        
        if (blockRepository.existsByBlockerAndBlocked(blocker, blocked)) {
            throw new IllegalArgumentException("User already blocked");
        }
        
        Block block = new Block();
        block.setBlocker(blocker);
        block.setBlocked(blocked);
        block.setReason(reason);
        
        return blockRepository.save(block);
    }
    
    @Transactional
    public void unblockUser(Long blockerId, Long blockedId) {
        User blocker = userRepository.findById(blockerId)
            .orElseThrow(() -> new RuntimeException("Blocker not found"));
        User blocked = userRepository.findById(blockedId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        Block block = blockRepository.findByBlockerAndBlocked(blocker, blocked)
            .orElseThrow(() -> new RuntimeException("Block not found"));
        
        blockRepository.delete(block);
    }
    
    public List<Block> getBlockedUsers(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return blockRepository.findByBlocker(user);
    }
    
    public boolean isBlocked(Long userId1, Long userId2) {
        User user1 = userRepository.findById(userId1)
            .orElseThrow(() -> new RuntimeException("User not found"));
        User user2 = userRepository.findById(userId2)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        return blockRepository.existsByBlockerAndBlocked(user1, user2) ||
               blockRepository.existsByBlockerAndBlocked(user2, user1);
    }
    
    public List<Long> getBlockedUserIds(Long userId) {
        return blockRepository.findBlockedUserIds(userId);
    }
    
    public List<Long> getBlockerUserIds(Long userId) {
        return blockRepository.findBlockerUserIds(userId);
    }
    
    public List<Long> getAllBlockedRelationships(Long userId) {
        List<Long> blocked = getBlockedUserIds(userId);
        List<Long> blockers = getBlockerUserIds(userId);
        blocked.addAll(blockers);
        return blocked;
    }
}
