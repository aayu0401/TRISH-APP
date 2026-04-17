package com.trish.controller;

import com.trish.model.*;
import com.trish.service.GiftService;
import com.trish.service.UserService;
import com.trish.dto.SendGiftRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/gifts")
@CrossOrigin(origins = "*")
public class GiftController {

    @Autowired
    private GiftService giftService;

    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<Gift>> getAllGifts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String type) {

        if (category != null && type != null) {
            return ResponseEntity.ok(
                    giftService.getGiftsByCategoryAndType(
                            Enum.valueOf(Gift.GiftCategory.class, category.toUpperCase()),
                            Enum.valueOf(Gift.GiftType.class, type.toUpperCase())
                    )
            );
        } else if (category != null) {
            return ResponseEntity
                    .ok(giftService.getGiftsByCategory(Enum.valueOf(Gift.GiftCategory.class, category.toUpperCase())));
        } else if (type != null) {
            return ResponseEntity.ok(giftService.getGiftsByType(Enum.valueOf(Gift.GiftType.class, type.toUpperCase())));
        }

        return ResponseEntity.ok(giftService.getAllGifts());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Gift> getGiftById(@PathVariable Long id) {
        return giftService.getGiftById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/popular")
    public ResponseEntity<List<Gift>> getPopularGifts() {
        return ResponseEntity.ok(giftService.getPopularGifts());
    }

    @PostMapping("/send")
    public ResponseEntity<GiftTransaction> sendGift(
            @RequestBody SendGiftRequest request,
            Authentication authentication) {

        Long userId = (Long) authentication.getPrincipal();
        User user = userService.getUserById(userId);
        GiftTransaction transaction = giftService.sendGift(user, request);
        return ResponseEntity.ok(transaction);
    }

    @GetMapping("/sent")
    public ResponseEntity<List<GiftTransaction>> getSentGifts(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        User user = userService.getUserById(userId);
        return ResponseEntity.ok(giftService.getSentGifts(user));
    }

    @GetMapping("/received")
    public ResponseEntity<List<GiftTransaction>> getReceivedGifts(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        User user = userService.getUserById(userId);
        return ResponseEntity.ok(giftService.getReceivedGifts(user));
    }

    @PostMapping("/accept/{transactionId}")
    public ResponseEntity<String> acceptGift(
            @PathVariable Long transactionId,
            Authentication authentication) {

        Long userId = (Long) authentication.getPrincipal();
        User user = userService.getUserById(userId);
        boolean accepted = giftService.acceptGift(transactionId, user);

        if (accepted) {
            return ResponseEntity.ok("Gift accepted successfully");
        }
        return ResponseEntity.badRequest().body("Unable to accept gift");
    }

    @GetMapping("/track/{transactionId}")
    public ResponseEntity<GiftTransaction> trackGift(@PathVariable Long transactionId) {
        return giftService.trackGift(transactionId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/cancel/{transactionId}")
    public ResponseEntity<String> cancelGift(
            @PathVariable Long transactionId,
            Authentication authentication) {

        Long userId = (Long) authentication.getPrincipal();
        User user = userService.getUserById(userId);
        boolean cancelled = giftService.cancelGift(transactionId, user);

        if (cancelled) {
            return ResponseEntity.ok("Gift cancelled successfully");
        }
        return ResponseEntity.badRequest().body("Unable to cancel gift");
    }
}
