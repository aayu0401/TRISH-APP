package com.trish.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "gifts")
@Data
public class Gift {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private Double price;

    @Column(nullable = false)
    private String imageUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GiftCategory category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GiftType type;

    private Boolean isAvailable = true;

    private Integer stockQuantity;

    private String brand;

    private Integer popularityScore = 0;

    @Column(updatedAt = "CURRENT_TIMESTAMP", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(updatedAt = "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP", insertable = false, updatable = false)
    private LocalDateTime updatedAt;

    public enum GiftCategory {
        FLOWERS, CHOCOLATES, JEWELRY, PERFUME, GADGETS, EXPERIENCES, VIRTUAL, OTHER
    }

    public enum GiftType {
        PHYSICAL, VIRTUAL
    }
}
