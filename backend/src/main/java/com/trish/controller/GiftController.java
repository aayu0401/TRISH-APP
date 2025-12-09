package com.trish.controller;

import com.trish.model.*;
import com.trish.service.GiftService;
import com.trish.dto.SendGiftRequest;
import com.trish.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/gifts")
@CrossOrigin(origins = "*")
public class GiftController {

    @Autowired
    private GiftService giftService;

    @Autowired
    private JwtUtil jwtUtil;

    @GetMapping
    public ResponseEntity<List<Gift>> getAllGifts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String type) {
        
        if (category != null && type != null) {
            return ResponseEntity.ok(giftService.getGiftsByCategory(Gift.GiftCategory.valueOf(category.toUpperCase())));
        } else if (category != null) {
            return ResponseEntity.ok(giftService.getGiftsByCategory(Gift.GiftCategory.valueOf(category.toUpperCase())));
        } else if (type != null) {
            return ResponseEntity.ok(giftService.getGiftsByType(Gift.GiftType.valueOf(type.toUpperCase())));
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
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        GiftTransaction transaction = giftService.sendGift(user, request);
        return ResponseEntity.ok(transaction);
    }

    @GetMapping("/sent")
    public ResponseEntity<List<GiftTransaction>> getSentGifts(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(giftService.getSentGifts(user));
    }

    @GetMapping("/received")
    public ResponseEntity<List<GiftTransaction>> getReceivedGifts(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(giftService.getReceivedGifts(user));
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
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        boolean cancelled = giftService.cancelGift(transactionId, user);
        
        if (cancelled) {
            return ResponseEntity.ok("Gift cancelled successfully");
        }
        return ResponseEntity.badRequest().body("Unable to cancel gift");
    }
}
