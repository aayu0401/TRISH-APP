package com.trish.controller;

import com.trish.model.*;
import com.trish.service.WalletService;
import com.trish.dto.WalletRequest;
import com.trish.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/wallet")
@CrossOrigin(origins = "*")
public class WalletController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private JwtUtil jwtUtil;

    @GetMapping
    public ResponseEntity<Wallet> getWallet(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return walletService.getWallet(user)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.ok(walletService.getOrCreateWallet(user)));
    }

    @PostMapping("/add-money")
    public ResponseEntity<WalletTransaction> addMoney(
            @RequestBody WalletRequest request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        WalletTransaction transaction = walletService.addMoney(user, request);
        return ResponseEntity.ok(transaction);
    }

    @PostMapping("/withdraw")
    public ResponseEntity<WalletTransaction> withdraw(
            @RequestBody WalletRequest request,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        WalletTransaction transaction = walletService.withdraw(user, request);
        return ResponseEntity.ok(transaction);
    }

    @GetMapping("/transactions")
    public ResponseEntity<Page<WalletTransaction>> getTransactions(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int limit,
            HttpServletRequest httpRequest) {
        
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(walletService.getTransactions(user, page, limit));
    }

    @GetMapping("/transactions/{id}")
    public ResponseEntity<WalletTransaction> getTransactionById(@PathVariable Long id) {
        return walletService.getTransactionById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getWalletStats(HttpServletRequest httpRequest) {
        User user = jwtUtil.getUserFromRequest(httpRequest);
        return ResponseEntity.ok(walletService.getWalletStats(user));
    }

    @PostMapping("/verify-payment")
    public ResponseEntity<String> verifyPayment(@RequestBody Map<String, String> request) {
        boolean verified = walletService.verifyPayment(
                request.get("paymentId"),
                request.get("signature")
        );
        
        if (verified) {
            return ResponseEntity.ok("Payment verified");
        }
        return ResponseEntity.badRequest().body("Payment verification failed");
    }
}
